import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() async => db = await seededDb([w('cat')]));
  tearDown(() => db.close());

  testWidgets('first run: create PIN, add a child, see the picker', (t) async {
    await pumpApp(t, db);
    expect(find.text('Welcome to Voca Swiper'), findsOneWidget);

    // Six separate boxes; a short PIN is not accepted.
    expect(
      find.descendant(
        of: find.byKey(const Key('setup-pin')),
        matching: find.byKey(const Key('pin-box-5')),
      ),
      findsOneWidget,
    );
    await t.enterText(pinInput('setup-pin'), '1234');
    await t.enterText(pinInput('setup-confirm'), '1234');
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(find.text('Enter all 6 digits.'), findsOneWidget);

    await t.enterText(pinInput('setup-pin'), '123456');
    await t.enterText(pinInput('setup-confirm'), '123465');
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(find.text('The two PINs are different.'), findsOneWidget);

    await t.enterText(pinInput('setup-confirm'), '123456');
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('name-field')), findsOneWidget);

    await t.enterText(find.byKey(const Key('name-field')), 'Bi');
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('placement-later')));
    await t.pumpAndSettle();

    final rows = await db.select(db.profiles).get();
    expect(rows.single.name, 'Bi');
    expect(rows.single.currentLevel, 'preA1'); // age 6 default
    final account = await db.select(db.parentAccounts).getSingle();
    expect(account.pinHash, isNot(contains('123456')));
  });

  testWidgets('parent area needs the PIN and locks on exit', (t) async {
    await createParent(db);
    await createKid(db);
    await pumpApp(t, db);
    expect(find.text("Who's learning today?"), findsOneWidget);
    expect(find.text('Bi'), findsOneWidget);

    await unlockParent(t, pin: '0000');
    expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
    expect(find.text('Parent area'), findsNothing);
    await t.enterText(pinInput('pin-field'), '1');
    await t.pump();
    expect(
      find.text('Wrong PIN. Try again.'),
      findsNothing,
      reason: 'typing again clears the error',
    );

    // An older 4-digit PIN still works with the Unlock button.
    await t.enterText(pinInput('pin-field'), '1234');
    await t.tap(find.byKey(const Key('unlock')));
    await t.pumpAndSettle();
    expect(find.text('Parent area'), findsOneWidget);

    await t.tap(find.byKey(const Key('exit-parent')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    expect(find.text('Parents only'), findsOneWidget);
  });

  testWidgets('a 6-digit PIN unlocks as soon as the last box is filled', (
    t,
  ) async {
    await createParent(db, pin: '246810');
    await createKid(db);
    await pumpApp(t, db);
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    await t.enterText(pinInput('pin-field'), '246810');
    await t.pumpAndSettle();
    expect(find.text('Parent area'), findsOneWidget);
  });

  testWidgets('change PIN uses the 6 boxes too', (t) async {
    await createParent(db);
    await createKid(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.text('Change PIN'));
    await t.pumpAndSettle();
    await t.enterText(pinInput('change-pin'), '13579');
    await t.enterText(pinInput('change-confirm'), '13579');
    await t.tap(find.byKey(const Key('change-save')));
    await t.pumpAndSettle();
    expect(find.text('Enter all 6 digits.'), findsOneWidget);

    await t.enterText(pinInput('change-pin'), '135790');
    await t.enterText(pinInput('change-confirm'), '135790');
    await t.tap(find.byKey(const Key('change-save')));
    await t.pumpAndSettle();
    expect(
      await ParentRepository(db, run: runInline).verifyPin('135790'),
      isTrue,
    );
  });

  testWidgets('feat-014: A2/B1 levels; translation fades by level', (t) async {
    await createParent(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(const Key('add-child')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name-field')), 'Tom');

    // All four levels are offered.
    for (final l in ['Pre-A1', 'A1', 'A2', 'B1']) {
      expect(
        find.descendant(
          of: find.byKey(const Key('level')),
          matching: find.text(l),
        ),
        findsOneWidget,
        reason: l,
      );
    }

    // Age 11 → A2, and translations go to "tap to see".
    final slider = find.byKey(const Key('age-slider'));
    final r = t.getRect(slider);
    // Slider runs 4–15: age 11 is 7/11 of the way (track has 24px padding).
    final x = r.left + 24 + (r.width - 48) * 7 / 11;
    await t.tapAt(Offset(x, r.center.dy));
    await t.pumpAndSettle();
    expect(find.text('Age: 11'), findsOneWidget);
    SegmentedButton<T> seg<T>() =>
        t.widget<SegmentedButton<T>>(find.byType(SegmentedButton<T>));
    expect(seg<CefrLevel>().selected, {CefrLevel.a2});
    await scrollForm(t, find.text('Tap'));
    expect(seg<TranslationMode>().selected, {TranslationMode.tap});

    // The parent can pick B1.
    await t.tap(
      find.descendant(
        of: find.byKey(const Key('level')),
        matching: find.text('B1'),
      ),
    );
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('placement-skip')));
    await t.pumpAndSettle();

    final row = await db.select(db.profiles).getSingle();
    expect(row.onboardedAt, isNotNull);
    expect(row.currentLevel, 'B1');
    expect(row.translationMode, TranslationMode.tap);
    expect(row.age, 11);
  });

  testWidgets('editing one profile leaves the other unchanged', (t) async {
    await createParent(db);
    final a = await createKid(db, name: 'Bi');
    final b = await createKid(db, name: 'Na', age: 9);
    await pumpApp(t, db);
    await unlockParent(t);

    await t.tap(find.byKey(Key('parent-profile-$a')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name-field')), 'Bo');
    // feat-011: the parent sees what the minutes mean for a session.
    await scrollForm(t, find.byKey(const Key('minutes-hint')));
    expect(
      t.widget<Text>(find.byKey(const Key('minutes-hint'))).data,
      contains('up to 25 cards'),
    );
    await scrollForm(t, find.byKey(const Key('swipe-direction')));
    await t.tap(find.byKey(const Key('swipe-direction')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();

    final repo = ProfileRepository(db);
    final ra = (await repo.get(a))!;
    final rb = (await repo.get(b))!;
    expect([ra.name, ra.swipeKnownRight], ['Bo', false]);
    expect([rb.name, rb.swipeKnownRight], ['Na', true]);
  });

  testWidgets('delete a profile after confirming', (t) async {
    await createParent(db);
    final a = await createKid(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(Key('parent-profile-$a')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('delete-profile')));
    await t.tap(find.byKey(const Key('delete-profile')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm')));
    await t.pumpAndSettle();
    expect(await db.select(db.profiles).get(), isEmpty);
  });

  testWidgets('tapping a profile opens the child home', (t) async {
    await createParent(db);
    final a = await createKid(db, name: 'Bi');
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$a')));
    await t.pumpAndSettle();
    expect(find.text('Hi Bi!'), findsOneWidget);
  });
}
