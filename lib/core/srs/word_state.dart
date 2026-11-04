/// Learning state of a word for one profile (docs/SPEC.md — Spaced repetition).
///
/// New → Learning → Review → Mastered. A miss at any stage returns to Learning.
enum WordState { newWord, learning, review, mastered }

/// How the child answered a card. A wrong quiz answer overrides a "knew it" swipe.
enum AnswerQuality { knew, almost, didntKnow, quizWrong }
