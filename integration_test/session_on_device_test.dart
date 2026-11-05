// On-device run of a daily session (feat-006 manual check), on a phone and a
// tablet: `flutter drive --driver test_driver/integration_test.dart
// --target integration_test/session_on_device_test.dart -d <device>`.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/features/session/quiz_view.dart';
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
    // Android renders to a texture; it must be switched to an image surface
    // once before screenshots.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
    }

    // pumpAndSettle with a short limit that reports who keeps asking for
    // frames instead of hanging for 10 minutes.
    Finder anyOption() => find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('quiz-option-'),
        )
        .first;
    Finder wrongOption(String right) => find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('quiz-option-') &&
              w.key != Key('quiz-option-$right'),
        )
        .first;
    Future<void> settle() async {
      try {
        await t.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 20),
        );
      } on FlutterError {
        debugPrint(
          'SETTLE-TIMEOUT transient=${t.binding.transientCallbackCount}',
        );
        debugPrintScheduleFrameStacks = true;
        await t.pump(const Duration(milliseconds: 100));
        debugPrintScheduleFrameStacks = false;
        rethrow;
      }
    }

    Future<void> shot(String name) async {
      await settle();
      // Let the last animated frame reach the screen before capturing.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await t.pump();
      await binding.takeScreenshot('$tag-$name');
    }

    await shot('0-picker');
    await t.tap(find.byKey(Key('profile-$kid')));
    await settle();
    expect(find.text('5 words are waiting to say hi!'), findsOneWidget);
    await shot('1-kid-home');

    Future<void> quizPick(WidgetTester t, String id) async {
      await t.tap(find.byKey(Key('quiz-option-$id')));
      await t.pump(QuizView.wrongPause);
      await settle();
    }

    await t.tap(find.byKey(const Key('start-session')));
    await settle();
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
    await settle(); // cat: knew

    await t.drag(find.byKey(const Key('flash-card')), const Offset(-500, 0));
    await settle(); // dog: didn't know
    await t.drag(find.byKey(const Key('flash-card')), const Offset(0, -600));
    await settle(); // bird: almost
    await t.tap(find.byKey(const Key('answer-knew'))); // fish
    await settle();
    await t.tap(find.byKey(const Key('answer-knew'))); // horse
    await settle();
    expect(find.text('One more try! 💪'), findsOneWidget);
    await shot('5-retry');
    await t.tap(find.byKey(const Key('answer-knew'))); // dog retry
    await settle();

    // feat-012: quiz on the words swiped knew/almost (not dog).
    expect(find.byKey(const Key('quiz')), findsOneWidget);
    expect(find.byKey(const Key('quiz-kind-pickPicture')), findsOneWidget);
    await shot('6a-quiz-picture');
    await quizPick(t, 'cat');
    // A wrong pick for bird: the right picture lights up.
    await t.tap(
      find.byKey(const Key('quiz-option-fish')).evaluate().isNotEmpty
          ? find.byKey(const Key('quiz-option-fish'))
          : wrongOption('bird'),
    );
    await t.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('$tag-6b-quiz-wrong');
    await t.pump(QuizView.wrongPause);
    await settle();
    await quizPick(t, 'fish');
    await t.tap(find.byKey(const Key('quiz-option-horse')));
    // Catch the confetti mid-burst.
    for (var i = 0; i < 12; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    await binding.takeScreenshot('$tag-6-summary');
    await settle();
    // Swipes 4/5, but bird's quiz was wrong → 3/5 → 2 stars.
    expect(find.text('Great job!'), findsOneWidget);
    expect(find.text('Quiz: 3 of 4 right'), findsOneWidget);

    final p = await ProgressRepository(db).schedules(kid);
    expect(p.keys.toSet(), {'cat', 'dog', 'bird', 'fish', 'horse'});
    expect(p['dog']!.wrongCount, 1);
    expect(p['bird']!.wrongCount, 1, reason: 'quiz wrong overrides');

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
    await settle();

    // The 7+ "adventure" look.
    await t.tap(find.byTooltip('Back'));
    await settle();
    await t.tap(find.byKey(Key('profile-$older')));
    await shot('8-older-home');
    await t.tap(find.byKey(const Key('start-session')));
    await shot('9-older-card');
    for (
      var i = 0;
      i < 5 && find.byKey(const Key('answer-knew')).evaluate().isNotEmpty;
      i++
    ) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await settle();
    }
    // 7+: questions take turns (picture, meaning, spelling).
    for (
      var q = 0;
      q < 3 && find.byKey(const Key('quiz')).evaluate().isNotEmpty;
      q++
    ) {
      final kind = QuizKind.values.firstWhere(
        (k) => find.byKey(Key('quiz-kind-${k.name}')).evaluate().isNotEmpty,
      );
      if (kind == QuizKind.spell) {
        await t.tap(find.byKey(const Key('quiz-tile-0')));
        await t.pump();
        await t.tap(find.byKey(const Key('quiz-tile-1')));
        await t.pump();
        await shot('9${'abc'[q]}-older-quiz-${kind.name}');
        break;
      }
      await shot('9${'abc'[q]}-older-quiz-${kind.name}');
      await t.tap(anyOption());
      await t.pump(QuizView.wrongPause);
      await settle();
    }
    await t.tap(find.byKey(const Key('quit-session')));
    await settle();
    // Unmount first: closing Drift under live queries hangs.
    await t.pumpWidget(const SizedBox());
    await db.close();
  });
}
