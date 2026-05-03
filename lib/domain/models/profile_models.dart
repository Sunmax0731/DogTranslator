import 'enums.dart';

class DogVoiceCalibration {
  const DogVoiceCalibration({
    required this.sampleCount,
    required this.averagePitchHz,
    required this.averageRms,
    required this.averageActivityRatio,
    required this.lastSampleAtIso,
  });

  final int sampleCount;
  final double averagePitchHz;
  final double averageRms;
  final double averageActivityRatio;
  final String? lastSampleAtIso;

  Map<String, dynamic> toJson() {
    return {
      'sampleCount': sampleCount,
      'averagePitchHz': averagePitchHz,
      'averageRms': averageRms,
      'averageActivityRatio': averageActivityRatio,
      'lastSampleAtIso': lastSampleAtIso,
    };
  }

  factory DogVoiceCalibration.fromJson(Map<String, dynamic> json) {
    return DogVoiceCalibration(
      sampleCount: (json['sampleCount'] as num?)?.toInt() ?? 0,
      averagePitchHz: (json['averagePitchHz'] as num?)?.toDouble() ?? 0,
      averageRms: (json['averageRms'] as num?)?.toDouble() ?? 0,
      averageActivityRatio:
          (json['averageActivityRatio'] as num?)?.toDouble() ?? 0,
      lastSampleAtIso: json['lastSampleAtIso'] as String?,
    );
  }

  DogVoiceCalibration mergeSample({
    required double pitchHz,
    required double rms,
    required double activityRatio,
    required String timestampIso,
  }) {
    final nextCount = sampleCount + 1;
    return DogVoiceCalibration(
      sampleCount: nextCount,
      averagePitchHz: _nextAverage(averagePitchHz, pitchHz, sampleCount),
      averageRms: _nextAverage(averageRms, rms, sampleCount),
      averageActivityRatio: _nextAverage(
        averageActivityRatio,
        activityRatio,
        sampleCount,
      ),
      lastSampleAtIso: timestampIso,
    );
  }

  static double _nextAverage(double current, double sample, int count) {
    if (count <= 0) {
      return sample;
    }
    return ((current * count) + sample) / (count + 1);
  }
}

class DogProfile {
  const DogProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.notes,
    required this.createdAtIso,
    this.voiceCalibration,
  });

  final String id;
  final String name;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final String notes;
  final String createdAtIso;
  final DogVoiceCalibration? voiceCalibration;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed.name,
      'ageStage': ageStage.name,
      'sizeClass': sizeClass.name,
      'notes': notes,
      'createdAtIso': createdAtIso,
      'voiceCalibration': voiceCalibration?.toJson(),
    };
  }

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    return DogProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'プロフィール',
      breed: DogBreedText.fromKey(json['breed'] as String?),
      ageStage: DogAgeStageText.fromKey(json['ageStage'] as String?),
      sizeClass: DogSizeClassText.fromKey(json['sizeClass'] as String?),
      notes: json['notes'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String? ?? '',
      voiceCalibration:
          (json['voiceCalibration'] as Map<dynamic, dynamic>?) == null
          ? null
          : DogVoiceCalibration.fromJson(
              (json['voiceCalibration'] as Map<dynamic, dynamic>)
                  .cast<String, dynamic>(),
            ),
    );
  }

  DogProfile copyWith({
    String? id,
    String? name,
    DogBreed? breed,
    DogAgeStage? ageStage,
    DogSizeClass? sizeClass,
    String? notes,
    String? createdAtIso,
    DogVoiceCalibration? voiceCalibration,
    bool clearVoiceCalibration = false,
  }) {
    return DogProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageStage: ageStage ?? this.ageStage,
      sizeClass: sizeClass ?? this.sizeClass,
      notes: notes ?? this.notes,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      voiceCalibration: clearVoiceCalibration
          ? null
          : (voiceCalibration ?? this.voiceCalibration),
    );
  }
}
