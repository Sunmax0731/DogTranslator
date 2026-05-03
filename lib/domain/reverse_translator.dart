import 'package:dog_translator/domain/dog_bark_synthesizer.dart';
import 'package:dog_translator/domain/models.dart';

class ReverseTranslator {
  ReverseTranslator({DogBarkSynthesizer? synthesizer})
    : _synthesizer = synthesizer ?? const DogBarkSynthesizer();

  final DogBarkSynthesizer _synthesizer;

  ReverseTranslationResult translate(String input) {
    final trimmed = input.trim();
    final normalized = trimmed.toLowerCase();
    final style = _detectStyle(normalized);

    final dogText = switch (style) {
      ReverseEmotionStyle.playful => 'wan! wan! yip-yip!',
      ReverseEmotionStyle.friendly => 'woof... wan wan!',
      ReverseEmotionStyle.requesting => 'wan? wan? kuun...',
      ReverseEmotionStyle.alert => 'woof! woof! grr-ruff!',
      ReverseEmotionStyle.anxious => 'kuuun... wan...',
      ReverseEmotionStyle.neutral => 'wan... woof.',
    };

    final explanation = switch (style) {
      ReverseEmotionStyle.playful => '遊びに誘う雰囲気の犬語表現です。',
      ReverseEmotionStyle.friendly => '親しみや安心感を出す犬語表現です。',
      ReverseEmotionStyle.requesting => '相手に何かを求める雰囲気の犬語表現です。',
      ReverseEmotionStyle.alert => '相手に気づいてほしい警戒寄りの犬語表現です。',
      ReverseEmotionStyle.anxious => '不安や甘えをにじませる犬語表現です。',
      ReverseEmotionStyle.neutral => '中立的で軽い犬語表現です。',
    };

    return ReverseTranslationResult(
      style: style,
      dogText: dogText,
      explanation: trimmed.isEmpty
          ? '$explanation 入力が空だったため中立表現を使いました。'
          : explanation,
      audioBytes: _synthesizer.createWav(style),
    );
  }

  ReverseEmotionStyle _detectStyle(String normalized) {
    if (normalized.isEmpty) {
      return ReverseEmotionStyle.neutral;
    }

    const playfulKeywords = ['遊ぼ', 'play', 'fun', 'いこう', 'run'];
    const friendlyKeywords = ['好き', 'hello', 'hi', 'ありがとう', 'friend'];
    const requestingKeywords = ['来て', 'please', 'ちょうだい', 'want', 'help'];
    const alertKeywords = ['危険', 'danger', 'stop', 'だめ', 'watch'];
    const anxiousKeywords = ['寂しい', 'sad', 'こわい', '不安', 'miss you'];

    if (_containsAny(normalized, alertKeywords)) {
      return ReverseEmotionStyle.alert;
    }
    if (_containsAny(normalized, anxiousKeywords)) {
      return ReverseEmotionStyle.anxious;
    }
    if (_containsAny(normalized, requestingKeywords)) {
      return ReverseEmotionStyle.requesting;
    }
    if (_containsAny(normalized, playfulKeywords)) {
      return ReverseEmotionStyle.playful;
    }
    if (_containsAny(normalized, friendlyKeywords)) {
      return ReverseEmotionStyle.friendly;
    }
    return ReverseEmotionStyle.neutral;
  }

  bool _containsAny(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
