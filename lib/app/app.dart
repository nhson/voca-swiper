import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/reminders/reminder_refresher.dart';
import 'router.dart';
import 'theme.dart';

class VocaSwiperApp extends StatefulWidget {
  const VocaSwiperApp({super.key});

  @override
  State<VocaSwiperApp> createState() => _VocaSwiperAppState();
}

class _VocaSwiperAppState extends State<VocaSwiperApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Voca Swiper',
    theme: buildTheme(),
    routerConfig: _router,
    builder: (context, child) => ReminderRefresher(child: child!),
  );
}
