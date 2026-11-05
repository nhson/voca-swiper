import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/themes.dart';

void main() {
  test('offers kid-friendly themes with enough words, in appeal order', () {
    final choices = themeChoices({
      'animals': 40,
      'food': 60,
      'space': 3, // too few
      'actions': 100, // not a theme a child picks
      'sports': 8,
    });
    expect(choices.map((t) => t.id), ['animals', 'food', 'sports']);
    expect(choices[1].label, 'Food');
    expect(choices.first.emoji, isNotEmpty);
  });

  test('at most maxChoices are offered', () {
    final counts = {for (final t in favouriteThemes) t.id: 20};
    expect(themeChoices(counts), hasLength(themeChoiceLimit));
  });

  test('every theme has a label and a single, older emoji', () {
    for (final t in favouriteThemes) {
      expect(t.label, isNotEmpty);
      expect(t.emoji.contains('‍'), isFalse, reason: t.id);
    }
    expect(
      favouriteThemes.map((t) => t.id).toSet(),
      hasLength(favouriteThemes.length),
    );
  });
}
