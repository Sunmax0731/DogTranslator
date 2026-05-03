import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interpreter = DogIntentInterpreter();

  test('maps sharp loud bark to warning alert', () async {
    final result = await interpreter.analyze(
      const AudioFeatures(
        durationSeconds: 0.45,
        rms: 0.31,
        peak: 0.9,
        zeroCrossingRate: 0.08,
        burstCount: 2,
        dynamicRange: 0.24,
        spectralCentroid: 2100,
        highBandRatio: 0.42,
      ),
      sceneMode: SceneMode.guest,
    );

    expect(result.intent, DogIntent.warningAlert);
    expect(result.confidence, isNot(ConfidenceLevel.low));
    expect(result.vocalType, isNot(DogVocalType.unknown));
    expect(result.context, DogContext.strangerOrNoise);
  });

  test('maps long soft audio to a calm low-energy candidate set', () async {
    final result = await interpreter.analyze(
      const AudioFeatures(
        durationSeconds: 1.6,
        rms: 0.06,
        peak: 0.23,
        zeroCrossingRate: 0.05,
        burstCount: 1,
        dynamicRange: 0.05,
        spectralCentroid: 600,
        highBandRatio: 0.12,
      ),
    );

    final intents = result.candidates
        .map((candidate) => candidate.intent)
        .toSet();
    expect(
      intents.contains(DogIntent.anxiousWhine) ||
          intents.contains(DogIntent.sleepy) ||
          intents.contains(DogIntent.bored),
      isTrue,
    );
    expect(result.arousal, lessThan(0.65));
  });

  test('reports quality issues for short weak audio', () async {
    final result = await interpreter.analyze(
      const AudioFeatures(
        durationSeconds: 0.12,
        rms: 0.02,
        peak: 0.04,
        zeroCrossingRate: 0.28,
        burstCount: 0,
        dynamicRange: 0.01,
        spectralCentroid: 1200,
        highBandRatio: 0.72,
      ),
    );

    expect(result.intent, DogIntent.uncertain);
    expect(result.qualityIssues, contains(RecordingQualityIssue.tooShort));
    expect(result.qualityIssues, contains(RecordingQualityIssue.lowVolume));
    expect(result.detectedDogVocal, isFalse);
  });
}
