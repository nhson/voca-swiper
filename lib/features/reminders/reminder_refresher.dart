import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reminder_service.dart';

/// Re-plans reminders when the app starts and whenever it comes back to the
/// foreground (days may have passed; due counts change).
class ReminderRefresher extends ConsumerStatefulWidget {
  const ReminderRefresher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderRefresher> createState() => _ReminderRefresherState();
}

class _ReminderRefresherState extends ConsumerState<ReminderRefresher>
    with WidgetsBindingObserver {
  late final ReminderService _service = ref.read(reminderServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _service.refresh();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
