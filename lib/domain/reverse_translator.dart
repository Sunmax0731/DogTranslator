import 'package:dog_translator/domain/dog_bark_synthesizer.dart';
import 'package:dog_translator/domain/models.dart';

class ReverseTranslator {
  ReverseTranslator({DogBarkSynthesizer? synthesizer})
    : _synthesizer = synthesizer ?? const DogBarkSynthesizer();

  final DogBarkSynthesizer _synthesizer;

  ReverseTranslationResult translate(
    String input, {
    DogBreed breed = DogBreed.mixed,
    DogAgeStage ageStage = DogAgeStage.adult,
    DogSizeClass sizeClass = DogSizeClass.medium,
    TensionLevel tension = TensionLevel.normal,
  }) {
    final trimmed = input.trim();
    final normalized = trimmed.toLowerCase();
    final style = _detectStyle(normalized);

    return ReverseTranslationResult(
      style: style,
      breed: breed,
      ageStage: ageStage,
      sizeClass: sizeClass,
      tension: tension,
      dogText: _dogTextFor(style, breed, ageStage, sizeClass, tension),
      explanation: _explanationFor(
        style,
        breed,
        ageStage,
        sizeClass,
        tension,
        trimmed.isEmpty,
      ),
      audioBytes: _synthesizer.createWav(
        style,
        breed,
        ageStage: ageStage,
        sizeClass: sizeClass,
        tension: tension,
      ),
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

  String _dogTextFor(
    ReverseEmotionStyle style,
    DogBreed breed,
    DogAgeStage ageStage,
    DogSizeClass sizeClass,
    TensionLevel tension,
  ) {
    final base = switch (style) {
      ReverseEmotionStyle.playful => 'wan! wan! yip-yip!',
      ReverseEmotionStyle.friendly => 'woof... wan wan!',
      ReverseEmotionStyle.requesting => 'wan? wan? kuun...',
      ReverseEmotionStyle.alert => 'woof! woof! grr-ruff!',
      ReverseEmotionStyle.anxious => 'kuuun... wan...',
      ReverseEmotionStyle.neutral => 'wan... woof.',
    };

    final breedFlavor = switch (breed) {
      DogBreed.shiba => '$base kyan!',
      DogBreed.chihuahua => 'kyan! kyan! $base',
      DogBreed.toyPoodle => '$base yap-yap!',
      DogBreed.goldenRetriever => 'bow-wow... $base',
      DogBreed.husky => '$base awooo!',
      DogBreed.mixed => base,
    };

    final ageFlavor = switch (ageStage) {
      DogAgeStage.puppy => 'yip! $breedFlavor',
      DogAgeStage.adult => breedFlavor,
      DogAgeStage.senior => '$breedFlavor ...woof',
    };

    final sizeFlavor = switch (sizeClass) {
      DogSizeClass.small => ageFlavor.replaceAll('woof', 'yap'),
      DogSizeClass.medium => ageFlavor,
      DogSizeClass.large => 'ruff... $ageFlavor',
    };

    return switch (tension) {
      TensionLevel.calm => '$sizeFlavor ...',
      TensionLevel.normal => sizeFlavor,
      TensionLevel.excited => '$sizeFlavor! $sizeFlavor',
    };
  }

  String _explanationFor(
    ReverseEmotionStyle style,
    DogBreed breed,
    DogAgeStage ageStage,
    DogSizeClass sizeClass,
    TensionLevel tension,
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
    final emptyNote = isEmptyInput ? ' 入力が空だったため、もっとも無難な表現に寄せています。' : '';
    return '$styleTextを ${breed.labelJa} / ${ageStage.labelJa} / ${sizeClass.labelJa} / ${tension.labelJa} で表現します。${breed.descriptionJa}$emptyNote';
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
