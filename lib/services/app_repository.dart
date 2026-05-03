import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';

abstract class AppRepository {
  Future<AppData> load();

  Future<void> save(AppData data);

  Future<String?> saveRecording(Uint8List wavBytes, String recordId);
}
