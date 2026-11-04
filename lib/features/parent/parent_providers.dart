import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';

final parentAccountProvider = StreamProvider<ParentAccountRow?>(
  (ref) => ref.watch(parentRepositoryProvider).watchAccount(),
);

/// Whether the PIN-protected parent area is unlocked. Locks again when the
/// parent leaves the area.
class ParentUnlocked extends Notifier<bool> {
  @override
  bool build() => false;
  void unlock() => state = true;
  void lock() => state = false;
}

final parentUnlockedProvider = NotifierProvider<ParentUnlocked, bool>(
  ParentUnlocked.new,
);
