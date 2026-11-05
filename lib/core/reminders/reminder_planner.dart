/// Plans the daily "words are waiting" notifications (docs/SPEC.md —
/// Knowledge reminders). Pure Dart; works in local wall-clock time.
///
/// A local notification can't check the database when it fires, so the app
/// plans the next week of reminders up front and re-plans whenever progress
/// or settings change. Each day's reminder counts the reviews that would be
/// due by then if the child doesn't study in between.
class ReminderSettings {
  const ReminderSettings({
    required this.minuteOfDay,
    required this.quietStartMinute,
    required this.quietEndMinute,
    required this.schoolBlock,
    required this.schoolStartMinute,
    required this.schoolEndMinute,
  });

  /// Minutes after local midnight; null means reminders are off.
  final int? minuteOfDay;
  final int quietStartMinute;
  final int quietEndMinute;

  /// Block Mon–Fri school hours.
  final bool schoolBlock;
  final int schoolStartMinute;
  final int schoolEndMinute;
}

/// One child's due-review times.
class LearnerDue {
  const LearnerDue({required this.name, required this.dueAt});

  final String name;
  final List<DateTime> dueAt;
}

class PlannedReminder {
  const PlannedReminder({
    required this.at,
    required this.title,
    required this.body,
    required this.dueCount,
  });

  /// Local time.
  final DateTime at;
  final String title;
  final String body;
  final int dueCount;
}

class ReminderPlanner {
  const ReminderPlanner();

  static const title = 'Sunny says hi! ☀️';

  /// Up to one reminder per day for [days] days from [now] (local).
  ///
  /// - In Mon–Fri school hours the reminder moves to when school ends.
  /// - Inside quiet hours it is skipped (never moved into the night).
  /// - Days with nothing due get no reminder.
  List<PlannedReminder> plan({
    required DateTime now,
    required ReminderSettings settings,
    required List<LearnerDue> learners,
    int days = 7,
  }) {
    final minute = settings.minuteOfDay;
    if (minute == null) return const [];
    final out = <PlannedReminder>[];
    for (var i = 0; i < days; i++) {
      var m = minute;
      final day = DateTime(now.year, now.month, now.day + i);
      final weekday = day.weekday <= DateTime.friday;
      if (settings.schoolBlock &&
          weekday &&
          _inWindow(m, settings.schoolStartMinute, settings.schoolEndMinute)) {
        m = settings.schoolEndMinute;
      }
      if (_inWindow(m, settings.quietStartMinute, settings.quietEndMinute)) {
        continue;
      }
      final at = DateTime(day.year, day.month, day.day, m ~/ 60, m % 60);
      if (!at.isAfter(now)) continue;

      final counts = [
        for (final l in learners)
          (l.name, l.dueAt.where((d) => !d.isAfter(at)).length),
      ].where((c) => c.$2 > 0).toList();
      final total = counts.fold(0, (a, c) => a + c.$2);
      if (total == 0) continue;
      out.add(
        PlannedReminder(
          at: at,
          title: title,
          body: _body(counts, total),
          dueCount: total,
        ),
      );
    }
    return out;
  }

  static String _waiting(int n) =>
      '$n ${n == 1 ? 'word is' : 'words are'} waiting to say hi!';

  static String _body(List<(String, int)> counts, int total) =>
      counts.length == 1
      ? '${counts.single.$1}, ${_waiting(total)}'
      : '${_waiting(total)} ${counts.map((c) => '${c.$1} ${c.$2}').join(' · ')}';

  /// [start, end) in minutes; wraps past midnight when start > end.
  static bool _inWindow(int m, int start, int end) {
    if (start == end) return false;
    return start < end ? m >= start && m < end : m >= start || m < end;
  }
}
