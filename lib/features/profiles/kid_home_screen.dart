import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../session/session_providers.dart';
import 'profile_providers.dart';

/// A child's home: greeting, what's waiting today, and Start.
class KidHomeScreen extends ConsumerWidget {
  const KidHomeScreen({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(profileId)).value;
    final preview = ref.watch(sessionPreviewProvider(profileId)).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final text = Theme.of(context).textTheme;
    final waiting = preview?.total ?? 0;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(profile.avatar, style: const TextStyle(fontSize: 96)),
              Text('Hi ${profile.name}!', style: text.headlineMedium),
              const SizedBox(height: 12),
              if (preview != null)
                Text(
                  waiting == 0
                      ? 'All done for today! 🎉'
                      : '$waiting ${waiting == 1 ? 'word is' : 'words are'} '
                            'waiting to say hi!',
                  key: const Key('waiting'),
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
              if (preview != null && waiting > 0)
                Text(
                  [
                    if (preview.reviews > 0) '${preview.reviews} to review',
                    if (preview.newWords > 0) '${preview.newWords} new',
                  ].join(' · '),
                  style: text.bodyLarge,
                ),
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const Key('start-session'),
                onPressed: preview == null || waiting == 0
                    ? null
                    : () async {
                        await context.push('/kid/$profileId/session');
                        ref.invalidate(sessionPreviewProvider(profileId));
                      },
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
