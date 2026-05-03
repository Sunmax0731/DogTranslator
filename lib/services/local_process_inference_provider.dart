import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/local_inference_runtime.dart';

typedef ProcessExecutor =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

class LocalProcessInferenceProvider implements InferenceProvider {
  LocalProcessInferenceProvider({
    required LocalInferenceRuntimeConfig config,
    ProcessExecutor? executor,
  }) : _config = config,
       _executor = executor ?? _defaultExecutor;

  final LocalInferenceRuntimeConfig _config;
  final ProcessExecutor _executor;

  static Future<ProcessResult> _defaultExecutor(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  }

  @override
  Future<TranslationResult> analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
    Uint8List? wavBytes,
  }) async {
    if (wavBytes == null || wavBytes.isEmpty) {
      throw ArgumentError('wavBytes are required for local process inference.');
    }

    final tempDir = await Directory.systemTemp.createTemp(
      'dog_translator_infer_',
    );
    final wavFile = File('${tempDir.path}${Platform.pathSeparator}input.wav');
    try {
      await wavFile.writeAsBytes(wavBytes, flush: true);
      final args = <String>[..._config.arguments, '--input', wavFile.path];
      final result = await _executor(
        _config.command,
        args,
        workingDirectory: _config.workingDirectory,
      ).timeout(_config.timeout);

      if (result.exitCode != 0) {
        throw ProcessException(
          _config.command,
          args,
          result.stderr.toString(),
          result.exitCode,
        );
      }

      final json = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      return _mapResponse(json, features);
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  TranslationResult _mapResponse(
    Map<String, dynamic> json,
    AudioFeatures features,
  ) {
    final topEmotionKey =
        ((json['emotion'] as Map<String, dynamic>?)?['top'] as String?) ??
        'unknown';
    final topEmotionScore =
        ((json['emotion'] as Map<String, dynamic>?)?['score'] as num?)
            ?.toDouble() ??
        0;
    final topContextKey =
        ((json['context'] as Map<String, dynamic>?)?['top'] as String?) ??
        'unknown';
    final contextScore =
        ((json['context'] as Map<String, dynamic>?)?['score'] as num?)
            ?.toDouble() ??
        0;
    final rawConfidence =
        (json['confidence'] as num?)?.toDouble() ?? topEmotionScore;
    final mappedIntent = _mapEmotion(topEmotionKey);
    final mappedContext = _mapContext(topContextKey);
    final vocalType = DogVocalTypeText.fromKey(json['vocal_type'] as String?);
    final message = json['message'] as String? ?? mappedIntent.explanationJa;

    return TranslationResult(
      intent: mappedIntent,
      explanation: message,
      confidence: _confidenceFromScore(rawConfidence),
      features: features,
      candidates: <TranslationCandidate>[
        TranslationCandidate(
          intent: mappedIntent,
          score: topEmotionScore.clamp(0.0, 1.0),
        ),
        if (contextScore > 0)
          TranslationCandidate(
            intent: mappedIntent == DogIntent.uncertain
                ? DogIntent.attentionSeeking
                : DogIntent.uncertain,
            score: (1.0 - topEmotionScore).clamp(0.0, 1.0),
          ),
      ],
      qualityIssues: const <RecordingQualityIssue>[],
      detectedDogVocal: json['detected'] as bool? ?? true,
      vocalType: vocalType,
      context: mappedContext,
      valence: (json['valence'] as num?)?.toDouble() ?? 0,
      arousal: (json['arousal'] as num?)?.toDouble() ?? 0,
      rawConfidence: rawConfidence.clamp(0.0, 1.0),
      providerLabel: 'dog2vec-local',
    );
  }

  DogIntent _mapEmotion(String key) {
    switch (key) {
      case 'alert':
      case 'aggression':
        return DogIntent.warningAlert;
      case 'fear':
      case 'loneliness':
      case 'pain_warning':
        return DogIntent.anxiousWhine;
      case 'excitement':
      case 'playful':
        return DogIntent.excitedGreeting;
      case 'request':
        return DogIntent.attentionSeeking;
      case 'frustration':
        return DogIntent.restlessEnergy;
      default:
        return DogIntent.uncertain;
    }
  }

  DogContext _mapContext(String key) {
    switch (key) {
      case 'stranger_or_noise':
        return DogContext.strangerOrNoise;
      case 'owner_return':
        return DogContext.ownerReturn;
      case 'food_or_attention':
        return DogContext.foodOrAttention;
      case 'walk_anticipation':
        return DogContext.walkAnticipation;
      case 'play':
        return DogContext.play;
      case 'alone':
        return DogContext.alone;
      case 'other_dog':
        return DogContext.otherDog;
      case 'conflict':
        return DogContext.conflict;
      default:
        return DogContext.unknown;
    }
  }

  ConfidenceLevel _confidenceFromScore(double score) {
    if (score >= 0.75) {
      return ConfidenceLevel.high;
    }
    if (score >= 0.5) {
      return ConfidenceLevel.medium;
    }
    return ConfidenceLevel.low;
  }
}
