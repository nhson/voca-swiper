import 'dart:math';

import '../srs/word_state.dart';

/// The kinds of active-recall question (docs/SPEC.md — Session flow step 4).
enum QuizKind {
  /// Hear the word, pick its picture from four. Needs no reading.
  pickPicture,

  /// See the word, pick its meaning (native language) from four.
  chooseMeaning,

  /// See the picture, hear the word, spell it with letter tiles.
  spell,
}

/// What the quiz needs to know about a word.
class QuizWord {
  const QuizWord({
    required this.id,
    required this.word,
    this.emoji,
    this.meaning,
  });

  final String id;
  final String word;
  final String? emoji;

  /// Translation in the child's native language, if there is one.
  final String? meaning;
}

/// One question about [wordId].
class QuizItem {
  const QuizItem({
    required this.wordId,
    required this.kind,
    this.options = const [],
    this.tiles = const [],
    this.answer = '',
  });

  final String wordId;
  final QuizKind kind;

  /// Word ids to choose from, shuffled, the answer among them
  /// ([QuizKind.pickPicture], [QuizKind.chooseMeaning]).
  final List<String> options;

  /// Shuffled letter tiles: the word's letters plus a few extra
  /// ([QuizKind.spell]).
  final List<String> tiles;

  /// The word to spell ([QuizKind.spell]).
  final String answer;

  /// [given] is a chosen word id, or the spelled letters for [QuizKind.spell].
  bool isCorrect(String given) => kind == QuizKind.spell
      ? given.toLowerCase() == answer.toLowerCase()
      : given == wordId;
}

/// Builds the short quiz that follows the swipe cards.
///
/// - Asks about words the child swiped "knew it" or "almost" (the swipe is
///   the child's own word; the quiz checks it). Missed words are skipped:
///   they are already scheduled as misses.
/// - Up to [maxItems] questions, in session order.
/// - Ages 4–6 only get pick-the-picture. Ages 7+ take turns: picture,
///   meaning, spelling; a kind that does not fit a word (no picture, no
///   translation, too long to spell) passes to the next kind.
/// - Wrong options come from [pool]: different words with a different
///   picture / meaning, so there is exactly one right answer.
class QuizBuilder {
  const QuizBuilder();

  static const int maxItems = 5;
  static const int optionCount = 4;
  static const int extraTiles = 2;
  static final _spellable = RegExp(r'^[a-z]{3,6}$');
  static const _letters = 'abcdefghijklmnopqrstuvwxyz';

  List<QuizItem> build({
    required List<QuizWord> today,
    required Map<String, AnswerQuality> swipes,
    required List<QuizWord> pool,
    required int age,
    required Random random,
    int maxItems = QuizBuilder.maxItems,
  }) {
    final kinds = age <= 6
        ? const [QuizKind.pickPicture]
        : const [QuizKind.pickPicture, QuizKind.chooseMeaning, QuizKind.spell];
    final items = <QuizItem>[];
    final asked = <String>{};
    for (final w in today) {
      if (items.length >= maxItems) break;
      final swipe = swipes[w.id];
      if (swipe != AnswerQuality.knew && swipe != AnswerQuality.almost) {
        continue;
      }
      if (!asked.add(w.id)) continue;
      for (var k = 0; k < kinds.length; k++) {
        final kind = kinds[(items.length + k) % kinds.length];
        final item = _make(kind, w, pool, random);
        if (item != null) {
          items.add(item);
          break;
        }
      }
    }
    return items;
  }

  QuizItem? _make(QuizKind kind, QuizWord w, List<QuizWord> pool, Random r) {
    switch (kind) {
      case QuizKind.pickPicture:
        return _choice(kind, w, pool, r, (x) => x.emoji);
      case QuizKind.chooseMeaning:
        return _choice(kind, w, pool, r, (x) => x.meaning);
      case QuizKind.spell:
        final word = w.word.toLowerCase();
        if (!_spellable.hasMatch(word)) return null;
        final tiles = [
          ...word.split(''),
          for (var i = 0; i < extraTiles; i++) _letters[r.nextInt(26)],
        ]..shuffle(r);
        return QuizItem(wordId: w.id, kind: kind, tiles: tiles, answer: word);
    }
  }

  /// Four options that differ in [face] (picture or meaning).
  QuizItem? _choice(
    QuizKind kind,
    QuizWord w,
    List<QuizWord> pool,
    Random r,
    String? Function(QuizWord) face,
  ) {
    final own = face(w);
    if (own == null) return null;
    final faces = {own};
    final others = [
      for (final x in pool)
        if (x.id != w.id && x.word != w.word && face(x) != null) x,
    ]..shuffle(r);
    final picked = <String>[];
    for (final x in others) {
      if (picked.length == optionCount - 1) break;
      if (faces.add(face(x)!)) picked.add(x.id);
    }
    if (picked.length < optionCount - 1) return null;
    return QuizItem(
      wordId: w.id,
      kind: kind,
      options: [w.id, ...picked]..shuffle(r),
    );
  }
}
