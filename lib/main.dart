import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/db/app_database.dart';
import 'data/word_bank_importer.dart';

const wordBankAsset = 'assets/word_bank/word_bank.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(driftDatabase(name: 'voca_swiper'));
  await WordBankImporter(db).importIfNewer(
    await rootBundle.loadString(wordBankAsset),
  );
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const VocaSwiperApp(),
    ),
  );
}
