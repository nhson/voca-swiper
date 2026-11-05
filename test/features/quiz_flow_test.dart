import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/features/session/quiz_view.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-012: the quiz round after the swipe cards, as the child sees it.
void main() {
  late AppDatabase db;
  const animals = [
    ('cat', '🐱', 'con mèo'),
    ('dog', '🐶', 'con chó'),
    ('fish', '🐟', 'con cá'),
    ('bird', '🐦', 'con chim'),
    ('frog', '🐸', 'con ếch'),
    ('duck', '🦆', 'con vịt'),
  ];
  setUp(() async {
    db = await seededDb([
      for (final (i, (id, e, vi)) in animals.indexed)
        w(id, rank: i + 1, emoji: e, vi: vi),
    ]);
    await createParent(db);
  });
  tearDown(() => db.close());

  Future<void> swipeAllKnew(WidgetTester t, int kid) async {
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }
  }

  /// Taps and waits out the right/wrong feedback.
  Future<void> pick(WidgetTester t, Finder f) async {
    await t.tap(f);
    await t.pump();
    await t.pump(QuizView.wrongPause);
    await t.pumpAndSettle();
  }

  Finder option(String id) => find.byKey(Key('quiz-option-$id'));

  String quizCount(WidgetTester t) => t
      .widget<Text>(
        find.descendant(
          of: find.byKey(const Key('quiz-count')),
          matching: find.byType(Text),
        ),
      )
      .data!;

  /// Spells [word] by tapping its letter tiles.
  Future<void> spell(WidgetTester t, String word) async {
    final tiles = <int, String>{};
    for (
      var i = 0;
      find.byKey(Key('quiz-tile-$i')).evaluate().isNotEmpty;
      i++
    ) {
      tiles[i] = t
          .widget<Text>(
            find.descendant(
              of: find.byKey(Key('quiz-tile-$i')),
              matching: find.byType(Text),
            ),
          )
          .data!;
    }
    for (final ch in word.split('')) {
      final i = tiles.entries.firstWhere((e) => e.value == ch).key;
      tiles.remove(i);
      await t.tap(find.byKey(Key('quiz-tile-$i')));
      await t.pump();
    }
    await t.pump(QuizView.wrongPause);
    await t.pumpAndSettle();
  }

  testWidgets('ages 4–6: pick the picture; a wrong pick reschedules', (
    t,
  ) async {
    final kid = await createKid(db, age: 6);
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);
    await swipeAllKnew(t, kid);

    expect(find.byKey(const Key('quiz')), findsOneWidget);
    expect(find.text('Quiz time!'), findsOneWidget);
    expect(quizCount(t), '1/5');
    expect(find.byKey(const Key('quiz-kind-pickPicture')), findsOneWidget);
    expect(
      find.byKey(const Key('quiz-word')),
      findsNothing,
      reason: 'young children hear the word, no reading',
    );
    expect(speaker.said.last, 'cat');
    expect(find.byType(GridView), findsOneWidget);
    expect(option('cat'), findsOneWidget);

    // Wrong pick for "cat": the right picture is shown, then the next one.
    final wrong = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('quiz-option-') &&
          w.key != const Key('quiz-option-cat'),
    );
    await t.tap(wrong.first);
    await t.pump();
    expect(speaker.said.last, 'cat', reason: 'hear the right word again');
    await t.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('quiz-mark-right')), findsOneWidget);
    expect(find.byKey(const Key('quiz-mark-wrong')), findsOneWidget);
    await t.pump(QuizView.wrongPause);
    await t.pumpAndSettle();
    expect(quizCount(t), '2/5');

    for (final id in ['dog', 'fish', 'bird', 'frog']) {
      await pick(t, option(id));
    }

    expect(find.byKey(const Key('stars')), findsOneWidget);
    expect(find.text('Quiz: 4 of 5 right'), findsOneWidget);
    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.wrongCount, 1, reason: 'quiz wrong overrides the swipe');
    expect(p['cat']!.correctCount, 0);
    expect(p['dog']!.correctCount, 1);
    final log = await db.select(db.sessionLogs).getSingle();
    expect(log.accuracy, closeTo(4 / 5, 1e-9));
  });

  testWidgets('ages 7+: picture, meaning and spelling', (t) async {
    final kid = await createKid(db, age: 8);
    await pumpApp(t, db);
    await swipeAllKnew(t, kid);

    // 1. cat: picture, with the written word.
    expect(find.byKey(const Key('quiz-kind-pickPicture')), findsOneWidget);
    expect(find.byKey(const Key('quiz-word')), findsOneWidget);
    await pick(t, option('cat'));

    // 2. dog: choose the meaning.
    expect(find.byKey(const Key('quiz-kind-chooseMeaning')), findsOneWidget);
    expect(find.text('con chó'), findsOneWidget);
    await pick(t, find.text('con chó'));

    // 3. fish: spell it — wrongly; the right spelling is shown.
    expect(find.byKey(const Key('quiz-kind-spell')), findsOneWidget);
    expect(find.text('🐟'), findsOneWidget);
    final tilesBefore = <String>[];
    for (
      var i = 0;
      find.byKey(Key('quiz-tile-$i')).evaluate().isNotEmpty;
      i++
    ) {
      tilesBefore.add(i.toString());
    }
    expect(tilesBefore, hasLength(6), reason: '4 letters + 2 extra');
    // Tap the tiles for "f", "i", "h", "s" (wrong order).
    final letters = <int, String>{
      for (var i = 0; i < 6; i++)
        i: t
            .widget<Text>(
              find.descendant(
                of: find.byKey(Key('quiz-tile-$i')),
                matching: find.byType(Text),
              ),
            )
            .data!,
    };
    for (final ch in ['f', 'i', 'h', 's']) {
      final i = letters.entries.firstWhere((e) => e.value == ch).key;
      letters.remove(i);
      await t.tap(find.byKey(Key('quiz-tile-$i')));
      await t.pump();
    }
    expect(find.byKey(const Key('quiz-correct-spelling')), findsOneWidget);
    await t.pump(QuizView.wrongPause);
    await t.pumpAndSettle();

    // 4. bird: picture; 5. frog: meaning.
    await pick(t, option('bird'));
    await pick(t, find.text('con ếch'));

    expect(find.text('Quiz: 4 of 5 right'), findsOneWidget);
    final p = await ProgressRepository(db).schedules(kid);
    expect(p['fish']!.wrongCount, 1);
    expect(p['dog']!.wrongCount, 0);
  });

  testWidgets('a spelled word can be fixed before the last letter', (t) async {
    final kid = await createKid(db, age: 8);
    await pumpApp(t, db);
    await swipeAllKnew(t, kid);
    await pick(t, option('cat'));
    await pick(t, find.text('con chó'));

    // Place one tile, take it back by tapping its slot, then spell right.
    await t.tap(find.byKey(const Key('quiz-tile-0')));
    await t.pump();
    await t.tap(find.byKey(const Key('quiz-slot-0')));
    await t.pump();
    await spell(t, 'fish');
    expect(quizCount(t), '4/5');
  });

  testWidgets('tablet: the quiz fits', (t) async {
    final kid = await createKid(db, age: 6);
    await pumpApp(t, db, size: const Size(1024, 1366));
    await swipeAllKnew(t, kid);
    expect(find.byKey(const Key('quiz')), findsOneWidget);
    expect(t.takeException(), isNull);
    final grid = t.getRect(find.byType(GridView));
    expect(grid.bottom, lessThanOrEqualTo(1366));
  });
}
