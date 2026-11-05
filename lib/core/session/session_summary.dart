import '../srs/sm2_scheduler.dart';
import '../srs/word_state.dart';
import 'study_session.dart';

/// End-of-session numbers (docs/SPEC.md — Session flow step 5) and the
/// fields written to SessionLog.
class SessionSummary {
  const SessionSummary({
    required this.reviewed,
    required this.newLearned,
    required this.answered,
    required this.correct,
    this.quizAsked = 0,
    this.quizCorrect = 0,
  });

  /// Built from first answers only; retries are practice. [quiz] holds the
  /// quiz result per word: a wrong quiz answer overrides the swipe.
  factory SessionSummary.of(
    StudySession session, {
    Map<String, bool> quiz = const {},
  }) {
    final isNew = <String, bool>{};
    for (final c in session.seen) {
      isNew.putIfAbsent(c.wordId, () => c.isNew);
    }
    var reviewed = 0, newLearned = 0, correct = 0;
    session.firstAnswers.forEach((wordId, answer) {
      if (isNew[wordId] ?? false) {
        newLearned++;
      } else {
        reviewed++;
      }
      if (isPass(resolveAnswer(answer, quizCorrect: quiz[wordId]))) correct++;
    });
    return SessionSummary(
      reviewed: reviewed,
      newLearned: newLearned,
      answered: session.firstAnswers.length,
      correct: correct,
      quizAsked: quiz.length,
      quizCorrect: quiz.values.where((ok) => ok).length,
    );
  }

  final int reviewed;
  final int newLearned;
  final int answered;
  final int correct;
  final int quizAsked;
  final int quizCorrect;

  double get accuracy => answered == 0 ? 0 : correct / answered;

  /// 0 when nothing was answered; otherwise 1–3, never 0 for trying.
  int get stars {
    if (answered == 0) return 0;
    if (accuracy >= 0.8) return 3;
    if (accuracy >= 0.5) return 2;
    return 1;
  }
}

bool isPass(AnswerQuality a) =>
    a == AnswerQuality.knew || a == AnswerQuality.almost;
