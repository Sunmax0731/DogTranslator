import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/local_inference_runtime.dart';
import 'package:dog_translator/services/local_process_inference_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps local process json output into translation result', () async {
    final provider = LocalProcessInferenceProvider(
      config: const LocalInferenceRuntimeConfig(
        enabled: true,
        command: 'python',
        arguments: <String>['app/infer.py'],
        timeout: Duration(seconds: 3),
      ),
      executor: (executable, arguments, {workingDirectory}) async {
        return ProcessResult(
          1,
          0,
          jsonEncode({
            'detected': true,
            'vocal_type': 'bark',
            'emotion': {'top': 'alert', 'score': 0.74},
            'context': {'top': 'stranger_or_noise', 'score': 0.62},
            'valence': -0.22,
            'arousal': 0.81,
            'confidence': 0.68,
            'message': '来客や物音に反応して警戒している可能性があります。',
          }),
          '',
        );
      },
    );

    final result = await provider.analyze(
      const AudioFeatures(
        durationSeconds: 0.8,
        rms: 0.2,
        peak: 0.7,
        zeroCrossingRate: 0.09,
        burstCount: 2,
        dynamicRange: 0.14,
        spectralCentroid: 1200,
        highBandRatio: 0.25,
      ),
      wavBytes: Uint8List.fromList(List<int>.filled(100, 1)),
    );

    expect(result.providerLabel, 'dog2vec-local');
    expect(result.intent, DogIntent.warningAlert);
    expect(result.vocalType, DogVocalType.bark);
    expect(result.context, DogContext.strangerOrNoise);
    expect(result.arousal, closeTo(0.81, 0.001));
  });
}
