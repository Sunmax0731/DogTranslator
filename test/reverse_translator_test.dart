import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/domain/reverse_translator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final translator = ReverseTranslator();

  test('detects requesting tone from Japanese text', () {
    final result = translator.translate('こっちに来て');

    expect(result.style, ReverseEmotionStyle.requesting);
    expect(result.dogText, contains('wan?'));
    expect(result.audioBytes.length, greaterThan(44));
  });

  test('applies breed and age flavor', () {
    final result = translator.translate(
      '遊ぼう',
      breed: DogBreed.husky,
      ageStage: DogAgeStage.puppy,
      sizeClass: DogSizeClass.large,
      tension: TensionLevel.excited,
    );

    expect(result.style, ReverseEmotionStyle.playful);
    expect(result.breed, DogBreed.husky);
    expect(result.dogText, contains('awooo!'));
    expect(result.explanation, contains('ハスキー'));
    expect(result.explanation, contains('子犬'));
  });

  test('falls back to neutral for empty text', () {
    final result = translator.translate('');

    expect(result.style, ReverseEmotionStyle.neutral);
    expect(result.explanation, contains('入力が空'));
  });
}
