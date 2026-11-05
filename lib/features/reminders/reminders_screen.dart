import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/reminders/reminder_planner.dart';
import '../../data/db/app_database.dart';
import '../parent/parent_providers.dart';
import '../parent/pin_gate.dart';
import 'reminder_notifier.dart';
import 'reminder_service.dart';
import '../../ui/readable_width.dart';

String formatMinute(BuildContext context, int m) => MaterialLocalizations.of(
  context,
).formatTimeOfDay(TimeOfDay(hour: m ~/ 60, minute: m % 60));

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Parent settings for the daily reminder (docs/SPEC.md — Knowledge
/// reminders): time, quiet hours, school hours, and what's planned next.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  static const defaultMinute = 18 * 60;

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  Future<List<PlannedReminder>>? _plan;

  @override
  void initState() {
    super.initState();
    _plan = ref.read(reminderServiceProvider).plan();
  }

  Future<void> _save(
    ParentAccountRow a, {
    int? Function()? minute,
    int? quietStart,
    int? quietEnd,
    bool? school,
    int? schoolStart,
    int? schoolEnd,
  }) async {
    await ref
        .read(parentRepositoryProvider)
        .updateReminders(
          reminderMinuteOfDay: minute != null
              ? minute()
              : a.reminderMinuteOfDay,
          quietStartMinute: quietStart ?? a.quietStartMinute,
          quietEndMinute: quietEnd ?? a.quietEndMinute,
          blockSchoolHours: school ?? a.blockSchoolHours,
          schoolStartMinute: schoolStart ?? a.schoolStartMinute,
          schoolEndMinute: schoolEnd ?? a.schoolEndMinute,
        );
    final plan = ref.read(reminderServiceProvider).refresh();
    if (mounted) {
      setState(() {
        _plan = plan;
      });
    }
  }

  Future<void> _toggle(ParentAccountRow a, bool on) async {
    if (on) {
      final allowed = await ref
          .read(reminderNotifierProvider)
          .requestPermission();
      if (!allowed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            key: Key('permission-denied'),
            content: Text(
              'Notifications are off for Voca Swiper. Turn them on in the '
              "device's Settings to get reminders.",
            ),
          ),
        );
      }
    }
    await _save(a, minute: () => on ? RemindersScreen.defaultMinute : null);
  }

  Future<int?> _pick(int current) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(parentAccountProvider).value;
    return ParentGate(
      child: Scaffold(
        appBar: AppBar(title: const Text('Daily reminder')),
        body: a == null
            ? const Center(child: CircularProgressIndicator())
            : _body(context, a),
      ),
    );
  }

  Widget _body(BuildContext context, ParentAccountRow a) {
    final text = Theme.of(context).textTheme;
    final on = a.reminderMinuteOfDay != null;
    Widget timeTile(
      String key,
      String title,
      int minute,
      void Function(int) onPicked, {
      bool enabled = true,
    }) => ListTile(
      key: Key(key),
      enabled: enabled,
      title: Text(title),
      trailing: Text(formatMinute(context, minute), style: text.titleMedium),
      onTap: () async {
        final m = await _pick(minute);
        if (m != null) onPicked(m);
      },
    );

    return ListView(
      padding: readablePadding(context),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                key: const Key('reminder-toggle'),
                title: const Text('Remind us every day'),
                subtitle: const Text(
                  'Only on days when words are due for review',
                ),
                value: on,
                onChanged: (v) => _toggle(a, v),
              ),
              if (on)
                timeTile(
                  'reminder-time',
                  'Time',
                  a.reminderMinuteOfDay!,
                  (m) => _save(a, minute: () => m),
                ),
            ],
          ),
        ),
        if (on) ...[
          const SizedBox(height: 8),
          _NextReminder(plan: _plan),
          const SizedBox(height: 16),
          Text('Quiet hours', style: text.titleMedium),
          Text(
            'No reminders during this time.',
            style: text.bodyMedium?.copyWith(color: Colors.black54),
          ),
          Card(
            child: Column(
              children: [
                timeTile(
                  'quiet-start',
                  'From',
                  a.quietStartMinute,
                  (m) => _save(a, quietStart: m),
                ),
                timeTile(
                  'quiet-end',
                  'To',
                  a.quietEndMinute,
                  (m) => _save(a, quietEnd: m),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('School time', style: text.titleMedium),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('school-toggle'),
                  title: const Text('Wait until school is out (Mon–Fri)'),
                  subtitle: const Text(
                    'A reminder during school hours moves to when school ends',
                  ),
                  value: a.blockSchoolHours,
                  onChanged: (v) => _save(a, school: v),
                ),
                timeTile(
                  'school-start',
                  'School starts',
                  a.schoolStartMinute,
                  (m) => _save(a, schoolStart: m),
                  enabled: a.blockSchoolHours,
                ),
                timeTile(
                  'school-end',
                  'School ends',
                  a.schoolEndMinute,
                  (m) => _save(a, schoolEnd: m),
                  enabled: a.blockSchoolHours,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _NextReminder extends StatelessWidget {
  const _NextReminder({required this.plan});

  final Future<List<PlannedReminder>>? plan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FutureBuilder(
      future: plan,
      builder: (context, snap) {
        final p = snap.data;
        if (p == null) return const SizedBox(height: 56);
        final String label;
        if (p.isEmpty) {
          label =
              'Nothing is due in the next 7 days, so no reminder is planned.';
        } else {
          final r = p.first;
          final at = r.at;
          label =
              'Next: ${_weekdays[at.weekday - 1]} ${at.day} '
              '${_months[at.month - 1]}, '
              '${formatMinute(context, at.hour * 60 + at.minute)}\n'
              '“${r.body}”';
        }
        return Card(
          color: const Color(0xFFF3F0FF),
          child: ListTile(
            leading: const Text('☀️', style: TextStyle(fontSize: 28)),
            title: Text(label, key: const Key('next-reminder')),
            titleTextStyle: text.bodyLarge,
          ),
        );
      },
    );
  }
}
