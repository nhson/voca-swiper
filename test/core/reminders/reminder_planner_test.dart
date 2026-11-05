import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/reminders/reminder_planner.dart';

void main() {
  // Wednesday 4 Nov 2026, 09:00 local.
  final now = DateTime(2026, 11, 4, 9);
  const planner = ReminderPlanner();

  ReminderSettings settings({
    int? at = 17 * 60, // 17:00
    bool school = true,
  }) => ReminderSettings(
    minuteOfDay: at,
    quietStartMinute: 21 * 60,
    quietEndMinute: 7 * 60,
    schoolBlock: school,
    schoolStartMinute: 7 * 60 + 30,
    schoolEndMinute: 16 * 60 + 30,
  );

  LearnerDue bi(List<DateTime> due) => LearnerDue(name: 'Bi', dueAt: due);

  test('reminders off: nothing planned', () {
    expect(
      planner.plan(
        now: now,
        settings: settings(at: null),
        learners: [
          bi([now]),
        ],
      ),
      isEmpty,
    );
  });

  test('no reviews due: nothing planned', () {
    expect(
      planner.plan(now: now, settings: settings(), learners: [bi([])]),
      isEmpty,
    );
  });

  test('one reminder per day while reviews are due, for a week', () {
    final r = planner.plan(
      now: now,
      settings: settings(),
      learners: [
        bi([now]),
      ],
    );
    expect(r, hasLength(7));
    expect(r.first.at, DateTime(2026, 11, 4, 17));
    expect(r.last.at, DateTime(2026, 11, 10, 17));
    expect(r.first.body, 'Bi, 1 word is waiting to say hi!');
    expect(r.first.dueCount, 1);
  });

  test('a day is skipped until its words are due', () {
    final r = planner.plan(
      now: now,
      settings: settings(),
      learners: [
        bi([DateTime(2026, 11, 6, 8), DateTime(2026, 11, 6, 12)]),
      ],
    );
    expect(r.first.at, DateTime(2026, 11, 6, 17));
    expect(r.first.body, 'Bi, 2 words are waiting to say hi!');
    expect(r, hasLength(5)); // 6th … 10th
  });

  test('words due after the reminder time wait for the next day', () {
    final r = planner.plan(
      now: now,
      settings: settings(),
      learners: [
        bi([DateTime(2026, 11, 4, 18)]),
      ],
    );
    expect(r.first.at, DateTime(2026, 11, 5, 17));
  });

  test("today's time already passed: start tomorrow", () {
    final r = planner.plan(
      now: DateTime(2026, 11, 4, 18),
      settings: settings(),
      learners: [
        bi([now]),
      ],
    );
    expect(r.first.at, DateTime(2026, 11, 5, 17));
  });

  test(
    'school hours move a weekday reminder to school end; weekends keep it',
    () {
      final r = planner.plan(
        now: now,
        settings: settings(at: 15 * 60),
        learners: [
          bi([now]),
        ],
      );
      // Wed–Fri moved to 16:30; Sat 7th and Sun 8th stay at 15:00.
      expect(r.map((x) => (x.at.day, x.at.hour, x.at.minute)), [
        (4, 16, 30),
        (5, 16, 30),
        (6, 16, 30),
        (7, 15, 0),
        (8, 15, 0),
        (9, 16, 30),
        (10, 16, 30),
      ]);
    },
  );

  test('school block off: weekday time is kept', () {
    final r = planner.plan(
      now: now,
      settings: settings(at: 15 * 60, school: false),
      learners: [
        bi([now]),
      ],
    );
    expect(r.first.at, DateTime(2026, 11, 4, 15));
  });

  test('a time inside quiet hours is skipped (overnight window)', () {
    for (final at in [21 * 60 + 30, 6 * 60]) {
      expect(
        planner.plan(
          now: now,
          settings: settings(at: at),
          learners: [
            bi([now]),
          ],
        ),
        isEmpty,
        reason: 'minute $at',
      );
    }
  });

  test('quiet hours that do not cross midnight', () {
    final s = ReminderSettings(
      minuteOfDay: 13 * 60,
      quietStartMinute: 12 * 60,
      quietEndMinute: 14 * 60,
      schoolBlock: false,
      schoolStartMinute: 0,
      schoolEndMinute: 0,
    );
    expect(
      planner.plan(
        now: now,
        settings: s,
        learners: [
          bi([now]),
        ],
      ),
      isEmpty,
    );
  });

  test('several children: one notification with the total and names', () {
    final r = planner.plan(
      now: now,
      settings: settings(),
      learners: [
        bi([now, now]),
        LearnerDue(name: 'An', dueAt: [now]),
        LearnerDue(name: 'Mi', dueAt: const []),
      ],
    );
    expect(r.first.dueCount, 3);
    expect(r.first.body, '3 words are waiting to say hi! Bi 2 · An 1');
  });

  group('weekly recap (feat-019)', () {
    PlannedReminder? weekly({
      DateTime? at,
      int minute = 17 * 60,
      List<WeeklyLearner>? learners,
    }) => planner.planWeekly(
      now: at ?? now,
      minute: minute,
      settings: settings(),
      learners:
          learners ??
          const [WeeklyLearner(name: 'Bi', newWords: 12, wordOfWeek: 'dog 🐶')],
    );

    test('once, on the coming Sunday at the reminder time', () {
      final r = weekly()!;
      expect(r.at, DateTime(2026, 11, 8, 17));
      expect(r.title, ReminderPlanner.weeklyTitle);
      expect(
        r.body,
        'Bi learned 12 new words this week! Word of the week: dog 🐶',
      );
    });

    test('on a Sunday before the time: today; after it: next Sunday', () {
      expect(
        weekly(at: DateTime(2026, 11, 8, 9))!.at,
        DateTime(2026, 11, 8, 17),
      );
      expect(
        weekly(at: DateTime(2026, 11, 8, 18))!.at,
        DateTime(2026, 11, 15, 17),
      );
    });

    test('several children: one message', () {
      final r = weekly(
        learners: const [
          WeeklyLearner(name: 'Bi', newWords: 12),
          WeeklyLearner(name: 'An', newWords: 0),
          WeeklyLearner(name: 'Mi', newWords: 1),
        ],
      )!;
      expect(r.body, 'New words this week: Bi 12 · Mi 1 🎉');
    });

    test('nobody learned anything → no recap', () {
      expect(
        weekly(learners: const [WeeklyLearner(name: 'Bi', newWords: 0)]),
        isNull,
      );
    });

    test('inside quiet hours → skipped, never moved into the night', () {
      expect(weekly(minute: 22 * 60), isNull);
    });

    test('school hours do not apply on Sunday', () {
      expect(weekly(minute: 10 * 60)!.at, DateTime(2026, 11, 8, 10));
    });
  });
}
