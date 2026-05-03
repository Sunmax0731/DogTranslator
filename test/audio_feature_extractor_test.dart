import 'dart:typed_data';

import 'package:dog_translator/domain/audio_feature_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts audio metrics from WAV bytes', () {
    final extractor = const AudioFeatureExtractor();
    final bytes = _testWave(
      amplitudes: [0.0, 0.8, -0.8, 0.8, -0.8, 0.0, 0.7, -0.7, 0.0],
      sampleRate: 8000,
    );

    final result = extractor.extractFromWavBytes(bytes);

    expect(result.durationSeconds, greaterThan(0));
    expect(result.peak, closeTo(0.8, 0.05));
    expect(result.zeroCrossingRate, greaterThan(0.2));
  });
}

Uint8List _testWave({
  required List<double> amplitudes,
  required int sampleRate,
}) {
  final pcmBytes = BytesBuilder();
  for (final amplitude in amplitudes) {
    final sample = (amplitude * 32767).round();
    pcmBytes.add([sample & 0xFF, (sample >> 8) & 0xFF]);
  }

  final data = pcmBytes.takeBytes();
  final bytes = BytesBuilder();

  void writeAscii(String value) => bytes.add(value.codeUnits);
  void writeUint16(int value) => bytes.add([value & 0xFF, (value >> 8) & 0xFF]);
  void writeUint32(int value) => bytes.add([
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ]);

  writeAscii('RIFF');
  writeUint32(36 + data.length);
  writeAscii('WAVE');
  writeAscii('fmt ');
  writeUint32(16);
  writeUint16(1);
  writeUint16(1);
  writeUint32(sampleRate);
  writeUint32(sampleRate * 2);
  writeUint16(2);
  writeUint16(16);
  writeAscii('data');
  writeUint32(data.length);
  bytes.add(data);

  return bytes.takeBytes();
}
