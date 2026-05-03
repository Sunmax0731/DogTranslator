import 'dart:math';

import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';

class DogIntentInterpreter implements InferenceProvider {
  const DogIntentInterpreter();

  @override
  TranslationResult analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
  }) {
    final scores = <DogIntent, double>{
      DogIntent.excitedGreeting: _excitedScore(features, sceneMode, profile),
      DogIntent.attentionSeeking: _attentionScore(features, sceneMode),
      DogIntent.warningAlert: _warningScore(features, sceneMode, profile),
      DogIntent.anxiousWhine: _anxiousScore(features, sceneMode),
      DogIntent.sleepy: _sleepyScore(features, sceneMode, profile),
      DogIntent.restlessEnergy: _restlessScore(features),
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

    final primaryIntent =
        (top.value < 0.24 && qualityIssues.isNotEmpty) || hasWeakShortInput
        ? DogIntent.uncertain
        : top.key;
    final candidates = ranked
        .take(3)
        .map(
          (entry) => TranslationCandidate(
            intent: entry.key,
            score: entry.value.clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);

    return TranslationResult(
      intent: primaryIntent,
      explanation: primaryIntent.explanationJa,
      confidence: confidence,
      features: features,
      candidates: candidates,
      qualityIssues: qualityIssues,
    );
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

  double _attentionScore(AudioFeatures features, SceneMode sceneMode) {
    var score =
        (features.burstCount / 5.5) +
        ((1.3 - (features.durationSeconds - 0.9).abs()).clamp(0.0, 1.3) *
            0.16) +
        (features.dynamicRange * 0.8);
    if (sceneMode == SceneMode.mealtime) {
      score += 0.1;
    }
    return score;
  }

  double _warningScore(
    AudioFeatures features,
    SceneMode sceneMode,
    DogProfile? profile,
  ) {
    var score =
        (features.peak * 0.9) +
        (features.rms * 1.7) +
        (features.spectralCentroid / 4000) +
        (features.highBandRatio * 0.7);
    if (features.durationSeconds > 1.0) {
      score -= 0.15;
    }
    if (sceneMode == SceneMode.guest) {
      score += 0.16;
    }
    if (profile?.sizeClass == DogSizeClass.large) {
      score += 0.05;
    }
    return score;
  }

  double _anxiousScore(AudioFeatures features, SceneMode sceneMode) {
    var score =
        (features.durationSeconds * 0.28) +
        ((0.16 - features.peak).clamp(0.0, 0.16) * 3.5) +
        (features.zeroCrossingRate * 1.6);
    if (sceneMode == SceneMode.night) {
      score += 0.08;
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

  double _restlessScore(AudioFeatures features) {
    return (features.rms * 1.8) +
        (features.dynamicRange * 1.1) +
        (features.burstCount * 0.12);
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
}
