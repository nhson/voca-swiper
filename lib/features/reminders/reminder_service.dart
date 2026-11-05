import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/reminders/reminder_planner.dart';
import '../../core/srs/word_state.dart';
import '../../data/db/app_database.dart';
import 'reminder_notifier.dart';

/// Re-plans the week of reminders from the current settings and progress.
/// Call after anything that changes them: app start/resume, a finished
/// session, reminder settings, profile reset/delete.
class ReminderService {
  ReminderService(this._ref);

  final Ref _ref;
  static const planner = ReminderPlanner();

  static ReminderSettings settingsOf(ParentAccountRow a) => ReminderSettings(
    minuteOfDay: a.reminderMinuteOfDay,
    quietStartMinute: a.quietStartMinute,
    quietEndMinute: a.quietEndMinute,
    schoolBlock: a.blockSchoolHours,
    schoolStartMinute: a.schoolStartMinute,
    schoolEndMinute: a.schoolEndMinute,
  );

  /// The plan for the coming week (also shown in the parent area).
  Future<List<PlannedReminder>> plan() async {
    final account = await _ref.read(parentRepositoryProvider).account();
    if (account == null) return const [];
    final profiles = await _ref.read(profileRepositoryProvider).all();
    final progress = _ref.read(progressRepositoryProvider);
    final learners = [
      for (final p in profiles)
        LearnerDue(
          name: p.name,
          dueAt: [
            for (final s in (await progress.schedules(p.id)).values)
              if (s.state != WordState.newWord && s.nextReviewAt != null)
                s.nextReviewAt!.toLocal(),
          ],
        ),
    ];
    final now = _ref.read(clockProvider)().toLocal();
    return planner.plan(
      now: now,
      settings: settingsOf(account),
      learners: learners,
    );
  }

  Future<List<PlannedReminder>> refresh() async {
    final p = await plan();
    await _ref.read(reminderNotifierProvider).replace(p);
    return p;
  }
}

final reminderServiceProvider = Provider(ReminderService.new);
