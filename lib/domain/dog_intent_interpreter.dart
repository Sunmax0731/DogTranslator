import 'package:dog_translator/domain/models.dart';

class DogIntentInterpreter {
  const DogIntentInterpreter();

  TranslationResult interpret(AudioFeatures features) {
    if (features.durationSeconds < 0.2 || features.peak < 0.03) {
      return _result(DogIntent.uncertain, ConfidenceLevel.low, features);
    }

    if (features.durationSeconds > 1.4 &&
        features.rms < 0.045 &&
        features.peak < 0.16) {
      return _result(DogIntent.sleepy, ConfidenceLevel.medium, features);
    }

    if (features.peak > 0.82 &&
        features.rms > 0.22 &&
        features.durationSeconds < 0.9) {
      return _result(DogIntent.warningAlert, ConfidenceLevel.high, features);
    }

    if (features.burstCount >= 4 &&
        features.rms > 0.12 &&
        features.durationSeconds < 1.4) {
      return _result(DogIntent.excitedGreeting, ConfidenceLevel.high, features);
    }

    if (features.durationSeconds >= 1.0 &&
        features.rms < 0.11 &&
        features.zeroCrossingRate > 0.03) {
      return _result(DogIntent.anxiousWhine, ConfidenceLevel.medium, features);
    }

    if (features.burstCount >= 2 &&
        features.durationSeconds >= 0.35 &&
        features.durationSeconds <= 1.6) {
      return _result(
        DogIntent.attentionSeeking,
        ConfidenceLevel.medium,
        features,
      );
    }

    if (features.rms > 0.16 && features.durationSeconds > 0.8) {
      return _result(
        DogIntent.restlessEnergy,
        ConfidenceLevel.medium,
        features,
      );
    }

    return _result(DogIntent.uncertain, ConfidenceLevel.low, features);
  }

  TranslationResult _result(
    DogIntent intent,
    ConfidenceLevel confidence,
    AudioFeatures features,
  ) {
    return TranslationResult(
      intent: intent,
      explanation: intent.explanationJa,
      confidence: confidence,
      features: features,
    );
  }
}
