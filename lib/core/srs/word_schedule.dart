import 'word_state.dart';

/// Spaced-repetition state of one word for one profile.
///
/// Mirrors the scheduling fields of `WordProgress` in docs/SPEC.md; the data
/// layer maps between the two. Immutable — the scheduler returns a new value.
class WordSchedule {
  const WordSchedule({
    required this.state,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReviewAt,
    required this.lastAnsweredAt,
    required this.correctCount,
    required this.wrongCount,
  });

  /// A word the profile has never answered.
  factory WordSchedule.initial() => const WordSchedule(
    state: WordState.newWord,
    easeFactor: defaultEase,
    intervalDays: 0,
    repetitions: 0,
    nextReviewAt: null,
    lastAnsweredAt: null,
    correctCount: 0,
    wrongCount: 0,
  );

  static const double defaultEase = 2.5;

  final WordState state;
  final double easeFactor;
  final int intervalDays;

  /// Consecutive passes since the last miss.
  final int repetitions;

  /// UTC. Null while the word is New.
  final DateTime? nextReviewAt;
  final DateTime? lastAnsweredAt;
  final int correctCount;
  final int wrongCount;

  /// Whether this word is a due review at [now]. New words never are; the
  /// session builder adds them separately, up to the daily goal.
  bool isDue(DateTime now) {
    final next = nextReviewAt;
    return next != null && !now.isBefore(next);
  }

  WordSchedule copyWith({
    WordState? state,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? nextReviewAt,
    DateTime? lastAnsweredAt,
    int? correctCount,
    int? wrongCount,
  }) => WordSchedule(
    state: state ?? this.state,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    lastAnsweredAt: lastAnsweredAt ?? this.lastAnsweredAt,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
  );

  @override
  String toString() =>
      'WordSchedule($state, ease $easeFactor, ${intervalDays}d, '
      'reps $repetitions, next $nextReviewAt)';
}
