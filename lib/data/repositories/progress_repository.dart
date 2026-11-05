import 'package:drift/drift.dart';

import '../../core/progress/progress_stats.dart';
import '../../core/progress/retention.dart';
import '../../core/quiz/quiz_builder.dart';
import '../../core/srs/word_schedule.dart';
import '../db/app_database.dart';

class ProgressRepository {
  ProgressRepository(this.db);

  final AppDatabase db;

  Future<Map<String, WordSchedule>> schedules(int profileId) async {
    final rows = await (db.select(
      db.wordProgress,
    )..where((p) => p.profileId.equals(profileId))).get();
    return {for (final r in rows) r.wordId: _toSchedule(r)};
  }

  /// Words first shown to the profile at or after [since].
  Future<int> newIntroducedSince(int profileId, DateTime since) {
    final p = db.wordProgress;
    final count = p.wordId.count();
    final q = db.selectOnly(p)
      ..addColumns([count])
      ..where(
        p.profileId.equals(profileId) &
            p.firstSeenAt.isBiggerOrEqualValue(since),
      );
    return q.map((r) => r.read(count)!).getSingle();
  }

  /// Saves the scheduler result for one word. [now] becomes firstSeenAt for a
  /// word the profile has not seen before; later saves keep the original.
  Future<void> save(
    int profileId,
    String wordId,
    WordSchedule s, {
    required DateTime now,
  }) {
    final row = WordProgressCompanion.insert(
      profileId: profileId,
      wordId: wordId,
      state: s.state,
      easeFactor: s.easeFactor,
      intervalDays: s.intervalDays,
      repetitions: s.repetitions,
      nextReviewAt: Value(s.nextReviewAt),
      lastAnsweredAt: Value(s.lastAnsweredAt),
      correctCount: s.correctCount,
      wrongCount: s.wrongCount,
      firstSeenAt: now,
    );
    return db
        .into(db.wordProgress)
        .insert(
          row,
          onConflict: DoUpdate(
            (_) => row.copyWith(firstSeenAt: const Value.absent()),
          ),
        );
  }

  Future<void> logSession({
    required int profileId,
    required DateTime startedAt,
    required int durationSec,
    required int reviewed,
    required int newLearned,
    required double accuracy,
  }) => db
      .into(db.sessionLogs)
      .insert(
        SessionLogsCompanion.insert(
          profileId: profileId,
          startedAt: startedAt,
          durationSec: durationSec,
          reviewed: reviewed,
          newLearned: newLearned,
          accuracy: accuracy,
        ),
      );

  /// Logged sessions for the progress screen, oldest first.
  Future<List<SessionStat>> sessionStats(int profileId) async {
    final rows =
        await (db.select(db.sessionLogs)
              ..where((l) => l.profileId.equals(profileId))
              ..orderBy([(l) => OrderingTerm.asc(l.startedAt)]))
            .get();
    return [
      for (final r in rows)
        SessionStat(
          startedAt: r.startedAt.toUtc(),
          durationSec: r.durationSec,
          answered: r.reviewed + r.newLearned,
          accuracy: r.accuracy,
        ),
    ];
  }

  /// Next review date of every word the profile has progress on (UTC), for
  /// reminder planning.
  Future<List<DateTime>> reviewDates(int profileId) async {
    final rows =
        await (db.select(db.wordProgress)..where(
              (p) => p.profileId.equals(profileId) & p.nextReviewAt.isNotNull(),
            ))
            .get();
    return [for (final r in rows) r.nextReviewAt!.toUtc()];
  }

  /// Records one quiz answer (feat-013).
  Future<void> logQuiz({
    required int profileId,
    required String wordId,
    required QuizKind kind,
    required bool correct,
    required DateTime at,
  }) => db
      .into(db.quizLogs)
      .insert(
        QuizLogsCompanion.insert(
          profileId: profileId,
          wordId: wordId,
          kind: kind.name,
          correct: correct,
          answeredAt: at,
        ),
      );

  /// Every quiz answer of the profile, oldest first (UTC).
  Future<List<QuizAnswer>> quizAnswers(int profileId) async {
    final rows =
        await (db.select(db.quizLogs)
              ..where((q) => q.profileId.equals(profileId))
              ..orderBy([
                (q) => OrderingTerm.asc(q.answeredAt),
                (q) => OrderingTerm.asc(q.id),
              ]))
            .get();
    return [
      for (final r in rows)
        QuizAnswer(
          wordId: r.wordId,
          correct: r.correct,
          answeredAt: r.answeredAt.toUtc(),
        ),
    ];
  }

  /// When each word was first shown to the profile (UTC).
  Future<Map<String, DateTime>> firstSeen(int profileId) async {
    final rows = await (db.select(
      db.wordProgress,
    )..where((p) => p.profileId.equals(profileId))).get();
    return {for (final r in rows) r.wordId: r.firstSeenAt.toUtc()};
  }

  /// "Remembered after 2 weeks" for the profile.
  Future<Retention> retention(int profileId) async => Retention.compute(
    answers: await quizAnswers(profileId),
    firstSeen: await firstSeen(profileId),
  );

  static WordSchedule _toSchedule(WordProgressRow r) => WordSchedule(
    state: r.state,
    easeFactor: r.easeFactor,
    intervalDays: r.intervalDays,
    repetitions: r.repetitions,
    nextReviewAt: r.nextReviewAt?.toUtc(),
    lastAnsweredAt: r.lastAnsweredAt?.toUtc(),
    correctCount: r.correctCount,
    wrongCount: r.wrongCount,
  );
}
