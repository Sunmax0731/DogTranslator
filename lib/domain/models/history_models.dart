import 'enums.dart';
import 'translation_models.dart';

class ForwardRecord {
  const ForwardRecord({
    required this.id,
    required this.timestampIso,
    required this.profileId,
    required this.sceneMode,
    required this.translation,
    required this.recordingPath,
    required this.feedbackLabel,
  });

  final String id;
  final String timestampIso;
  final String? profileId;
  final SceneMode sceneMode;
  final TranslationResult translation;
  final String? recordingPath;
  final UserFeedbackLabel? feedbackLabel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampIso': timestampIso,
      'profileId': profileId,
      'sceneMode': sceneMode.name,
      'translation': translation.toJson(),
      'recordingPath': recordingPath,
      'feedbackLabel': feedbackLabel?.name,
    };
  }

  factory ForwardRecord.fromJson(Map<String, dynamic> json) {
    return ForwardRecord(
      id: json['id'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
      profileId: json['profileId'] as String?,
      sceneMode: SceneModeText.fromKey(json['sceneMode'] as String?),
      translation: TranslationResult.fromJson(
        (json['translation'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
      recordingPath: json['recordingPath'] as String?,
      feedbackLabel: json['feedbackLabel'] == null
          ? null
          : UserFeedbackLabelText.fromKey(json['feedbackLabel'] as String?),
    );
  }
}

class ReverseRecord {
  const ReverseRecord({
    required this.id,
    required this.timestampIso,
    required this.profileId,
    required this.sceneMode,
    required this.style,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.tension,
    required this.dogText,
    required this.explanation,
  });

  final String id;
  final String timestampIso;
  final String? profileId;
  final SceneMode sceneMode;
  final ReverseEmotionStyle style;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final TensionLevel tension;
  final String dogText;
  final String explanation;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampIso': timestampIso,
      'profileId': profileId,
      'sceneMode': sceneMode.name,
      'style': style.name,
      'breed': breed.name,
      'ageStage': ageStage.name,
      'sizeClass': sizeClass.name,
      'tension': tension.name,
      'dogText': dogText,
      'explanation': explanation,
    };
  }

  factory ReverseRecord.fromJson(Map<String, dynamic> json) {
    return ReverseRecord(
      id: json['id'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
      profileId: json['profileId'] as String?,
      sceneMode: SceneModeText.fromKey(json['sceneMode'] as String?),
      style: ReverseEmotionStyle.values.firstWhere(
        (value) => value.name == json['style'],
        orElse: () => ReverseEmotionStyle.neutral,
      ),
      breed: DogBreedText.fromKey(json['breed'] as String?),
      ageStage: DogAgeStageText.fromKey(json['ageStage'] as String?),
      sizeClass: DogSizeClassText.fromKey(json['sizeClass'] as String?),
      tension: TensionLevelText.fromKey(json['tension'] as String?),
      dogText: json['dogText'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

enum InteractionMode { forward, reverse }

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isPersisted,
  });

  final String id;
  final InteractionMode mode;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isPersisted;
}
