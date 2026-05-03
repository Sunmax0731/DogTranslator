import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:path_provider/path_provider.dart';

class JsonFileAppRepository implements AppRepository {
  JsonFileAppRepository({Directory? baseDirectory})
    : _baseDirectoryOverride = baseDirectory;

  final Directory? _baseDirectoryOverride;

  @override
  Future<AppData> load() async {
    try {
      final file = await _dataFile();
      if (!await file.exists()) {
        return AppData.empty;
      }
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (_) {
      return AppData.empty;
    }
  }

  @override
  Future<void> save(AppData data) async {
    final file = await _dataFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(data.toPrettyJson(), flush: true);
  }

  @override
  Future<String?> saveRecording(Uint8List wavBytes, String recordId) async {
    final baseDirectory = await _baseDirectory();
    final recordingsDirectory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}recordings',
    );
    await recordingsDirectory.create(recursive: true);
    final file = File(
      '${recordingsDirectory.path}${Platform.pathSeparator}$recordId.wav',
    );
    await file.writeAsBytes(wavBytes, flush: true);
    return file.path;
  }

  Future<File> _dataFile() async {
    final baseDirectory = await _baseDirectory();
    return File(
      '${baseDirectory.path}${Platform.pathSeparator}dog_translator_state.json',
    );
  }

  Future<Directory> _baseDirectory() async {
    final override = _baseDirectoryOverride;
    if (override != null) {
      await override.create(recursive: true);
      return override;
    }

    final directory = await getApplicationSupportDirectory();
    final appDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}dog_translator',
    );
    await appDirectory.create(recursive: true);
    return appDirectory;
  }
}
