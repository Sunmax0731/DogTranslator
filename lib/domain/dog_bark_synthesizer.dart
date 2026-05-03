import 'dart:math';
import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';

class DogBarkSynthesizer {
  const DogBarkSynthesizer();

  Uint8List createWav(ReverseEmotionStyle style, DogBreed breed) {
    final profile = _profileFor(breed);
    final bursts = _burstsFor(style, profile);
    final sampleRate = profile.sampleRate;
    final samples = <int>[];
    final random = Random(profile.seed);

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
        final value = (tone * profile.toneMix) + (noise * profile.noiseMix);
        samples.add((value * envelope * 32767).round().clamp(-32768, 32767));
      }

      final pause = (sampleRate * profile.pauseSeconds).round();
      for (var i = 0; i < pause; i++) {
        samples.add(0);
      }
    }

    return _buildWav(samples, sampleRate);
  }

  _BreedProfile _profileFor(DogBreed breed) {
    switch (breed) {
      case DogBreed.shiba:
        return const _BreedProfile(
          seed: 11,
          sampleRate: 16000,
          pitchScale: 1.05,
          durationScale: 0.9,
          amplitudeScale: 0.9,
          toneMix: 0.76,
          noiseMix: 0.24,
          pauseSeconds: 0.05,
        );
      case DogBreed.chihuahua:
        return const _BreedProfile(
          seed: 17,
          sampleRate: 18000,
          pitchScale: 1.35,
          durationScale: 0.72,
          amplitudeScale: 0.65,
          toneMix: 0.72,
          noiseMix: 0.28,
          pauseSeconds: 0.045,
        );
      case DogBreed.toyPoodle:
        return const _BreedProfile(
          seed: 23,
          sampleRate: 17000,
          pitchScale: 1.18,
          durationScale: 0.88,
          amplitudeScale: 0.74,
          toneMix: 0.75,
          noiseMix: 0.25,
          pauseSeconds: 0.05,
        );
      case DogBreed.goldenRetriever:
        return const _BreedProfile(
          seed: 29,
          sampleRate: 16000,
          pitchScale: 0.82,
          durationScale: 1.18,
          amplitudeScale: 0.95,
          toneMix: 0.8,
          noiseMix: 0.2,
          pauseSeconds: 0.06,
        );
      case DogBreed.husky:
        return const _BreedProfile(
          seed: 37,
          sampleRate: 18000,
          pitchScale: 0.94,
          durationScale: 1.3,
          amplitudeScale: 0.88,
          toneMix: 0.83,
          noiseMix: 0.17,
          pauseSeconds: 0.07,
        );
      case DogBreed.mixed:
        return const _BreedProfile(
          seed: 73,
          sampleRate: 16000,
          pitchScale: 1.0,
          durationScale: 1.0,
          amplitudeScale: 1.0,
          toneMix: 0.78,
          noiseMix: 0.22,
          pauseSeconds: 0.055,
        );
    }
  }

  List<_Burst> _burstsFor(ReverseEmotionStyle style, _BreedProfile profile) {
    final base = switch (style) {
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

    return base
        .map(
          (burst) => _Burst(
            burst.startFrequency * profile.pitchScale,
            burst.endFrequency * profile.pitchScale,
            burst.durationSeconds * profile.durationScale,
            burst.amplitude * profile.amplitudeScale,
          ),
        )
        .toList(growable: false);
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

class _BreedProfile {
  const _BreedProfile({
    required this.seed,
    required this.sampleRate,
    required this.pitchScale,
    required this.durationScale,
    required this.amplitudeScale,
    required this.toneMix,
    required this.noiseMix,
    required this.pauseSeconds,
  });

  final int seed;
  final int sampleRate;
  final double pitchScale;
  final double durationScale;
  final double amplitudeScale;
  final double toneMix;
  final double noiseMix;
  final double pauseSeconds;
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
