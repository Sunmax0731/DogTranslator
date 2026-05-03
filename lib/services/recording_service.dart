abstract class RecordingService {
  bool get isRecording;

  Future<bool> hasPermission();

  Future<void> start();

  Future<String?> stop();

  Future<void> dispose();
}
