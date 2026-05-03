import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interpreter = DogIntentInterpreter();

  test('maps sharp loud bark to warning alert', () {
    final result = interpreter.interpret(
      const AudioFeatures(
        durationSeconds: 0.45,
        rms: 0.31,
        peak: 0.9,
        zeroCrossingRate: 0.08,
        burstCount: 2,
      ),
    );

    expect(result.intent, DogIntent.warningAlert);
    expect(result.confidence, ConfidenceLevel.high);
  });

  test('maps long soft audio to anxious whine', () {
    final result = interpreter.interpret(
      const AudioFeatures(
        durationSeconds: 1.6,
        rms: 0.06,
        peak: 0.23,
        zeroCrossingRate: 0.05,
        burstCount: 1,
      ),
    );

    expect(result.intent, DogIntent.anxiousWhine);
  });
}
