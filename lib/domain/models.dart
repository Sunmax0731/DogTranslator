import 'dart:typed_data';

enum ConfidenceLevel { high, medium, low }

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

enum DogIntent {
  excitedGreeting,
  attentionSeeking,
  warningAlert,
  anxiousWhine,
  sleepy,
  restlessEnergy,
  uncertain,
}

extension DogIntentText on DogIntent {
  String get labelJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '遊びたい';
      case DogIntent.attentionSeeking:
        return 'かまってほしい';
      case DogIntent.warningAlert:
        return '警戒している';
      case DogIntent.anxiousWhine:
        return 'さみしい / 甘えたい';
      case DogIntent.sleepy:
        return 'ねむたい';
      case DogIntent.restlessEnergy:
        return 'そわそわしている';
      case DogIntent.uncertain:
        return '判断が難しい';
    }
  }

  String get explanationJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '短く勢いのある鳴き方が続いていて、遊びや歓迎の気分が強そうです。';
      case DogIntent.attentionSeeking:
        return '呼びかけるようなリズムがあり、こちらに気づいてほしい様子です。';
      case DogIntent.warningAlert:
        return '音量が大きく鋭い鳴き方で、警戒や威嚇を示している可能性があります。';
      case DogIntent.anxiousWhine:
        return '長めで弱い鳴き方が多く、不安や甘えの傾向がありそうです。';
      case DogIntent.sleepy:
        return '穏やかで弱い音が続いていて、眠そうな気分に見えます。';
      case DogIntent.restlessEnergy:
        return '勢いはあるものの落ち着かない様子で、そわそわした反応に近そうです。';
      case DogIntent.uncertain:
        return '音量や長さの特徴が弱く、今回の録音だけでは意図の特定が難しいです。';
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

enum DogBreed { mixed, shiba, chihuahua, toyPoodle, goldenRetriever, husky }

extension DogBreedText on DogBreed {
  String get labelJa {
    switch (this) {
      case DogBreed.mixed:
        return 'ミックス';
      case DogBreed.shiba:
        return '柴犬';
      case DogBreed.chihuahua:
        return 'チワワ';
      case DogBreed.toyPoodle:
        return 'トイプードル';
      case DogBreed.goldenRetriever:
        return 'ゴールデンレトリバー';
      case DogBreed.husky:
        return 'ハスキー';
    }
  }

  String get descriptionJa {
    switch (this) {
      case DogBreed.mixed:
        return '標準的な犬声に近い、汎用プリセットです。';
      case DogBreed.shiba:
        return '日本犬らしい引き締まった鳴き方を意識したプリセットです。';
      case DogBreed.chihuahua:
        return '高めで軽い鳴き方を強めに寄せた小型犬プリセットです。';
      case DogBreed.toyPoodle:
        return '明るく細かな声色を意識したプリセットです。';
      case DogBreed.goldenRetriever:
        return 'やわらかく豊かな鳴き方に寄せた大型犬プリセットです。';
      case DogBreed.husky:
        return '遠吠え寄りの響きを少し加えたプリセットです。';
    }
  }
}

class ReverseTranslationResult {
  const ReverseTranslationResult({
    required this.style,
    required this.breed,
    required this.dogText,
    required this.explanation,
    required this.audioBytes,
  });

  final ReverseEmotionStyle style;
  final DogBreed breed;
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

class RecordingInputDevice {
  const RecordingInputDevice({required this.id, required this.label});

  final String id;
  final String label;
}
