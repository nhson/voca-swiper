// On-device look at feat-015: a new child's word check, favourite themes
// and the first 5 easy words, with the real word bank.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/placement_on_device_test.dart -d <device>
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
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/features/session/quiz_view.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('placement on device', (t) async {
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
        name: 'Mai',
        avatar: '🐼',
        age: 8,
        level: CefrLevel.a1,
      ),
      now: now,
    );
    // Word text → level, to play a child who knows Pre-A1 and A1 only.
    final levelOf = {
      for (final w in await db.select(db.words).get()) w.word: w.levelIndex,
    };

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
      await binding.takeScreenshot('$tag-f15-$name');
    }

    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await shot('1-home');
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    await shot('2-intro');
    await t.tap(find.byKey(const Key('placement-start')));
    await t.pumpAndSettle();

    var words = 0;
    var checks = 0;
    String? last;
    for (var guard = 0; guard < 80; guard++) {
      if (find.byKey(const Key('placement-word')).evaluate().isNotEmpty) {
        last = t
            .widget<Text>(find.byKey(const Key('placement-word-text')))
            .data!;
        if (words == 1) await shot('3-word');
        words++;
        final knows = (levelOf[last] ?? 9) <= CefrLevel.a1.index;
        await t.tap(find.byKey(Key(knows ? 'placement-yes' : 'placement-no')));
        await t.pumpAndSettle();
      } else if (find.byKey(const Key('quiz')).evaluate().isNotEmpty) {
        if (checks == 0) await shot('4-check');
        checks++;
        // Tap the option showing the right answer: its key ends with the id
        // of the word just asked, whose text is [last].
        final ids = (await (db.select(
          db.words,
        )..where((w) => w.word.equals(last!))).get()).map((w) => w.id);
        final right = ids
            .map((id) => find.byKey(Key('quiz-option-$id')))
            .firstWhere((f) => f.evaluate().isNotEmpty);
        await t.tap(right);
        await t.pump();
        await t.pump(QuizView.wrongPause);
        await t.pumpAndSettle();
      } else {
        break;
      }
    }
    expect(words, inInclusiveRange(20, 30));
    expect(checks, greaterThanOrEqualTo(3));

    expect(find.byKey(const Key('placement-themes')), findsOneWidget);
    await t.tap(find.byKey(const Key('theme-animals')));
    await t.tap(find.byKey(const Key('theme-sports')));
    await shot('5-themes');
    await t.tap(find.byKey(const Key('themes-done')));
    await t.pumpAndSettle();

    final p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(kid))).getSingle();
    expect(p.currentLevel, 'A1');
    expect(p.interests, ['animals', 'sports']);
    await shot('6-first-card');
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
