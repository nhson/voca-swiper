import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'session_controller.dart';

final sessionLoaderProvider = Provider(
  (ref) => SessionLoader(
    words: ref.watch(wordRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    profiles: ref.watch(profileRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Today's due reviews and new words for a profile (child home).
final sessionPreviewProvider = FutureProvider.family<SessionPreview, int>(
  (ref, profileId) => ref.watch(sessionLoaderProvider).preview(profileId),
);
