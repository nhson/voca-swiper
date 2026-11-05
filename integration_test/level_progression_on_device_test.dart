// On-device look at feat-016: the level-up celebration and the parent's
// step-back suggestion, with the real word bank.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/level_progression_on_device_test.dart -d <device>
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/features/session/quiz_view.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('level progression on device', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final profiles = ProfileRepository(db);
    final progress = ProgressRepository(db);

    // Bi (6, Pre-A1): one "knew it" away from 80% of Pre-A1 mastered.
    final bi = await profiles.create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now,
    );
    await profiles.skipPlacement(bi, now: now);
    final preA1 =
        await (db.select(db.words)
              ..where(
                (w) =>
                    w.levelIndex.equals(CefrLevel.preA1.index) &
                    w.minAge.isSmallerOrEqualValue(6),
              )
              ..orderBy([(w) => OrderingTerm.asc(w.rank)]))
            .get();
    final need = (preA1.length * 0.8).ceil();
    WordSchedule sched(WordState s, int days, DateTime due) => WordSchedule(
      state: s,
      easeFactor: 2.5,
      intervalDays: days,
      repetitions: 4,
      nextReviewAt: due,
      lastAnsweredAt: now.subtract(Duration(days: days)),
      correctCount: 4,
      wrongCount: 0,
    );
    for (final w in preA1.take(need - 1)) {
      await progress.save(
        bi,
        w.id,
        sched(WordState.mastered, 30, now.add(const Duration(days: 30))),
        now: now,
      );
    }
    await progress.save(
      bi,
      preA1[need - 1].id,
      sched(WordState.review, 10, now.subtract(const Duration(hours: 1))),
      now: now,
    );

    // An (9, A1): placed 10 days ago, 30% right on 4 days this week.
    final an = await profiles.create(
      const ProfileDraft(name: 'An', avatar: '🦊', age: 9, level: CefrLevel.a1),
      now: now.subtract(const Duration(days: 10)),
    );
    await profiles.skipPlacement(
      an,
      now: now.subtract(const Duration(days: 10)),
    );
    for (final d in [6, 4, 2, 1]) {
      await progress.logSession(
        profileId: an,
        startedAt: now.subtract(Duration(days: d)),
        durationSec: 300,
        reviewed: 8,
        newLearned: 2,
        accuracy: 0.3,
      );
    }

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        ambientMotionProvider.overrideWithValue(false),
      ],
    );
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocaSwiperApp(),
      ),
    );
    await t.pumpAndSettle();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      await t.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await t.pump();
      await binding.takeScreenshot('$tag-f16-$name');
    }

    // 1. Bi's session: all "knew it", the quiz answered right → level up.
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    for (var guard = 0; guard < 40; guard++) {
      if (find.byKey(const Key('answer-knew')).evaluate().isNotEmpty) {
        await t.tap(find.byKey(const Key('answer-knew')));
        await t.pumpAndSettle();
      } else if (find.byType(QuizView).evaluate().isNotEmpty) {
        final id = t.widget<QuizView>(find.byType(QuizView)).item.wordId;
        await t.tap(find.byKey(Key('quiz-option-$id')));
        await t.pump();
        await t.pump(QuizView.wrongPause);
        await t.pumpAndSettle();
      } else {
        break;
      }
    }
    expect(find.byKey(const Key('level-up')), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await t.pump();
    await binding.takeScreenshot('$tag-f16-1-level-up');
    expect((await profiles.get(bi))!.currentLevel, 'A1');
    await t.tap(find.byKey(const Key('session-done')));
    await t.pumpAndSettle();
    await t.pageBack();
    await t.pumpAndSettle();

    // 2. Parent area: step-back suggestion for An.
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('pin-field')),
        matching: find.byType(EditableText),
      ),
      '1234',
    );
    await t.pump();
    await t.tap(find.byKey(const Key('unlock')));
    await t.pumpAndSettle();
    expect(find.byKey(Key('step-back-$an')), findsOneWidget);
    expect(find.byKey(Key('step-back-$bi')), findsNothing);
    await shot('2-step-back');
    await t.tap(find.byKey(Key('step-back-accept-$an')));
    await t.pumpAndSettle();
    expect(find.byKey(Key('step-back-$an')), findsNothing);
    expect((await profiles.get(an))!.currentLevel, 'preA1');
    await shot('3-after');

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
