import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/settings_repository.dart';
import 'package:voca_swiper/ui/kid_look.dart';
import 'package:voca_swiper/ui/kid_scale.dart';
import 'package:voca_swiper/ui/sfx.dart';
import 'package:voca_swiper/ui/sky_background.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  group('KidLook.forAge', () {
    test('4–6 get the sunny look, 7+ the adventure look', () {
      expect(KidLook.forAge(4), KidLook.sunny);
      expect(KidLook.forAge(6), KidLook.sunny);
      expect(KidLook.forAge(7), KidLook.adventure);
      expect(KidLook.forAge(12), KidLook.adventure);
      expect(KidLook.forAge(null), KidLook.sunny);
    });
  });

  group('KidScale.factorFor', () {
    test('phones are not scaled', () {
      expect(KidScale.factorFor(const Size(390, 844)), 1);
      expect(KidScale.factorFor(const Size(599, 900)), 1);
    });
    test('tablets grow with size, capped', () {
      final mini = KidScale.factorFor(const Size(744, 1133));
      final big = KidScale.factorFor(const Size(1032, 1376));
      expect(mini, greaterThan(1.5));
      expect(big, 1.75);
      expect(big, greaterThanOrEqualTo(mini));
    });
  });

  group('child screens', () {
    late AppDatabase db;
    setUp(() async {
      db = await seededDb([
        w('cat', rank: 1, vi: 'con mèo'),
        w('dog', rank: 2),
      ]);
      await createParent(db);
    });
    tearDown(() => db.close());

    KidLook skyOf(WidgetTester t) =>
        t.widget<SkyBackground>(find.byType(SkyBackground)).look;

    testWidgets('child home look follows the age band', (t) async {
      final young = await createKid(db, name: 'Bi', age: 5);
      final older = await createKid(db, name: 'An', age: 9);
      await pumpApp(t, db);
      expect(skyOf(t), KidLook.sunny, reason: 'picker');

      await t.tap(find.byKey(Key('profile-$young')));
      await t.pumpAndSettle();
      expect(skyOf(t), KidLook.sunny);
      await t.tap(find.byTooltip('Back'));
      await t.pumpAndSettle();

      await t.tap(find.byKey(Key('profile-$older')));
      await t.pumpAndSettle();
      expect(skyOf(t), KidLook.adventure);
    });

    testWidgets('answers and the summary play their sounds', (t) async {
      final kid = await createKid(db);
      final sfx = FakeSfx();
      await pumpApp(t, db, sfx: sfx);
      await t.tap(find.byKey(Key('profile-$kid')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('start-session')));
      await t.pumpAndSettle();

      await t.tap(find.byKey(const Key('answer-knew'))); // cat
      await t.pumpAndSettle();
      await t.drag(find.byKey(const Key('flash-card')), const Offset(-300, 0));
      await t.pumpAndSettle(); // dog: not yet → retry
      await t.tap(find.byKey(const Key('answer-almost'))); // dog retry
      // Not pumpAndSettle: that would run the confetti to its end.
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }

      expect(sfx.played, [Sound.knew, Sound.notYet, Sound.almost, Sound.cheer]);
      expect(find.byKey(const Key('confetti')), findsOneWidget);
      expect(find.byKey(const Key('practiced')), findsOneWidget);
      await t.pump(const Duration(seconds: 3));
      expect(
        find.byKey(const Key('confetti')),
        findsNothing,
        reason: 'one burst, then gone',
      );
    });

    testWidgets('reduced motion: no confetti', (t) async {
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final kid = await createKid(db);
      await pumpApp(t, db);
      await t.tap(find.byKey(Key('profile-$kid')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('start-session')));
      await t.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await t.tap(find.byKey(const Key('answer-knew')));
        await t.pumpAndSettle();
      }
      expect(find.byKey(const Key('stars')), findsOneWidget);
      expect(find.byKey(const Key('confetti')), findsNothing);
    });

    testWidgets('parents can turn sound effects off', (t) async {
      await createKid(db);
      await pumpApp(t, db);
      await unlockParent(t);
      final toggle = find.byKey(const Key('sound-toggle'));
      await t.scrollUntilVisible(toggle, 100);
      expect(t.widget<SwitchListTile>(toggle).value, isTrue);
      await t.tap(toggle);
      await t.pumpAndSettle();
      expect(await SettingsRepository(db).soundEffects(), isFalse);
      expect(t.widget<SwitchListTile>(toggle).value, isFalse);
    });
  });

  test('AudioSfx stays silent when sound effects are off', () {
    // With enabled() false nothing reaches the audio plugin (which would
    // throw in a unit test).
    expect(
      () => AudioSfx(enabled: () => false).play(Sound.knew),
      returnsNormally,
    );
  });
}
