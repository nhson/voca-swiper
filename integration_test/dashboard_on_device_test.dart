// On-device look at feat-017: the parent dashboard with real words.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/dashboard_on_device_test.dart -d <device>
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard on device', (t) async {
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
    final bi = await profiles.create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now.subtract(const Duration(days: 60)),
    );
    await profiles.skipPlacement(
      bi,
      now: now.subtract(const Duration(days: 60)),
    );
    final words = await (db.select(db.words)..limit(60)).get();
    for (final (i, w) in words.indexed) {
      final wrong = i % 7 == 0 ? 4 : (i % 5 == 0 ? 2 : 0);
      await progress.save(
        bi,
        w.id,
        WordSchedule(
          state: i < 30 ? WordState.mastered : WordState.learning,
          easeFactor: 2.3,
          intervalDays: i < 30 ? 30 : 1,
          repetitions: 3,
          nextReviewAt: now.add(const Duration(days: 1)),
          lastAnsweredAt: now,
          correctCount: 3,
          wrongCount: wrong,
        ),
        now: now.subtract(Duration(days: 55 - i)),
      );
    }
    for (var d = 0; d < 50; d++) {
      if (d % 3 == 2) continue;
      await progress.logSession(
        profileId: bi,
        startedAt: now.subtract(Duration(days: d)),
        durationSec: (6 + d % 7) * 60,
        reviewed: 8,
        newLearned: 2,
        accuracy: 0.75,
      );
    }
    for (final (i, w) in words.take(20).indexed) {
      await progress.logQuiz(
        profileId: bi,
        wordId: w.id,
        kind: QuizKind.pickPicture,
        correct: i % 5 != 0,
        at: now,
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
      await binding.takeScreenshot('$tag-f17-$name');
    }

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
    await t.tap(find.byKey(Key('parent-progress-$bi')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('dashboard')), findsOneWidget);
    expect(find.textContaining('80% right'), findsOneWidget);
    await shot('1-top');
    await t.scrollUntilVisible(
      find.text('Struggling words'),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('dashboard')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await shot('2-struggling');

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
