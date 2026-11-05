/// One logged quiz answer.
class QuizAnswer {
  const QuizAnswer({
    required this.wordId,
    required this.correct,
    required this.answeredAt,
  });

  final String wordId;
  final bool correct;
  final DateTime answeredAt;
}

/// "Remembered after 2 weeks" (docs/SPEC.md — Phase 2 gate): how often the
/// child gets a quiz right on a word first learned [Retention.twoWeeks] or
/// more before the quiz. Every such answer counts.
class Retention {
  const Retention({
    required this.asked,
    required this.correct,
    required this.words,
  });

  static const twoWeeks = Duration(days: 14);

  /// [firstSeen]: when each word was first shown to this profile. Answers
  /// for words not in it (e.g. progress was reset) are ignored.
  factory Retention.compute({
    required List<QuizAnswer> answers,
    required Map<String, DateTime> firstSeen,
    Duration minAge = twoWeeks,
  }) {
    var asked = 0, correct = 0;
    final words = <String>{};
    for (final a in answers) {
      final first = firstSeen[a.wordId];
      if (first == null || a.answeredAt.difference(first) < minAge) continue;
      asked++;
      if (a.correct) correct++;
      words.add(a.wordId);
    }
    return Retention(asked: asked, correct: correct, words: words.length);
  }

  /// Quiz answers on words learned 2+ weeks earlier.
  final int asked;
  final int correct;

  /// Different words among those answers.
  final int words;

  /// Share right, 0–1; null until there is an answer to count.
  double? get rate => asked == 0 ? null : correct / asked;
}
