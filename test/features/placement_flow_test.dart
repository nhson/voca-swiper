import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/features/session/quiz_view.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-015: a new child's onboarding, as the child and parent see it.
void main() {
  late AppDatabase db;
  // 30 Pre-A1 + 30 A1 words, each with its own picture. A third of the words
  // are animals, a third food.
  setUp(() async {
    db = await seededDb([
      for (final level in ['preA1', 'A1'])
        for (var i = 1; i <= 30; i++)
          w(
            '${level == 'preA1' ? 'p' : 'a'}$i',
            cefr: level,
            rank: i,
            emoji: '$level-pic-$i',
            themes: [
              if (i % 3 == 0) 'animals',
              if (i % 3 == 1) 'food',
              'things',
            ],
          ),
    ]);
    await createParent(db);
  });
  tearDown(() => db.close());

  String shownWord(WidgetTester t) =>
      t.widget<Text>(find.byKey(const Key('placement-word-text'))).data!;

  /// Plays the word check as a child who knows Pre-A1 words but not A1,
  /// and picks the right picture on every check. Returns how many words
  /// and checks were shown.
  Future<(int, int)> playPlacement(WidgetTester t) async {
    var words = 0;
    var checks = 0;
    String? last;
    for (var guard = 0; guard < 80; guard++) {
      if (find.byKey(const Key('placement-word')).evaluate().isNotEmpty) {
        last = shownWord(t);
        words++;
        final knows = last.startsWith('p');
        await t.tap(find.byKey(Key(knows ? 'placement-yes' : 'placement-no')));
        await t.pumpAndSettle();
      } else if (find.byKey(const Key('quiz')).evaluate().isNotEmpty) {
        checks++;
        expect(find.text('Show me!'), findsOneWidget);
        await t.tap(find.byKey(Key('quiz-option-$last')));
        await t.pump();
        await t.pump(QuizView.wrongPause);
        await t.pumpAndSettle();
      } else {
        break;
      }
    }
    return (words, checks);
  }

  testWidgets('new child: word check → favourite themes → 5 easy words', (
    t,
  ) async {
    final kid = await createKid(db, age: 8, placed: false);
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);

    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    expect(find.textContaining('word game'), findsOneWidget);
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();

    expect(find.byKey(const Key('placement-intro')), findsOneWidget);
    await t.tap(find.byKey(const Key('placement-start')));
    await t.pumpAndSettle();
    // Each word is read aloud (pre-readers need it).
    expect(speaker.said, [shownWord(t)]);

    final (words, checks) = await playPlacement(t);
    expect(words, inInclusiveRange(20, 30));
    expect(checks, greaterThanOrEqualTo(3));

    // Themes: pick two, a third tap on the same one unpicks it.
    expect(find.byKey(const Key('placement-themes')), findsOneWidget);
    expect(find.byKey(const Key('theme-animals')), findsOneWidget);
    expect(find.byKey(const Key('theme-food')), findsOneWidget);
    // "things" is not something a child picks.
    expect(find.byKey(const Key('theme-things')), findsNothing);
    await t.tap(find.byKey(const Key('theme-animals')));
    await t.tap(find.byKey(const Key('theme-food')));
    await t.tap(find.byKey(const Key('theme-food')));
    await t.pump();
    await t.tap(find.byKey(const Key('themes-done')));
    await t.pumpAndSettle();

    final p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.currentLevel, 'preA1'); // started at A1, knew only Pre-A1
    expect(p.interests, ['animals']);
    expect(p.onboardedAt, isNotNull);

    // First mini-session: 5 words the child said they knew.
    final seen = <String>[];
    for (var i = 0; i < 5; i++) {
      expect(find.byKey(const Key('answer-knew')), findsOneWidget);
      seen.add(speaker.said.last);
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }
    expect(seen.every((id) => id.startsWith('p')), isTrue, reason: '$seen');
    expect(seen.toSet(), hasLength(5));
    final schedules = await ProgressRepository(db).schedules(kid);
    expect(schedules.keys.toSet(), seen.toSet());
  });

  testWidgets('quitting the word check saves nothing', (t) async {
    final kid = await createKid(db, placed: false);
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('placement-start')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('placement-no')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('placement-quit')));
    await t.pumpAndSettle();

    expect(find.textContaining('word game'), findsOneWidget);
    final p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.onboardedAt, isNull);
  });

  testWidgets('parent adds a child and hands over for the word check', (
    t,
  ) async {
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(const Key('add-child')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name-field')), 'An');
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();

    expect(find.text('Word check for An'), findsOneWidget);
    await t.tap(find.byKey(const Key('placement-now')));
    await t.pumpAndSettle();
    expect(find.text('Hi An!'), findsOneWidget);
    expect(find.textContaining('word game'), findsOneWidget);
  });

  testWidgets('parent can skip, then redo, the word check', (t) async {
    final kid = await createKid(db, placed: false);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.text('Bi'));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('placement-toggle')));
    expect(find.text('Skip'), findsOneWidget);
    await t.tap(find.byKey(const Key('placement-toggle')));
    await t.pumpAndSettle();
    expect(find.text('Redo'), findsOneWidget);
    var p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.onboardedAt, isNotNull);

    await t.tap(find.byKey(const Key('placement-toggle')));
    await t.pumpAndSettle();
    p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.onboardedAt, isNull);
  });

  testWidgets('parent sets favourite topics in the edit form', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.text('Bi'));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('interest-sports')));
    await t.tap(find.byKey(const Key('interest-sports')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();
    final p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.interests, ['sports']);
  });
}
