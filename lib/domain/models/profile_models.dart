import 'enums.dart';

class DogProfile {
  const DogProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.notes,
    required this.createdAtIso,
  });

  final String id;
  final String name;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final String notes;
  final String createdAtIso;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed.name,
      'ageStage': ageStage.name,
      'sizeClass': sizeClass.name,
      'notes': notes,
      'createdAtIso': createdAtIso,
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
    );
  }
}
