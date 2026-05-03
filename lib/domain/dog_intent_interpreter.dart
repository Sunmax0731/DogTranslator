import 'dart:math';
import 'dart:typed_data';

import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';

class DogIntentInterpreter implements InferenceProvider {
  const DogIntentInterpreter();

  @override
  Future<TranslationResult> analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
    Uint8List? wavBytes,
  }) async {
    final vocalDetected = _detectDogVocal(features);
    final vocalType = _inferVocalType(features);
    final context = _inferContext(features, sceneMode, vocalType);
    final scores = <DogIntent, double>{
      DogIntent.excitedGreeting: _excitedScore(features, sceneMode, profile),
      DogIntent.attentionSeeking: _attentionScore(
        features,
        sceneMode,
        vocalType,
        context,
      ),
      DogIntent.warningAlert: _warningScore(
        features,
        sceneMode,
        profile,
        vocalType,
        context,
      ),
      DogIntent.anxiousWhine: _anxiousScore(
        features,
        sceneMode,
        vocalType,
        context,
      ),
      DogIntent.sleepy: _sleepyScore(features, sceneMode, profile),
      DogIntent.restlessEnergy: _restlessScore(features, vocalType),
      DogIntent.happyRelaxed: _happyScore(features, sceneMode),
      DogIntent.bored: _boredScore(features, sceneMode),
      DogIntent.uncertain: 0.18,
    };

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.first;
    final runnerUp = ranked.length > 1 ? ranked[1] : ranked.first;
    final confidence = _confidenceFor(top.value, runnerUp.value, features);
    final qualityIssues = _qualityIssuesFor(features);
    final hasWeakShortInput =
        qualityIssues.contains(RecordingQualityIssue.tooShort) &&
        qualityIssues.contains(RecordingQualityIssue.lowVolume);
    final lowSignalUnknown =
        !vocalDetected ||
        ((top.value < 0.24 && qualityIssues.isNotEmpty) || hasWeakShortInput);

    final primaryIntent = lowSignalUnknown ? DogIntent.uncertain : top.key;
    final candidates = ranked
        .take(3)
        .map(
          (entry) => TranslationCandidate(
            intent: entry.key,
            score: entry.value.clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);

    final valence = _estimateValence(primaryIntent, context);
    final arousal = _estimateArousal(features, primaryIntent);

    return TranslationResult(
      intent: primaryIntent,
      explanation: _buildExplanation(
        primaryIntent,
        context,
        vocalType,
        vocalDetected,
      ),
      confidence: confidence,
      features: features,
      candidates: candidates,
      qualityIssues: qualityIssues,
      detectedDogVocal: vocalDetected,
      vocalType: vocalType,
      context: context,
      valence: valence,
      arousal: arousal,
      rawConfidence: top.value.clamp(0.0, 1.0),
      providerLabel: 'heuristic-pipeline',
    );
  }

  bool _detectDogVocal(AudioFeatures features) {
    final durationOk = features.durationSeconds >= 0.18;
    final levelOk = features.rms >= 0.025 || features.peak >= 0.08;
    final activityOk =
        features.zeroCrossingRate <= 0.32 || features.burstCount > 0;
    return durationOk && levelOk && activityOk;
  }

  DogVocalType _inferVocalType(AudioFeatures features) {
    if (features.durationSeconds > 1.8 && features.zeroCrossingRate < 0.08) {
      return DogVocalType.howl;
    }
    if (features.rms < 0.07 &&
        features.peak < 0.25 &&
        features.durationSeconds > 0.7) {
      return DogVocalType.whine;
    }
    if (features.peak > 0.8 && features.durationSeconds < 0.3) {
      return DogVocalType.yelp;
    }
    if (features.highBandRatio < 0.12 && features.rms > 0.18) {
      return DogVocalType.growl;
    }
    if (features.zeroCrossingRate > 0.24 && features.rms < 0.05) {
      return DogVocalType.pant;
    }
    if (features.burstCount >= 3 && features.dynamicRange > 0.18) {
      return DogVocalType.mixed;
    }
    if (features.rms > 0.04 || features.peak > 0.1) {
      return DogVocalType.bark;
    }
    return DogVocalType.unknown;
  }

  DogContext _inferContext(
    AudioFeatures features,
    SceneMode sceneMode,
    DogVocalType vocalType,
  ) {
    switch (sceneMode) {
      case SceneMode.playtime:
        return DogContext.play;
      case SceneMode.mealtime:
        return DogContext.foodOrAttention;
      case SceneMode.walk:
        return DogContext.walkAnticipation;
      case SceneMode.guest:
        return DogContext.strangerOrNoise;
      case SceneMode.night:
        return vocalType == DogVocalType.whine
            ? DogContext.alone
            : DogContext.strangerOrNoise;
      case SceneMode.home:
        if (vocalType == DogVocalType.growl) {
          return DogContext.conflict;
        }
        if (features.burstCount >= 2 && features.rms > 0.18) {
          return DogContext.ownerReturn;
        }
        return DogContext.unknown;
    }
  }

  double _excitedScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogProfile? profile,
  ) {
    var score =
        (features.burstCount / 5) +
        (features.rms * 2.2) +
        (features.peak * 0.35) -
        max(0, features.durationSeconds - 1.6) * 0.4;
    if (sceneMode == SceneMode.playtime || sceneMode == SceneMode.walk) {
      score += 0.12;
    }
    if (profile?.ageStage == DogAgeStage.puppy) {
      score += 0.08;
    }
    return score;
  }

  double _attentionScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogVocalType vocalType,
    DogContext context,
  ) {
    var score =
        (features.burstCount / 5.5) +
        ((1.3 - (features.durationSeconds - 0.9).abs()).clamp(0.0, 1.3) *
            0.16) +
        (features.dynamicRange * 0.8);
    if (sceneMode == SceneMode.mealtime ||
        context == DogContext.foodOrAttention) {
      score += 0.1;
    }
    if (vocalType == DogVocalType.whine) {
      score += 0.06;
    }
    return score;
  }

  double _warningScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogProfile? profile,
    DogVocalType vocalType,
    DogContext context,
  ) {
    var score =
        (features.peak * 0.9) +
        (features.rms * 1.7) +
        (features.spectralCentroid / 4000) +
        (features.highBandRatio * 0.7);
    if (features.durationSeconds > 1.0) {
      score -= 0.15;
    }
    if (sceneMode == SceneMode.guest || context == DogContext.strangerOrNoise) {
      score += 0.16;
    }
    if (profile?.sizeClass == DogSizeClass.large) {
      score += 0.05;
    }
    if (vocalType == DogVocalType.growl) {
      score += 0.1;
    }
    return score;
  }

  double _anxiousScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogVocalType vocalType,
    DogContext context,
  ) {
    var score =
        (features.durationSeconds * 0.28) +
        ((0.16 - features.peak).clamp(0.0, 0.16) * 3.5) +
        (features.zeroCrossingRate * 1.6);
    if (sceneMode == SceneMode.night || context == DogContext.alone) {
      score += 0.08;
    }
    if (vocalType == DogVocalType.whine) {
      score += 0.14;
    }
    return score;
  }

  double _sleepyScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogProfile? profile,
  ) {
    var score =
        (features.durationSeconds * 0.22) +
        ((0.10 - features.rms).clamp(0.0, 0.10) * 4.0) +
        ((0.22 - features.peak).clamp(0.0, 0.22) * 2.0);
    if (sceneMode == SceneMode.night) {
      score += 0.15;
    }
    if (profile?.ageStage == DogAgeStage.senior) {
      score += 0.08;
    }
    return score;
  }

  double _restlessScore(AudioFeatures features, DogVocalType vocalType) {
    var score =
        (features.rms * 1.8) +
        (features.dynamicRange * 1.1) +
        (features.burstCount * 0.12);
    if (vocalType == DogVocalType.mixed || vocalType == DogVocalType.yelp) {
      score += 0.08;
    }
    return score;
  }

  double _happyScore(AudioFeatures features, SceneMode sceneMode) {
    var score =
        (features.rms * 1.2) +
        (features.dynamicRange * 0.8) +
        ((1.4 - features.durationSeconds).clamp(0.0, 1.4) * 0.15);
    if (sceneMode == SceneMode.home || sceneMode == SceneMode.walk) {
      score += 0.08;
    }
    return score;
  }

  double _boredScore(AudioFeatures features, SceneMode sceneMode) {
    var score =
        (features.durationSeconds * 0.24) +
        ((0.11 - features.rms).clamp(0.0, 0.11) * 2.8) +
        ((2 - features.burstCount).clamp(0, 2) * 0.1);
    if (sceneMode == SceneMode.home) {
      score += 0.05;
    }
    return score;
  }

  ConfidenceLevel _confidenceFor(
    double topScore,
    double runnerUpScore,
    AudioFeatures features,
  ) {
    final gap = topScore - runnerUpScore;
    if (topScore > 0.8 && gap > 0.18 && features.peak > 0.08) {
      return ConfidenceLevel.high;
    }
    if (topScore > 0.45 && gap > 0.06) {
      return ConfidenceLevel.medium;
    }
    return ConfidenceLevel.low;
  }

  List<RecordingQualityIssue> _qualityIssuesFor(AudioFeatures features) {
    final issues = <RecordingQualityIssue>[];
    if (features.durationSeconds < 0.25) {
      issues.add(RecordingQualityIssue.tooShort);
    }
    if (features.rms < 0.035) {
      issues.add(RecordingQualityIssue.lowVolume);
    }
    if (features.peak > 0.9 && features.dynamicRange < 0.08) {
      issues.add(RecordingQualityIssue.peakyInput);
    }
    if (features.zeroCrossingRate > 0.25 || features.highBandRatio > 0.65) {
      issues.add(RecordingQualityIssue.unstableNoise);
    }
    return issues;
  }

  double _estimateValence(DogIntent intent, DogContext context) {
    final base = switch (intent) {
      DogIntent.excitedGreeting => 0.62,
      DogIntent.attentionSeeking => 0.18,
      DogIntent.warningAlert => -0.42,
      DogIntent.anxiousWhine => -0.56,
      DogIntent.sleepy => 0.08,
      DogIntent.restlessEnergy => -0.08,
      DogIntent.happyRelaxed => 0.74,
      DogIntent.bored => -0.15,
      DogIntent.uncertain => 0.0,
    };
    final contextShift = switch (context) {
      DogContext.play => 0.08,
      DogContext.ownerReturn => 0.1,
      DogContext.foodOrAttention => 0.02,
      DogContext.walkAnticipation => 0.14,
      DogContext.strangerOrNoise => -0.12,
      DogContext.alone => -0.14,
      DogContext.otherDog => -0.04,
      DogContext.conflict => -0.18,
      DogContext.unknown => 0.0,
    };
    return (base + contextShift).clamp(-1.0, 1.0);
  }

  double _estimateArousal(AudioFeatures features, DogIntent intent) {
    final energy =
        (features.rms * 2.6) +
        (features.peak * 0.8) +
        (features.dynamicRange * 1.4);
    final intentShift = switch (intent) {
      DogIntent.warningAlert => 0.18,
      DogIntent.excitedGreeting => 0.15,
      DogIntent.restlessEnergy => 0.14,
      DogIntent.attentionSeeking => 0.05,
      DogIntent.anxiousWhine => 0.02,
      DogIntent.sleepy => -0.22,
      DogIntent.happyRelaxed => -0.05,
      DogIntent.bored => -0.1,
      DogIntent.uncertain => 0.0,
    };
    return (energy + intentShift).clamp(0.0, 1.0);
  }

  String _buildExplanation(
    DogIntent intent,
    DogContext context,
    DogVocalType vocalType,
    bool vocalDetected,
  ) {
    if (!vocalDetected) {
      return '犬の声らしい区間を十分に検出できませんでした。雑音が多い可能性があります。';
    }

    final contextText = switch (context) {
      DogContext.strangerOrNoise => '来客や物音に反応している',
      DogContext.ownerReturn => '飼い主の帰宅に反応している',
      DogContext.foodOrAttention => '食事や注目を求めている',
      DogContext.walkAnticipation => '散歩への期待が高まっている',
      DogContext.play => '遊びに誘っている',
      DogContext.alone => 'ひとりで不安を感じている',
      DogContext.otherDog => '他の犬に反応している',
      DogContext.conflict => '緊張や競合がありそうな',
      DogContext.unknown => '何らかの場面に反応している',
    };

    return '${intent.explanationJa} 鳴き方は ${vocalType.labelJa} 寄りで、'
        '$contextText可能性があります。';
  }
}
