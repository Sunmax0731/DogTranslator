import 'dart:io';

import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/json_file_app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists and reloads app data from json file', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'dog_translator_repo_test_',
    );
    final repository = JsonFileAppRepository(baseDirectory: tempDirectory);

    const data = AppData(
      profiles: <DogProfile>[
        DogProfile(
          id: 'profile-1',
          name: 'Mugi',
          breed: DogBreed.shiba,
          ageStage: DogAgeStage.adult,
          sizeClass: DogSizeClass.medium,
          notes: 'memo',
          createdAtIso: '2026-05-04T00:00:00.000',
        ),
      ],
      forwardRecords: <ForwardRecord>[],
      reverseRecords: <ReverseRecord>[],
      settings: AppSettings.defaults,
    );

    await repository.save(data);
    final loaded = await repository.load();

    expect(loaded.profiles.length, 1);
    expect(loaded.profiles.first.name, 'Mugi');

    await tempDirectory.delete(recursive: true);
  });
}
