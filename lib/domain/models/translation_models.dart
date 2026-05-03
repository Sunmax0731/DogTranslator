import 'dart:typed_data';

import 'audio_features.dart';
import 'enums.dart';

class TranslationCandidate {
  const TranslationCandidate({required this.intent, required this.score});

  final DogIntent intent;
  final double score;

  Map<String, dynamic> toJson() {
    return {'intent': intent.name, 'score': score};
  }

  factory TranslationCandidate.fromJson(Map<String, dynamic> json) {
    return TranslationCandidate(
      intent: DogIntentText.fromKey(json['intent'] as String?),
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TranslationResult {
  const TranslationResult({
    required this.intent,
    required this.explanation,
    required this.confidence,
    required this.features,
    required this.candidates,
    required this.qualityIssues,
  });

  final DogIntent intent;
  final String explanation;
  final ConfidenceLevel confidence;
  final AudioFeatures features;
  final List<TranslationCandidate> candidates;
  final List<RecordingQualityIssue> qualityIssues;

  Map<String, dynamic> toJson() {
    return {
      'intent': intent.name,
      'explanation': explanation,
      'confidence': confidence.key,
      'features': features.toJson(),
      'candidates': candidates.map((candidate) => candidate.toJson()).toList(),
      'qualityIssues': qualityIssues.map((issue) => issue.name).toList(),
    };
  }

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    final candidateJson = json['candidates'] as List<dynamic>? ?? const [];
    final qualityJson = json['qualityIssues'] as List<dynamic>? ?? const [];
    return TranslationResult(
      intent: DogIntentText.fromKey(json['intent'] as String?),
      explanation: json['explanation'] as String? ?? '',
      confidence: ConfidenceLevelText.fromKey(json['confidence'] as String?),
      features: AudioFeatures.fromJson(
        (json['features'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
      candidates: candidateJson
          .map(
            (value) => TranslationCandidate.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      qualityIssues: qualityJson
          .map((value) => RecordingQualityIssueText.fromKey(value as String?))
          .toList(growable: false),
    );
  }
}

class ReverseTranslationResult {
  const ReverseTranslationResult({
    required this.style,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.tension,
    required this.dogText,
    required this.explanation,
    required this.audioBytes,
  });

  final ReverseEmotionStyle style;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final TensionLevel tension;
  final String dogText;
  final String explanation;
  final Uint8List audioBytes;
}
