// On-device run of a daily session (feat-006 manual check), on a phone and a
// tablet: `flutter drive --driver test_driver/integration_test.dart
// --target integration_test/session_on_device_test.dart -d <device>`.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily session on device', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final kid = await ProfileRepository(db).create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now,
    );
    final older = await ProfileRepository(db).create(
      const ProfileDraft(name: 'An', avatar: '🦊', age: 9, level: CefrLevel.a1),
      now: now,
    );

    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // Idle loops never settle; real sounds and TTS stay on.
          ambientMotionProvider.overrideWithValue(false),
        ],
        child: const VocaSwiperApp(),
      ),
    );
    await t.pumpAndSettle();

    Future<void> shot(String name) async {
      await t.pumpAndSettle();
      // Let the last animated frame reach the screen before capturing.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await t.pump();
      await binding.takeScreenshot('$tag-$name');
    }

    await shot('0-picker');
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    expect(find.text('5 words are waiting to say hi!'), findsOneWidget);
    await shot('1-kid-home');

    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    expect(find.text('cat'), findsOneWidget);
    await shot('2-card-front');

    await t.tap(find.byKey(const Key('flash-card')));
    await shot('3-card-back');
    expect(find.text('con mèo'), findsOneWidget);

    // Mid-swipe, to see the hint label.
    final g = await t.startGesture(
      t.getCenter(find.byKey(const Key('flash-card'))),
    );
    await g.moveBy(const Offset(60, 0));
    await g.moveBy(const Offset(60, 0));
    await shot('4-dragging-right');
    await g.moveBy(const Offset(200, 0));
    await g.up();
    await t.pumpAndSettle(); // cat: knew

    await t.drag(find.byKey(const Key('flash-card')), const Offset(-500, 0));
    await t.pumpAndSettle(); // dog: didn't know
    await t.drag(find.byKey(const Key('flash-card')), const Offset(0, -600));
    await t.pumpAndSettle(); // bird: almost
    await t.tap(find.byKey(const Key('answer-knew'))); // fish
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('answer-knew'))); // horse
    await t.pumpAndSettle();
    expect(find.text('One more try! 💪'), findsOneWidget);
    await shot('5-retry');
    await t.tap(find.byKey(const Key('answer-knew'))); // dog retry
    // Catch the confetti mid-burst.
    for (var i = 0; i < 12; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    await binding.takeScreenshot('$tag-6-summary');
    await t.pumpAndSettle();
    expect(find.text('Amazing!'), findsOneWidget); // 4/5 → 3 stars

    final p = await ProgressRepository(db).schedules(kid);
    expect(p.keys.toSet(), {'cat', 'dog', 'bird', 'fish', 'horse'});
    expect(p['dog']!.wrongCount, 1);
    expect(p['bird']!.easeFactor, closeTo(2.35, 1e-9));

    await t.tap(find.byKey(const Key('session-done')));
    await shot('7-kid-home-after');
    expect(find.text('All done for today! 🎉'), findsOneWidget);

    // feat-008: the progress screen after one session.
    await t.tap(find.byKey(const Key('open-progress')));
    await shot('7b-progress');
    expect(
      (t.widget<Text>(find.byKey(const Key('stat-learning')))).data,
      '5',
      reason: 'all five words are in Learning after their first answer',
    );
    await t.tap(find.byTooltip('Back'));
    await t.pumpAndSettle();

    // The 7+ "adventure" look.
    await t.tap(find.byTooltip('Back'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(Key('profile-$older')));
    await shot('8-older-home');
    await t.tap(find.byKey(const Key('start-session')));
    await shot('9-older-card');
    await t.tap(find.byKey(const Key('quit-session')));
    await t.pumpAndSettle();
    // Unmount first: closing Drift under live queries hangs.
    await t.pumpWidget(const SizedBox());
    await db.close();
  });
}
