import 'package:dog_translator/domain/models.dart';

abstract class RecordingService {
  bool get isRecording;

  String? get selectedInputDeviceId;

  Future<bool> hasPermission();

  Future<List<RecordingInputDevice>> listInputDevices();

  Future<void> selectInputDevice(String? deviceId);

  Stream<double> amplitudeStream();

  Future<void> start();

  Future<String?> stop();

  Future<void> dispose();
}
