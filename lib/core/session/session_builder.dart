import '../srs/word_schedule.dart';
import 'study_session.dart';

/// Builds a daily session (docs/SPEC.md — Core learning loop):
/// 1. Due reviews first, oldest due date first (ties by word id).
/// 2. New words next, in the given order, up to what is left of the
///    profile's daily goal.
///
/// Missed words are re-queued by [StudySession] while the session runs.
class SessionBuilder {
  const SessionBuilder();

  /// [schedules]: every word this profile has progress for, keyed by word id.
  /// [newWordIds]: candidate new words, already ordered by the data layer
  /// (level, interests, frequency). Words with progress are skipped.
  /// [newIntroducedToday]: new words already shown in earlier sessions today.
  StudySession build({
    required Map<String, WordSchedule> schedules,
    required List<String> newWordIds,
    required int dailyNewWords,
    required DateTime now,
    int newIntroducedToday = 0,
  }) {
    final due = schedules.entries.where((e) => e.value.isDue(now)).toList()
      ..sort((a, b) {
        final byDate = a.value.nextReviewAt!.compareTo(b.value.nextReviewAt!);
        return byDate != 0 ? byDate : a.key.compareTo(b.key);
      });

    final newBudget = dailyNewWords - newIntroducedToday;
    final seen = <String>{};
    final fresh = newBudget <= 0
        ? const <String>[]
        : newWordIds
              .where((id) => !schedules.containsKey(id) && seen.add(id))
              .take(newBudget)
              .toList();

    return StudySession([
      for (final e in due) SessionCard(e.key, isNew: false),
      for (final id in fresh) SessionCard(id, isNew: true),
    ]);
  }
}
