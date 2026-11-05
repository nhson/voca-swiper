import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/session/session_summary.dart';
import 'package:voca_swiper/core/session/study_session.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  StudySession play(List<SessionCard> cards, List<AnswerQuality> answers) {
    var s = StudySession(cards);
    for (final a in answers) {
      s = s.answer(a);
    }
    return s;
  }

  const newCat = SessionCard('cat', isNew: true);
  const newDog = SessionCard('dog', isNew: true);
  const reviewSun = SessionCard('sun', isNew: false);

  test('counts reviewed and new words from first answers only', () {
    final s = play(
      [reviewSun, newCat, newDog],
      [
        AnswerQuality.knew, // sun
        AnswerQuality.didntKnow, // cat → retry
        AnswerQuality.almost, // dog
        AnswerQuality.knew, // cat retry (ignored)
      ],
    );
    final sum = SessionSummary.of(s);
    expect(sum.reviewed, 1);
    expect(sum.newLearned, 2);
    expect(sum.answered, 3);
    expect(sum.correct, 2);
    expect(sum.accuracy, closeTo(2 / 3, 1e-9));
  });

  test('empty session: zero accuracy, zero stars', () {
    final sum = SessionSummary.of(StudySession(const []));
    expect(sum.answered, 0);
    expect(sum.accuracy, 0);
    expect(sum.stars, 0);
  });

  group('stars', () {
    int stars(int correct, int total) => SessionSummary(
      reviewed: total,
      newLearned: 0,
      answered: total,
      correct: correct,
    ).stars;

    test('3 stars at 80% or more', () {
      expect(stars(4, 5), 3);
      expect(stars(5, 5), 3);
    });
    test('2 stars at 50% or more', () {
      expect(stars(1, 2), 2);
      expect(stars(3, 5), 2);
    });
    test('always at least 1 star for trying', () {
      expect(stars(0, 3), 1);
      expect(stars(1, 4), 1);
    });
  });

  test('a quiz-wrong first answer counts as wrong', () {
    final s = play([newCat], [AnswerQuality.quizWrong, AnswerQuality.knew]);
    expect(SessionSummary.of(s).correct, 0);
  });
}
