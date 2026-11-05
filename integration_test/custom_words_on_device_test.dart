// On-device look at feat-018: a parent adds a word from homework; the child
// meets it first.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/custom_words_on_device_test.dart -d <device>
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
import 'package:voca_swiper/data/repositories/custom_word_repository.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('custom words on device', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final profiles = ProfileRepository(db);
    final bi = await profiles.create(
      const ProfileDraft(name: 'Bi', avatar: '🐯', age: 7, level: CefrLevel.a1),
      now: now,
    );
    await profiles.skipPlacement(bi, now: now);
    // One bank word already on the list.
    await CustomWordRepository(db).add(bi, text: 'rainbow', now: now);

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
      await binding.takeScreenshot('$tag-f18-$name');
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
    await t.tap(find.text('Bi'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.byKey(const Key('open-custom-words')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('profile-form')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await t.ensureVisible(find.byKey(const Key('open-custom-words')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-custom-words')));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('cw-add')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('cw-word')), 'Triceratops');
    await t.pumpAndSettle();
    await t.enterText(
      find.byKey(const Key('cw-definition')),
      'A dinosaur with three horns.',
    );
    await t.enterText(
      find.byKey(const Key('cw-translation')),
      'khủng long ba sừng',
    );
    await t.tap(find.byKey(const Key('cw-emoji-🦖')));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('1-form');
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('khủng long ba sừng · your word'), findsOneWidget);
    await shot('2-list');

    // Child: the custom words come first.
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('exit-parent')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    expect(find.text('rainbow'), findsWidgets);
    await t.tap(find.byKey(const Key('answer-knew')));
    await t.pumpAndSettle();
    expect(find.text('triceratops'), findsWidgets);
    await shot('3-card');
    await t.tap(find.byKey(const Key('flash-card')));
    await t.pumpAndSettle();
    expect(find.text('A dinosaur with three horns.'), findsOneWidget);
    await shot('4-card-back');

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
