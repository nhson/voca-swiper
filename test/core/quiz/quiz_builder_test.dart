import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

/// feat-012: the active-recall round after the swipe cards
/// (docs/SPEC.md — Session flow step 4).
void main() {
  const builder = QuizBuilder();

  QuizWord q(String id, {String? emoji, String? meaning}) =>
      QuizWord(id: id, word: id, emoji: emoji, meaning: meaning);

  // A bank to draw wrong options from: every word has a picture and meaning.
  final pool = [
    for (final (id, e, m) in [
      ('cat', '🐱', 'con mèo'),
      ('dog', '🐶', 'con chó'),
      ('fish', '🐟', 'con cá'),
      ('bird', '🐦', 'con chim'),
      ('apple', '🍎', 'quả táo'),
      ('sun', '☀️', 'mặt trời'),
      ('car', '🚗', 'xe hơi'),
      ('ball', '⚽', 'quả bóng'),
    ])
      q(id, emoji: e, meaning: m),
  ];
  QuizWord p(String id) => pool.firstWhere((x) => x.id == id);

  List<QuizItem> build(
    List<QuizWord> today,
    Map<String, AnswerQuality> swipes, {
    int age = 6,
    List<QuizWord>? from,
    int seed = 1,
  }) => builder.build(
    today: today,
    swipes: swipes,
    pool: from ?? pool,
    age: age,
    random: Random(seed),
  );

  Map<String, AnswerQuality> knew(Iterable<String> ids) => {
    for (final id in ids) id: AnswerQuality.knew,
  };

  group('which words', () {
    test('words swiped knew or almost; not the ones the child missed', () {
      final items = build(
        [p('cat'), p('dog'), p('fish')],
        {
          'cat': AnswerQuality.knew,
          'dog': AnswerQuality.didntKnow,
          'fish': AnswerQuality.almost,
        },
      );
      expect(items.map((i) => i.wordId), ['cat', 'fish']);
    });

    test('at most 5 questions', () {
      final today = pool.take(7).toList();
      final items = build(today, knew(today.map((w) => w.id)));
      expect(items, hasLength(QuizBuilder.maxItems));
    });

    test('nothing swiped → no quiz', () {
      expect(build([p('cat')], const {}), isEmpty);
    });
  });

  group('ages 4–6: pick the picture (no reading)', () {
    test('every question is pick-the-picture', () {
      final today = [p('cat'), p('dog'), p('fish')];
      final items = build(today, knew(['cat', 'dog', 'fish']));
      expect(items.map((i) => i.kind).toSet(), {QuizKind.pickPicture});
    });

    test('four different pictures, the answer among them', () {
      final item = build([p('cat')], knew(['cat'])).single;
      expect(item.options, hasLength(4));
      expect(item.options, contains('cat'));
      expect(item.options.toSet(), hasLength(4));
      final emojis = [
        for (final id in item.options) pool.firstWhere((w) => w.id == id).emoji,
      ];
      expect(emojis.toSet(), hasLength(4));
    });

    test('a word without a picture is skipped', () {
      final items = build([
        q('the', meaning: 'cái'),
        p('cat'),
      ], knew(['the', 'cat']));
      expect(items.map((i) => i.wordId), ['cat']);
    });

    test('too few pictures for wrong options → skipped', () {
      final small = [p('cat'), p('dog')];
      expect(build(small, knew(['cat']), from: small), isEmpty);
    });
  });

  group('ages 7+: picture, meaning and spelling take turns', () {
    test('kinds rotate', () {
      final today = [p('cat'), p('dog'), p('fish'), p('bird')];
      final items = build(today, knew(today.map((w) => w.id)), age: 8);
      expect(items.map((i) => i.kind), [
        QuizKind.pickPicture,
        QuizKind.chooseMeaning,
        QuizKind.spell,
        QuizKind.pickPicture,
      ]);
    });

    test('a kind that does not fit the word falls to the next one', () {
      // No picture → meaning; "elephant" is too long to spell → picture.
      final today = [
        q('the', meaning: 'cái'),
        q('elephant', emoji: '🐘', meaning: 'con voi'),
      ];
      final items = build(
        [today[0], p('cat'), today[1]],
        knew(['the', 'cat', 'elephant']),
        age: 8,
        from: [...pool, ...today],
      );
      expect(items.map((i) => (i.wordId, i.kind)), [
        ('the', QuizKind.chooseMeaning),
        ('cat', QuizKind.chooseMeaning),
        ('elephant', QuizKind.pickPicture),
      ]);
    });

    test('meaning options are four different meanings', () {
      final item = build([p('dog'), p('cat')], knew(['dog', 'cat']), age: 8)[1];
      expect(item.kind, QuizKind.chooseMeaning);
      final meanings = [
        for (final id in item.options)
          pool.firstWhere((w) => w.id == id).meaning,
      ];
      expect(meanings.toSet(), hasLength(4));
      expect(item.options, contains('cat'));
    });

    test('spelling tiles: the word letters plus two extra', () {
      final item = build(
        [p('dog'), p('cat'), p('fish')],
        knew(['dog', 'cat', 'fish']),
        age: 8,
      )[2];
      expect(item.kind, QuizKind.spell);
      expect(item.tiles, hasLength('fish'.length + QuizBuilder.extraTiles));
      final left = List.of(item.tiles);
      for (final ch in 'fish'.split('')) {
        expect(left.remove(ch), isTrue, reason: 'tile for "$ch"');
      }
    });
  });

  test('same seed → same quiz', () {
    final today = [p('cat'), p('dog'), p('fish')];
    final a = build(today, knew(['cat', 'dog', 'fish']), age: 8, seed: 3);
    final b = build(today, knew(['cat', 'dog', 'fish']), age: 8, seed: 3);
    expect(
      a.map((i) => [i.options, i.tiles]).toList(),
      b.map((i) => [i.options, i.tiles]).toList(),
    );
  });

  group('checking an answer', () {
    test('picture / meaning: the chosen word id', () {
      final item = build([p('cat')], knew(['cat'])).single;
      expect(item.isCorrect('cat'), isTrue);
      expect(
        item.isCorrect(item.options.firstWhere((o) => o != 'cat')),
        isFalse,
      );
    });

    test('spelling: the letters typed, case-insensitive', () {
      final item = build(
        [p('dog'), p('cat'), p('fish')],
        knew(['dog', 'cat', 'fish']),
        age: 8,
      )[2];
      expect(item.isCorrect('fish'), isTrue);
      expect(item.isCorrect('FISH'), isTrue);
      expect(item.isCorrect('fihs'), isFalse);
    });
  });
}
