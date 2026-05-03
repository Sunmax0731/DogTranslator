import 'dart:math';
import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';

class DogBarkSynthesizer {
  const DogBarkSynthesizer();

  Uint8List createWav(ReverseEmotionStyle style) {
    final bursts = switch (style) {
      ReverseEmotionStyle.playful => const [
        _Burst(560, 420, 0.18, 0.85),
        _Burst(620, 480, 0.16, 0.8),
        _Burst(540, 390, 0.22, 0.75),
      ],
      ReverseEmotionStyle.friendly => const [
        _Burst(520, 360, 0.2, 0.7),
        _Burst(500, 330, 0.24, 0.65),
      ],
      ReverseEmotionStyle.requesting => const [
        _Burst(430, 300, 0.26, 0.6),
        _Burst(450, 320, 0.3, 0.58),
      ],
      ReverseEmotionStyle.alert => const [
        _Burst(700, 520, 0.14, 0.95),
        _Burst(720, 540, 0.15, 0.92),
        _Burst(680, 500, 0.14, 0.9),
      ],
      ReverseEmotionStyle.anxious => const [
        _Burst(360, 260, 0.34, 0.52),
        _Burst(340, 240, 0.42, 0.48),
      ],
      ReverseEmotionStyle.neutral => const [
        _Burst(500, 360, 0.2, 0.62),
        _Burst(480, 340, 0.18, 0.58),
      ],
    };

    const sampleRate = 16000;
    final samples = <int>[];
    final random = Random(73);

    for (final burst in bursts) {
      final total = (sampleRate * burst.durationSeconds).round();
      for (var i = 0; i < total; i++) {
        final progress = i / total;
        final freq =
            burst.startFrequency +
            ((burst.endFrequency - burst.startFrequency) * progress);
        final envelope =
            sin(pi * progress) * (1.0 - (progress * 0.35)) * burst.amplitude;
        final tone = sin(2 * pi * freq * i / sampleRate);
        final noise = (random.nextDouble() * 2.0) - 1.0;
        final value = (tone * 0.78) + (noise * 0.22);
        samples.add((value * envelope * 32767).round().clamp(-32768, 32767));
      }

      final pause = (sampleRate * 0.055).round();
      for (var i = 0; i < pause; i++) {
        samples.add(0);
      }
    }

    return _buildWav(samples, sampleRate);
  }

  Uint8List _buildWav(List<int> samples, int sampleRate) {
    final dataLength = samples.length * 2;
    final bytes = BytesBuilder();
    void writeAscii(String text) => bytes.add(text.codeUnits);
    void writeUint32(int value) {
      bytes.add([
        value & 0xFF,
        (value >> 8) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 24) & 0xFF,
      ]);
    }

    void writeUint16(int value) {
      bytes.add([value & 0xFF, (value >> 8) & 0xFF]);
    }

    writeAscii('RIFF');
    writeUint32(36 + dataLength);
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
    writeUint32(dataLength);

    for (final sample in samples) {
      writeUint16(sample & 0xFFFF);
    }

    return bytes.takeBytes();
  }
}

class _Burst {
  const _Burst(
    this.startFrequency,
    this.endFrequency,
    this.durationSeconds,
    this.amplitude,
  );

  final double startFrequency;
  final double endFrequency;
  final double durationSeconds;
  final double amplitude;
}
