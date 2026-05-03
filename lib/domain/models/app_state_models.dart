import 'dart:convert';

import 'enums.dart';
import 'history_models.dart';
import 'profile_models.dart';

class AppSettings {
  const AppSettings({
    required this.selectedProfileId,
    required this.selectedInputDeviceId,
    required this.selectedInferenceModel,
    required this.selectedBreed,
    required this.selectedAgeStage,
    required this.selectedSizeClass,
    required this.selectedTension,
    required this.selectedSceneMode,
  });

  final String? selectedProfileId;
  final String? selectedInputDeviceId;
  final InferenceModelSelection selectedInferenceModel;
  final DogBreed selectedBreed;
  final DogAgeStage selectedAgeStage;
  final DogSizeClass selectedSizeClass;
  final TensionLevel selectedTension;
  final SceneMode selectedSceneMode;

  Map<String, dynamic> toJson() {
    return {
      'selectedProfileId': selectedProfileId,
      'selectedInputDeviceId': selectedInputDeviceId,
      'selectedInferenceModel': selectedInferenceModel.name,
      'selectedBreed': selectedBreed.name,
      'selectedAgeStage': selectedAgeStage.name,
      'selectedSizeClass': selectedSizeClass.name,
      'selectedTension': selectedTension.name,
      'selectedSceneMode': selectedSceneMode.name,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      selectedProfileId: json['selectedProfileId'] as String?,
      selectedInputDeviceId: json['selectedInputDeviceId'] as String?,
      selectedInferenceModel: InferenceModelSelectionText.fromKey(
        json['selectedInferenceModel'] as String?,
      ),
      selectedBreed: DogBreedText.fromKey(json['selectedBreed'] as String?),
      selectedAgeStage: DogAgeStageText.fromKey(
        json['selectedAgeStage'] as String?,
      ),
      selectedSizeClass: DogSizeClassText.fromKey(
        json['selectedSizeClass'] as String?,
      ),
      selectedTension: TensionLevelText.fromKey(
        json['selectedTension'] as String?,
      ),
      selectedSceneMode: SceneModeText.fromKey(
        json['selectedSceneMode'] as String?,
      ),
    );
  }

  static const defaults = AppSettings(
    selectedProfileId: null,
    selectedInputDeviceId: null,
    selectedInferenceModel: InferenceModelSelection.auto,
    selectedBreed: DogBreed.mixed,
    selectedAgeStage: DogAgeStage.adult,
    selectedSizeClass: DogSizeClass.medium,
    selectedTension: TensionLevel.normal,
    selectedSceneMode: SceneMode.home,
  );
}

class AppData {
  const AppData({
    required this.profiles,
    required this.forwardRecords,
    required this.reverseRecords,
    required this.settings,
  });

  final List<DogProfile> profiles;
  final List<ForwardRecord> forwardRecords;
  final List<ReverseRecord> reverseRecords;
  final AppSettings settings;

  Map<String, dynamic> toJson() {
    return {
      'profiles': profiles.map((value) => value.toJson()).toList(),
      'forwardRecords': forwardRecords.map((value) => value.toJson()).toList(),
      'reverseRecords': reverseRecords.map((value) => value.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final profilesJson = json['profiles'] as List<dynamic>? ?? const [];
    final forwardJson = json['forwardRecords'] as List<dynamic>? ?? const [];
    final reverseJson = json['reverseRecords'] as List<dynamic>? ?? const [];

    return AppData(
      profiles: profilesJson
          .map(
            (value) => DogProfile.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      forwardRecords: forwardJson
          .map(
            (value) => ForwardRecord.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      reverseRecords: reverseJson
          .map(
            (value) => ReverseRecord.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      settings: AppSettings.fromJson(
        (json['settings'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
    );
  }

  static const empty = AppData(
    profiles: <DogProfile>[],
    forwardRecords: <ForwardRecord>[],
    reverseRecords: <ReverseRecord>[],
    settings: AppSettings.defaults,
  );
}

class RecordingInputDevice {
  const RecordingInputDevice({required this.id, required this.label});

  final String id;
  final String label;
}
