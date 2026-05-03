import 'package:dog_translator/domain/dog_bark_synthesizer.dart';
import 'package:dog_translator/domain/models.dart';

class ReverseTranslator {
  ReverseTranslator({DogBarkSynthesizer? synthesizer})
    : _synthesizer = synthesizer ?? const DogBarkSynthesizer();

  final DogBarkSynthesizer _synthesizer;

  ReverseTranslationResult translate(
    String input, {
    DogBreed breed = DogBreed.mixed,
  }) {
    final trimmed = input.trim();
    final normalized = trimmed.toLowerCase();
    final style = _detectStyle(normalized);

    return ReverseTranslationResult(
      style: style,
      breed: breed,
      dogText: _dogTextFor(style, breed),
      explanation: _explanationFor(style, breed, trimmed.isEmpty),
      audioBytes: _synthesizer.createWav(style, breed),
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

  String _dogTextFor(ReverseEmotionStyle style, DogBreed breed) {
    final base = switch (style) {
      ReverseEmotionStyle.playful => 'wan! wan! yip-yip!',
      ReverseEmotionStyle.friendly => 'woof... wan wan!',
      ReverseEmotionStyle.requesting => 'wan? wan? kuun...',
      ReverseEmotionStyle.alert => 'woof! woof! grr-ruff!',
      ReverseEmotionStyle.anxious => 'kuuun... wan...',
      ReverseEmotionStyle.neutral => 'wan... woof.',
    };

    return switch (breed) {
      DogBreed.shiba => '$base kyan!',
      DogBreed.chihuahua => 'kyan! kyan! $base',
      DogBreed.toyPoodle => '$base yap-yap!',
      DogBreed.goldenRetriever => 'bow-wow... $base',
      DogBreed.husky => '$base awooo!',
      DogBreed.mixed => base,
    };
  }

  String _explanationFor(
    ReverseEmotionStyle style,
    DogBreed breed,
    bool isEmptyInput,
  ) {
    final styleText = switch (style) {
      ReverseEmotionStyle.playful => '遊びに誘う雰囲気',
      ReverseEmotionStyle.friendly => '親しみのある雰囲気',
      ReverseEmotionStyle.requesting => 'お願いを伝える雰囲気',
      ReverseEmotionStyle.alert => '警戒して知らせる雰囲気',
      ReverseEmotionStyle.anxious => '不安や甘えが混じる雰囲気',
      ReverseEmotionStyle.neutral => '中立的で軽い雰囲気',
    };

    final emptyNote = isEmptyInput ? ' 入力が空だったため、いちばん無難な表現に寄せています。' : '';
    return '$styleTextを ${breed.labelJa} プリセットで表現します。${breed.descriptionJa}$emptyNote';
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
