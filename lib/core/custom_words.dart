/// Custom words a parent adds for one child (feat-018).
///
/// A custom word that is in the bank uses the bank word's id; one that is
/// not gets a `custom:<n>` id, so progress, sessions and the dashboard
/// handle both alike.
library;

const _prefix = 'custom:';

String customWordId(int id) => '$_prefix$id';

int? parseCustomWordId(String wordId) => wordId.startsWith(_prefix)
    ? int.tryParse(wordId.substring(_prefix.length))
    : null;

bool isCustomWordId(String wordId) => parseCustomWordId(wordId) != null;

/// Trimmed, single spaces, lower case, curly apostrophes straightened.
String normalizeWord(String text) => text
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll('’', "'")
    .toLowerCase();

const maxCustomWordLength = 30;
const maxCustomMeaningLength = 120;

final _wordPattern = RegExp(r"^[\p{L}][\p{L} '\-]*$", unicode: true);

/// An error to show for the typed word, or null when it is fine.
String? validateCustomWord(String text) {
  final w = normalizeWord(text);
  if (w.isEmpty) return 'Type the word.';
  if (w.length > maxCustomWordLength) {
    return 'Keep it under $maxCustomWordLength letters.';
  }
  if (!_wordPattern.hasMatch(w)) return 'Letters only, please.';
  return null;
}

/// An error for a meaning or translation, or null.
String? validateCustomMeaning(String text) =>
    text.trim().length > maxCustomMeaningLength
    ? 'Keep it under $maxCustomMeaningLength characters.'
    : null;
