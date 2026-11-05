import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/custom_words.dart';

void main() {
  test('custom word ids round-trip and never look like bank ids', () {
    expect(customWordId(12), 'custom:12');
    expect(parseCustomWordId('custom:12'), 12);
    expect(parseCustomWordId('cat'), isNull);
    expect(parseCustomWordId('custom:x'), isNull);
    expect(isCustomWordId('custom:3'), isTrue);
    expect(isCustomWordId('custom'), isFalse);
  });

  test(
    'typed words are trimmed, spaces collapsed, lower-cased for matching',
    () {
      expect(normalizeWord('  Ice   Cream '), 'ice cream');
      expect(normalizeWord('DINOSAUR'), 'dinosaur');
      expect(normalizeWord('Don’t'), "don't");
    },
  );

  group('validation', () {
    test('a word is needed, letters only (plus space, hyphen, apostrophe)', () {
      expect(validateCustomWord(''), isNotNull);
      expect(validateCustomWord('   '), isNotNull);
      expect(validateCustomWord('cat2'), isNotNull);
      expect(validateCustomWord('x' * 31), isNotNull);
      expect(validateCustomWord('ice cream'), isNull);
      expect(validateCustomWord("o'clock"), isNull);
      expect(validateCustomWord('t-shirt'), isNull);
      expect(validateCustomWord('Éclair'), isNull);
    });

    test('meaning and translation are short', () {
      expect(validateCustomMeaning('a' * 121), isNotNull);
      expect(validateCustomMeaning('A big animal.'), isNull);
      expect(validateCustomMeaning(''), isNull);
    });
  });
}
