import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/levels.dart';
import '../../core/progress/level_progression.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/word_repository.dart';

/// Applies the level progression rules (feat-016) to a profile.
class LevelService {
  LevelService({
    required this.words,
    required this.progress,
    required this.profiles,
    required this.clock,
    this.rules = const LevelProgression(),
  });

  final WordRepository words;
  final ProgressRepository progress;
  final ProfileRepository profiles;
  final DateTime Function() clock;
  final LevelProgression rules;

  /// The levels just above and below [p]'s that have words for its age.
  Future<({CefrLevel? next, CefrLevel? lower})> neighbours(ProfileRow p) async {
    final have = (await words.levelCounts(age: p.age)).keys.toList();
    final cur = CefrLevel.fromCode(p.currentLevel).index;
    CefrLevel? next, lower;
    for (final l in have) {
      if (l.index > cur && next == null) next = l;
      if (l.index < cur) lower = l;
    }
    return (next: next, lower: lower);
  }

  /// Level for next-level preview words, or null (locked / top level).
  Future<CefrLevel?> previewLevel(ProfileRow p) async =>
      p.levelLocked ? null : (await neighbours(p)).next;

  /// Moves the profile up a level if the rules say so; returns the new
  /// level, or null when it stays.
  Future<CefrLevel?> maybeLevelUp(int profileId) async {
    final p = await profiles.get(profileId);
    if (p == null) return null;
    final level = CefrLevel.fromCode(p.currentLevel);
    final total = (await words.levelCounts(age: p.age))[level] ?? 0;
    final mastered = await progress.masteredAt(
      profileId,
      level: level,
      age: p.age,
    );
    final up = rules.levelUp(
      mastered: mastered,
      total: total,
      next: (await neighbours(p)).next,
      locked: p.levelLocked,
    );
    if (up != null) await profiles.changeLevel(profileId, up, now: clock());
    return up;
  }

  /// A step-back suggestion for the parent, or null.
  Future<StepBackSuggestion?> stepBackFor(int profileId) async {
    final p = await profiles.get(profileId);
    if (p == null) return null;
    return rules.stepBack(
      lower: (await neighbours(p)).lower,
      locked: p.levelLocked,
      levelSince: levelSince(p).toUtc(),
      dismissedAt: p.stepBackDismissedAt?.toUtc(),
      sessions: await progress.sessionStats(profileId),
      now: clock(),
    );
  }

  /// Sets the level (step back, or the parent's override).
  Future<void> setLevel(int profileId, CefrLevel to) =>
      profiles.changeLevel(profileId, to, now: clock());

  Future<void> dismissStepBack(int profileId) =>
      profiles.dismissStepBack(profileId, now: clock());
}

final levelServiceProvider = Provider(
  (ref) => LevelService(
    words: ref.watch(wordRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    profiles: ref.watch(profileRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The parent's step-back suggestion for a profile (parent area).
final stepBackSuggestionProvider = FutureProvider.autoDispose
    .family<StepBackSuggestion?, int>(
      (ref, profileId) =>
          ref.watch(levelServiceProvider).stepBackFor(profileId),
    );
