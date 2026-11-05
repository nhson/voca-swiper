import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/recap/weekly_recap.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/word_repository.dart';

/// A child's weekly recap with the cards it mentions.
class RecapData {
  const RecapData(this.recap, this.cards);
  final WeeklyRecap recap;
  final Map<String, WordCard> cards;

  WordCard? get wordOfWeek =>
      recap.wordOfWeek == null ? null : cards[recap.wordOfWeek];
  List<WordCard> get recall => [for (final id in recap.recall) ?cards[id]];
}

/// Builds weekly recaps from progress (feat-019).
class RecapService {
  RecapService({
    required this.words,
    required this.progress,
    required this.profiles,
    required this.clock,
  });

  final WordRepository words;
  final ProgressRepository progress;
  final ProfileRepository profiles;
  final DateTime Function() clock;

  Future<RecapData?> load(int profileId) async {
    final p = await profiles.get(profileId);
    if (p == null) return null;
    final schedules = await progress.schedules(profileId);
    final firstSeen = await progress.firstSeen(profileId);
    final cards = {
      for (final c in await words.cards(
        schedules.keys.toList(),
        language: p.nativeLanguage,
      ))
        c.word.id: c,
    };
    final recap = WeeklyRecap.compute(
      words: [
        for (final e in schedules.entries)
          if (cards[e.key] != null && firstSeen[e.key] != null)
            RecapWord(
              id: e.key,
              state: e.value.state,
              firstSeen: firstSeen[e.key]!.toUtc(),
              correctCount: e.value.correctCount,
              lastAnsweredAt: e.value.lastAnsweredAt?.toUtc(),
              hasPicture: cards[e.key]!.word.emoji != null,
            ),
      ],
      sessions: await progress.sessionStats(profileId),
      now: clock(),
    );
    return RecapData(recap, cards);
  }
}

final recapServiceProvider = Provider(
  (ref) => RecapService(
    words: ref.watch(wordRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    profiles: ref.watch(profileRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final weeklyRecapProvider = FutureProvider.autoDispose.family<RecapData?, int>(
  (ref, profileId) => ref.watch(recapServiceProvider).load(profileId),
);
