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
        dynamicRange: 0,
        spectralCentroid: 0,
        highBandRatio: 0,
        crestFactor: 0,
        activityRatio: 0,
        pitchHz: 0,
      );
    }

    final values = List<double>.filled(sampleCount, 0);
    final magnitudes = List<double>.filled(sampleCount, 0);
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
      final magnitude = sample.abs();
      values[i] = sample;
      magnitudes[i] = magnitude;
      peak = max(peak, magnitude);
      sumSquares += sample * sample;
      if (previous != null &&
          ((sample >= 0 && previous < 0) || (sample < 0 && previous >= 0))) {
        zeroCrossings++;
      }
      previous = sample;
    }

    magnitudes.sort();
    final rms = sqrt(sumSquares / sampleCount);
    final durationSeconds = sampleCount / sampleRate;
    final zeroCrossingRate = zeroCrossings / sampleCount;
    final burstCount = _estimateBursts(values, rms);
    final dynamicRange =
        _percentile(magnitudes, 0.95) - _percentile(magnitudes, 0.20);
    final spectrum = _estimateSpectrum(values, sampleRate);
    final activityRatio = _estimateActivityRatio(values, rms);
    final pitchHz = _estimatePitch(values, sampleRate);
    final crestFactor = rms == 0 ? 0.0 : peak / rms;

    return AudioFeatures(
      durationSeconds: durationSeconds,
      rms: rms,
      peak: peak,
      zeroCrossingRate: zeroCrossingRate,
      burstCount: burstCount,
      dynamicRange: dynamicRange,
      spectralCentroid: spectrum.$1,
      highBandRatio: spectrum.$2,
      crestFactor: crestFactor,
      activityRatio: activityRatio,
      pitchHz: pitchHz,
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

  double _estimateActivityRatio(List<double> samples, double rms) {
    if (samples.isEmpty) {
      return 0;
    }

    final threshold = max(0.02, rms * 0.85);
    var active = 0;
    for (final sample in samples) {
      if (sample.abs() >= threshold) {
        active++;
      }
    }
    return active / samples.length;
  }

  double _percentile(List<double> sorted, double ratio) {
    if (sorted.isEmpty) {
      return 0;
    }
    final index = ((sorted.length - 1) * ratio).round().clamp(
      0,
      sorted.length - 1,
    );
    return sorted[index];
  }

  double _estimatePitch(List<double> samples, int sampleRate) {
    final sampleWindow = min(samples.length, 1024);
    if (sampleWindow < 128 || sampleRate <= 0) {
      return 0;
    }

    final offset = (samples.length - sampleWindow) ~/ 2;
    final window = samples.sublist(offset, offset + sampleWindow);
    final minLag = max(1, sampleRate ~/ 1200);
    final maxLag = min(sampleWindow ~/ 2, max(minLag + 1, sampleRate ~/ 80));
    var bestLag = 0;
    var bestScore = 0.0;

    for (var lag = minLag; lag <= maxLag; lag++) {
      var correlation = 0.0;
      for (var i = 0; i < sampleWindow - lag; i++) {
        correlation += window[i] * window[i + lag];
      }
      if (correlation > bestScore) {
        bestScore = correlation;
        bestLag = lag;
      }
    }

    if (bestLag == 0 || bestScore <= 0) {
      return 0;
    }
    return sampleRate / bestLag;
  }

  (double, double) _estimateSpectrum(List<double> samples, int sampleRate) {
    final sampleWindow = min(samples.length, 512);
    if (sampleWindow < 32) {
      return (0, 0);
    }

    final offset = (samples.length - sampleWindow) ~/ 2;
    var weightedFrequency = 0.0;
    var totalEnergy = 0.0;
    var highBandEnergy = 0.0;
    final half = sampleWindow ~/ 2;

    for (var bin = 1; bin < half; bin++) {
      var real = 0.0;
      var imag = 0.0;
      for (var n = 0; n < sampleWindow; n++) {
        final sample = samples[offset + n];
        final angle = (2 * pi * bin * n) / sampleWindow;
        real += sample * cos(angle);
        imag -= sample * sin(angle);
      }
      final energy = sqrt((real * real) + (imag * imag));
      final frequency = (bin * sampleRate) / sampleWindow;
      totalEnergy += energy;
      weightedFrequency += frequency * energy;
      if (frequency > sampleRate / 4) {
        highBandEnergy += energy;
      }
    }

    if (totalEnergy == 0) {
      return (0, 0);
    }
    return (weightedFrequency / totalEnergy, highBandEnergy / totalEnergy);
  }
}
