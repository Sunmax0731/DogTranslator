import 'dart:io';

import 'package:dog_translator/services/recording_service.dart';
import 'package:record/record.dart';

class RecordRecordingService implements RecordingService {
  AudioRecorder? _recorder;
  String? _activePath;
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  AudioRecorder get _instance => _recorder ??= AudioRecorder();

  @override
  Future<bool> hasPermission() {
    return _instance.hasPermission();
  }

  @override
  Future<void> start() async {
    final path =
        '${Directory.systemTemp.path}\\dog_translator_${DateTime.now().microsecondsSinceEpoch}.wav';
    await _instance.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
    _activePath = path;
    _isRecording = true;
  }

  @override
  Future<String?> stop() async {
    final recorder = _recorder;
    if (recorder == null) {
      _isRecording = false;
      return _activePath;
    }

    final path = await recorder.stop();
    final resolved = path ?? _activePath;
    _activePath = null;
    _isRecording = false;
    return resolved;
  }

  @override
  Future<void> dispose() async {
    final recorder = _recorder;
    _recorder = null;
    if (recorder != null) {
      await recorder.dispose();
    }
  }
}
