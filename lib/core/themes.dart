/// A word-bank theme a child can pick as a favourite (feat-015).
class ThemeInfo {
  const ThemeInfo(this.id, this.label, this.emoji);

  /// Matches the word bank's `themes` values.
  final String id;
  final String label;
  final String emoji;
}

/// Themes a child would pick, most appealing first. Grammar-ish tags (actions, describing,
/// things, time, people, places) are left out: they are not interests.
/// Emoji are Emoji 11 or older, with no ZWJ, so old Android shows them.
const favouriteThemes = [
  ThemeInfo('animals', 'Animals', '🐶'),
  ThemeInfo('food', 'Food', '🍎'),
  ThemeInfo('sports', 'Sports', '⚽'),
  ThemeInfo('toys', 'Toys', '🧸'),
  ThemeInfo('nature', 'Nature', '🌳'),
  ThemeInfo('transport', 'Cars & trains', '🚗'),
  ThemeInfo('space', 'Space', '🚀'),
  ThemeInfo('music', 'Music', '🎵'),
  ThemeInfo('colors', 'Colours', '🎨'),
  ThemeInfo('clothes', 'Clothes', '👕'),
  ThemeInfo('body', 'My body', '✋'),
  ThemeInfo('family', 'Family', '❤️'),
  ThemeInfo('home', 'Home', '🏠'),
  ThemeInfo('school', 'School', '🏫'),
  ThemeInfo('weather', 'Weather', '⛅'),
  ThemeInfo('numbers', 'Numbers', '🔢'),
  ThemeInfo('feelings', 'Feelings', '😊'),
  ThemeInfo('hobbies', 'Hobbies', '🎲'),
  ThemeInfo('jobs', 'Jobs', '💼'),
  ThemeInfo('science', 'Science', '🔬'),
  ThemeInfo('technology', 'Computers', '💻'),
  ThemeInfo('travel', 'Travel', '✈️'),
  ThemeInfo('health', 'Health', '🏥'),
  ThemeInfo('shopping', 'Shopping', '🛒'),
  ThemeInfo('culture', 'Art & culture', '🎭'),
];

/// A theme needs this many words for the child's level and age to be offered.
const themeMinWords = 8;

/// How many themes the picker shows.
const themeChoiceLimit = 12;

/// How many favourites a child picks at most.
const maxFavouriteThemes = 3;

/// The themes to offer, given how many words each has for the child: those
/// with at least [themeMinWords], in [favouriteThemes] order (most appealing
/// to children first, not biggest first), at most [themeChoiceLimit].
List<ThemeInfo> themeChoices(Map<String, int> wordCounts) => [
  for (final t in favouriteThemes)
    if ((wordCounts[t.id] ?? 0) >= themeMinWords) t,
].take(themeChoiceLimit).toList();
