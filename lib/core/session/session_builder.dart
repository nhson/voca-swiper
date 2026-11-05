import 'dart:math';

import '../srs/word_schedule.dart';
import 'study_session.dart';

/// Builds a daily session (docs/SPEC.md — Core learning loop):
/// 1. Due reviews first, oldest due date first (ties by word id).
/// 2. New words next, in the given order, up to what is left of the
///    profile's daily goal.
/// 3. With a [maxCards] budget (feat-011): at most that many cards. The most
///    overdue reviews go in first and the rest wait for the next session;
///    new words only fill the room reviews leave, so they pause on a
///    catch-up day and come back as the pile drains.
///
/// Missed words are re-queued by [StudySession] while the session runs;
/// those retries are practice on top of the budget.
class SessionBuilder {
  const SessionBuilder();

  /// Cards a child gets through per minute, retries included (~20–25 s per
  /// card for a 6–10-year-old).
  static const double cardsPerMinute = 2.5;

  /// Even a very short session shows a handful of cards.
  static const int minCards = 5;

  /// The session budget for a profile's "minutes per day" setting.
  static int cardsForMinutes(int minutes) =>
      max(minCards, (minutes * cardsPerMinute).floor());

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
    int? maxCards,
  }) {
    final due = schedules.entries.where((e) => e.value.isDue(now)).toList()
      ..sort((a, b) {
        final byDate = a.value.nextReviewAt!.compareTo(b.value.nextReviewAt!);
        return byDate != 0 ? byDate : a.key.compareTo(b.key);
      });
    final reviews = maxCards == null ? due : due.take(maxCards).toList();

    final room = maxCards == null ? dailyNewWords : maxCards - reviews.length;
    final newBudget = min(dailyNewWords - newIntroducedToday, room);
    final seen = <String>{};
    final fresh = newBudget <= 0
        ? const <String>[]
        : newWordIds
              .where((id) => !schedules.containsKey(id) && seen.add(id))
              .take(newBudget)
              .toList();

    return StudySession([
      for (final e in reviews) SessionCard(e.key, isNew: false),
      for (final id in fresh) SessionCard(id, isNew: true),
    ]);
  }
}
