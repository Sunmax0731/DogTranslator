import 'dart:math';
import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';

class AudioFeatureExtractor {
  const AudioFeatureExtractor();

  AudioFeatures extractFromWavBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    if (bytes.length < 44) {
      throw const FormatException('WAV data is too short.');
    }

    final channels = byteData.getUint16(22, Endian.little);
    final sampleRate = byteData.getUint32(24, Endian.little);
    final bitsPerSample = byteData.getUint16(34, Endian.little);
    final dataOffset = _findChunk(bytes, 'data');
    if (dataOffset < 0) {
      throw const FormatException('WAV data chunk was not found.');
    }
    if (bitsPerSample != 16) {
      throw FormatException('Unsupported bits per sample: $bitsPerSample');
    }

    final dataLength = byteData.getUint32(dataOffset + 4, Endian.little);
    final sampleStart = dataOffset + 8;
    final bytesPerFrame = (bitsPerSample ~/ 8) * channels;
    final sampleCount = dataLength ~/ bytesPerFrame;
    if (sampleCount <= 1) {
      return const AudioFeatures(
        durationSeconds: 0,
        rms: 0,
        peak: 0,
        zeroCrossingRate: 0,
        burstCount: 0,
      );
    }

    final values = List<double>.filled(sampleCount, 0);
    var peak = 0.0;
    var sumSquares = 0.0;
    var zeroCrossings = 0;
    double? previous;

    for (var i = 0; i < sampleCount; i++) {
      final frameOffset = sampleStart + (i * bytesPerFrame);
      var mix = 0.0;
      for (var channel = 0; channel < channels; channel++) {
        final raw = byteData.getInt16(
          frameOffset + (channel * 2),
          Endian.little,
        );
        mix += raw / 32768.0;
      }
      final sample = mix / channels;
      values[i] = sample;
      peak = max(peak, sample.abs());
      sumSquares += sample * sample;
      if (previous != null &&
          ((sample >= 0 && previous < 0) || (sample < 0 && previous >= 0))) {
        zeroCrossings++;
      }
      previous = sample;
    }

    final rms = sqrt(sumSquares / sampleCount);
    final durationSeconds = sampleCount / sampleRate;
    final zeroCrossingRate = zeroCrossings / sampleCount;
    final burstCount = _estimateBursts(values, rms);

    return AudioFeatures(
      durationSeconds: durationSeconds,
      rms: rms,
      peak: peak,
      zeroCrossingRate: zeroCrossingRate,
      burstCount: burstCount,
    );
  }

  int _findChunk(Uint8List bytes, String chunkId) {
    final pattern = chunkId.codeUnits;
    for (var i = 0; i <= bytes.length - 4; i++) {
      if (bytes[i] == pattern[0] &&
          bytes[i + 1] == pattern[1] &&
          bytes[i + 2] == pattern[2] &&
          bytes[i + 3] == pattern[3]) {
        return i;
      }
    }
    return -1;
  }

  int _estimateBursts(List<double> samples, double rms) {
    if (samples.isEmpty) {
      return 0;
    }
    final frameSize = max(120, samples.length ~/ 60);
    final threshold = max(0.045, rms * 1.3);
    var bursts = 0;
    var active = false;

    for (var index = 0; index < samples.length; index += frameSize) {
      final end = min(samples.length, index + frameSize);
      var energy = 0.0;
      for (var i = index; i < end; i++) {
        energy += samples[i].abs();
      }
      final frameLevel = energy / (end - index);
      final isActive = frameLevel > threshold;
      if (isActive && !active) {
        bursts++;
      }
      active = isActive;
    }

    return bursts;
  }
}
