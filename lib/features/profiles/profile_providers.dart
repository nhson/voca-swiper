import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';

final profilesProvider = StreamProvider<List<ProfileRow>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAll(),
);

final profileProvider = StreamProvider.family<ProfileRow?, int>(
  (ref, id) => ref.watch(profileRepositoryProvider).watch(id),
);

const avatars = [
  '🐯', '🦁', '🐼', '🐨', '🐸', '🦊', '🐰', '🐻', //
  '🦄', '🐙', '🐵', '🐧', '🦖', '🐳', '🐞', '🦋',
];
