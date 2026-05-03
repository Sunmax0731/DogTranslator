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

  test('falls back to neutral for empty text', () {
    final result = translator.translate('');

    expect(result.style, ReverseEmotionStyle.neutral);
    expect(result.explanation, contains('入力が空'));
  });
}
