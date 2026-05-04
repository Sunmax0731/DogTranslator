import 'dart:io';

import 'package:dog_translator/services/local_inference_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefers explicit runtime config environment path when present', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'dog_translator_runtime_loader_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    final configFile = File(
      '${tempDir.path}${Platform.pathSeparator}dog2vec_runtime.json',
    );
    await configFile.writeAsString(
      '''
      {
        "enabled": true,
        "command": "python",
        "args": ["app/infer.py"],
        "timeoutMs": 12000
      }
      ''',
    );

    final loader = LocalInferenceRuntimeConfigLoader(
      environment: <String, String>{
        'DOG_TRANSLATOR_RUNTIME_CONFIG': configFile.path,
      },
      currentDirectoryPath: tempDir.path,
      executablePath: '${tempDir.path}${Platform.pathSeparator}dog_translator.exe',
    );

    final config = await loader.load();

    expect(config, isNotNull);
    expect(config!.command, 'python');
    expect(config.timeout, const Duration(milliseconds: 12000));
  });

  test('falls back to LOCALAPPDATA DogTranslator config', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'dog_translator_runtime_loader_localappdata_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    final configDir = Directory(
      '${tempDir.path}${Platform.pathSeparator}DogTranslator${Platform.pathSeparator}.dog2vec',
    );
    await configDir.create(recursive: true);
    final configFile = File(
      '${configDir.path}${Platform.pathSeparator}dog2vec_runtime.json',
    );
    await configFile.writeAsString(
      '''
      {
        "enabled": true,
        "command": "python.exe",
        "args": ["app/infer.py"],
        "workingDirectory": "C:/DogTranslator/runtime",
        "timeoutMs": 15000
      }
      ''',
    );

    final loader = LocalInferenceRuntimeConfigLoader(
      environment: <String, String>{
        'LOCALAPPDATA': tempDir.path,
      },
      currentDirectoryPath: '${tempDir.path}${Platform.pathSeparator}workspace',
      executablePath:
          '${tempDir.path}${Platform.pathSeparator}workspace${Platform.pathSeparator}dog_translator.exe',
    );

    final config = await loader.load();

    expect(config, isNotNull);
    expect(config!.command, 'python.exe');
    expect(config.workingDirectory, 'C:/DogTranslator/runtime');
  });
}
