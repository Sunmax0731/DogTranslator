import 'dart:typed_data';

enum ConfidenceLevel { high, medium, low }

enum DogIntent {
  excitedGreeting,
  attentionSeeking,
  warningAlert,
  anxiousWhine,
  restlessEnergy,
  uncertain,
}

extension DogIntentText on DogIntent {
  String get labelJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return 'うれしいあいさつ';
      case DogIntent.attentionSeeking:
        return 'かまってほしい';
      case DogIntent.warningAlert:
        return '警戒して知らせたい';
      case DogIntent.anxiousWhine:
        return '不安・甘え';
      case DogIntent.restlessEnergy:
        return '落ち着かない興奮';
      case DogIntent.uncertain:
        return '判断が難しい';
    }
  }

  String get explanationJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '短く勢いのある鳴きが続き、相手への歓迎や高い興奮が強そうです。';
      case DogIntent.attentionSeeking:
        return '呼びかけるようなリズムで、飼い主に気づいてほしい意図が見えます。';
      case DogIntent.warningAlert:
        return '大きく鋭い音のため、周囲への警戒や注意喚起の可能性があります。';
      case DogIntent.anxiousWhine:
        return '長めで弱い鳴き方が多く、不安や甘えの傾向がありそうです。';
      case DogIntent.restlessEnergy:
        return '落ち着かないエネルギーが続いていて、刺激に反応している可能性があります。';
      case DogIntent.uncertain:
        return '音量や長さの特徴が弱く、今回の録音だけでは意図の特定が難しいです。';
    }
  }
}

extension ConfidenceLevelText on ConfidenceLevel {
  String get labelJa {
    switch (this) {
      case ConfidenceLevel.high:
        return '高め';
      case ConfidenceLevel.medium:
        return '中くらい';
      case ConfidenceLevel.low:
        return '低め';
    }
  }
}

class AudioFeatures {
  const AudioFeatures({
    required this.durationSeconds,
    required this.rms,
    required this.peak,
    required this.zeroCrossingRate,
    required this.burstCount,
  });

  final double durationSeconds;
  final double rms;
  final double peak;
  final double zeroCrossingRate;
  final int burstCount;
}

class TranslationResult {
  const TranslationResult({
    required this.intent,
    required this.explanation,
    required this.confidence,
    required this.features,
  });

  final DogIntent intent;
  final String explanation;
  final ConfidenceLevel confidence;
  final AudioFeatures features;
}

enum ReverseEmotionStyle {
  playful,
  friendly,
  requesting,
  alert,
  anxious,
  neutral,
}

extension ReverseEmotionStyleText on ReverseEmotionStyle {
  String get labelJa {
    switch (this) {
      case ReverseEmotionStyle.playful:
        return '遊びたい';
      case ReverseEmotionStyle.friendly:
        return '親しみ';
      case ReverseEmotionStyle.requesting:
        return 'お願い';
      case ReverseEmotionStyle.alert:
        return '警戒';
      case ReverseEmotionStyle.anxious:
        return '不安';
      case ReverseEmotionStyle.neutral:
        return 'ニュートラル';
    }
  }
}

class ReverseTranslationResult {
  const ReverseTranslationResult({
    required this.style,
    required this.dogText,
    required this.explanation,
    required this.audioBytes,
  });

  final ReverseEmotionStyle style;
  final String dogText;
  final String explanation;
  final Uint8List audioBytes;
}

enum InteractionMode { forward, reverse }

class HistoryEntry {
  const HistoryEntry({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final InteractionMode mode;
  final String title;
  final String subtitle;
  final DateTime timestamp;
}
