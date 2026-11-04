import 'package:flutter/material.dart';

/// Root widget. Routing (go_router) and state (Riverpod) arrive with feat-002+.
class VocaSwiperApp extends StatelessWidget {
  const VocaSwiperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voca Swiper',
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Voca Swiper')),
      ),
    );
  }
}
