import 'dart:io';

import 'package:dog_translator/services/recording_service.dart';
import 'package:record/record.dart';

class RecordRecordingService implements RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _activePath;
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> hasPermission() {
    return _recorder.hasPermission();
  }

  @override
  Future<void> start() async {
    final path =
        '${Directory.systemTemp.path}\\dog_translator_${DateTime.now().microsecondsSinceEpoch}.wav';
    await _recorder.start(
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
    final path = await _recorder.stop();
    final resolved = path ?? _activePath;
    _activePath = null;
    _isRecording = false;
    return resolved;
  }

  @override
  Future<void> dispose() {
    return _recorder.dispose();
  }
}
