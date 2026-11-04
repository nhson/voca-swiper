import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Root widget. Routing (go_router) arrives with feat-005.
class VocaSwiperApp extends StatelessWidget {
  const VocaSwiperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voca Swiper',
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const _Home(),
    );
  }
}

class _Home extends ConsumerWidget {
  const _Home();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(wordCountProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Voca Swiper'),
            Text(count.when(
              data: (n) => '$n words ready',
              loading: () => '…',
              error: (e, _) => 'Error: $e',
            )),
          ],
        ),
      ),
    );
  }
}
