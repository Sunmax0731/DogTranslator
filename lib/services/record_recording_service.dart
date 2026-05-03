import 'dart:async';
import 'dart:io';

import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:record/record.dart';

class RecordRecordingService implements RecordingService {
  AudioRecorder? _recorder;
  String? _activePath;
  bool _isRecording = false;
  String? _selectedInputDeviceId;

  @override
  bool get isRecording => _isRecording;

  @override
  String? get selectedInputDeviceId => _selectedInputDeviceId;

  AudioRecorder get _instance => _recorder ??= AudioRecorder();

  @override
  Future<bool> hasPermission() {
    return _instance.hasPermission();
  }

  @override
  Future<List<RecordingInputDevice>> listInputDevices() async {
    final devices = await _instance.listInputDevices();
    return devices
        .map(
          (device) => RecordingInputDevice(id: device.id, label: device.label),
        )
        .toList(growable: false);
  }

  @override
  Future<void> selectInputDevice(String? deviceId) async {
    _selectedInputDeviceId = deviceId;
  }

  @override
  Stream<double> amplitudeStream() {
    return _instance
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .map((amplitude) => _normalizeAmplitude(amplitude.current))
        .handleError((_) => 0.0);
  }

  @override
  Future<void> start() async {
    final path =
        '${Directory.systemTemp.path}\\dog_translator_${DateTime.now().microsecondsSinceEpoch}.wav';

    final device = await _resolveSelectedDevice();
    await _instance.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        device: device,
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

  Future<InputDevice?> _resolveSelectedDevice() async {
    final selectedId = _selectedInputDeviceId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }

    final devices = await _instance.listInputDevices();
    for (final device in devices) {
      if (device.id == selectedId) {
        return device;
      }
    }

    _selectedInputDeviceId = null;
    return null;
  }

  double _normalizeAmplitude(double current) {
    if (current.isNaN || current.isInfinite) {
      return 0;
    }
    final normalized = (current + 60) / 60;
    return normalized.clamp(0.0, 1.0);
  }
}
