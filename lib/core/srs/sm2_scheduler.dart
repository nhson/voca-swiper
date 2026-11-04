import 'word_schedule.dart';
import 'word_state.dart';

/// SM-2-style scheduler (docs/SPEC.md — Spaced repetition and reminders).
///
/// - Passes walk the ladder 1 day → 3 days → previous interval × ease.
/// - "Almost" is a pass with a shorter interval and a small ease penalty.
/// - A miss (didn't know / quiz wrong) resets to Learning, 1 day, lower ease.
/// - Mastered once the interval reaches [masteredIntervalDays].
///
/// Pure and deterministic: callers pass [now] (UTC).
class Sm2Scheduler {
  const Sm2Scheduler();

  static const int firstIntervalDays = 1;
  static const int secondIntervalDays = 3;
  static const int masteredIntervalDays = 21;
  static const double minEase = 1.3;
  static const double almostIntervalFactor = 0.6;
  static const double almostEasePenalty = 0.15;
  static const double missEasePenalty = 0.2;

  WordSchedule schedule(
    WordSchedule current,
    AnswerQuality answer, {
    required DateTime now,
  }) {
    switch (answer) {
      case AnswerQuality.knew:
        return _pass(current, now, almost: false);
      case AnswerQuality.almost:
        return _pass(current, now, almost: true);
      case AnswerQuality.didntKnow:
      case AnswerQuality.quizWrong:
        return _miss(current, now);
    }
  }

  WordSchedule _pass(WordSchedule s, DateTime now, {required bool almost}) {
    final repetitions = s.repetitions + 1;
    final ladder = switch (repetitions) {
      1 => firstIntervalDays,
      2 => secondIntervalDays,
      _ => (s.intervalDays * s.easeFactor).round(),
    };
    final interval =
        almost ? _atLeastOne((ladder * almostIntervalFactor).round()) : ladder;
    final ease =
        almost ? _lowerEase(s.easeFactor, almostEasePenalty) : s.easeFactor;

    return s.copyWith(
      state: _stateAfterPass(interval, repetitions),
      easeFactor: ease,
      intervalDays: interval,
      repetitions: repetitions,
      nextReviewAt: now.add(Duration(days: interval)),
      lastAnsweredAt: now,
      correctCount: s.correctCount + 1,
    );
  }

  WordSchedule _miss(WordSchedule s, DateTime now) => s.copyWith(
        state: WordState.learning,
        easeFactor: _lowerEase(s.easeFactor, missEasePenalty),
        intervalDays: firstIntervalDays,
        repetitions: 0,
        nextReviewAt: now.add(const Duration(days: firstIntervalDays)),
        lastAnsweredAt: now,
        wrongCount: s.wrongCount + 1,
      );

  static WordState _stateAfterPass(int interval, int repetitions) {
    if (interval >= masteredIntervalDays) return WordState.mastered;
    if (repetitions >= 2) return WordState.review;
    return WordState.learning;
  }

  /// Rounded to 2 decimals so stored values don't accumulate float drift.
  static double _lowerEase(double ease, double penalty) {
    final lowered = ((ease - penalty) * 100).round() / 100;
    return lowered < minEase ? minEase : lowered;
  }

  static int _atLeastOne(int days) => days < 1 ? 1 : days;
}

/// Final answer for a card: a wrong quiz answer overrides the swipe.
AnswerQuality resolveAnswer(AnswerQuality swipe, {bool? quizCorrect}) =>
    quizCorrect == false ? AnswerQuality.quizWrong : swipe;
