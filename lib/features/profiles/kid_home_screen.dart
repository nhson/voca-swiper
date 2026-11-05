import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';
import '../../ui/kid_screen.dart';
import '../../ui/mascot.dart';
import '../reminders/reminder_service.dart';
import '../session/session_providers.dart';
import 'profile_providers.dart';

/// A child's home: Sunny says what's waiting today, then Start.
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
    final look = KidLook.forAge(profile.age);
    final text = Theme.of(context).textTheme;
    final waiting = preview?.total ?? 0;
    final needsPlacement = profile.onboardedAt == null;
    final done = !needsPlacement && preview != null && waiting == 0;
    return KidScreen(
      look: look,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                _MyWordsButton(
                  onTap: () async {
                    await context.push('/kid/$profileId/progress');
                  },
                ),
                const SizedBox(width: 8),
                _NameBadge(avatar: profile.avatar, name: profile.name),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi ${profile.name}!',
                      textAlign: TextAlign.center,
                      style: text.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    if (needsPlacement)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: SpeechBubble(
                          child: Text(
                            "Let's play a word game and find the words "
                            'you know! 🔎',
                            key: const Key('waiting'),
                            textAlign: TextAlign.center,
                            style: text.titleLarge?.copyWith(fontSize: 19),
                          ),
                        ),
                      )
                    else if (preview != null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: SpeechBubble(
                          child: Column(
                            children: [
                              Text(
                                done
                                    ? 'All done for today! 🎉'
                                    : '$waiting '
                                          '${waiting == 1 ? 'word is' : 'words are'} '
                                          'waiting to say hi!',
                                key: const Key('waiting'),
                                textAlign: TextAlign.center,
                                style: text.titleLarge?.copyWith(fontSize: 19),
                              ),
                              if (done)
                                Text(
                                  'Come back tomorrow for more.',
                                  textAlign: TextAlign.center,
                                  style: text.bodyLarge?.copyWith(
                                    color: KidColors.inkSoft,
                                  ),
                                ),
                              if (!done) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (preview.reviews > 0)
                                      _Pill(
                                        '${preview.reviews} to review',
                                        const Color(0xFF4FA9FF),
                                      ),
                                    if (preview.newWords > 0)
                                      _Pill(
                                        '${preview.newWords} new',
                                        KidColors.knew,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Mascot(
                      mood: done ? MascotMood.sleepy : MascotMood.happy,
                      size: 170,
                    ),
                    const SizedBox(height: 20),
                    ChunkyButton(
                      key: const Key('start-session'),
                      color: look.accent,
                      semanticLabel: 'Start',
                      onPressed: needsPlacement
                          ? () async {
                              await context.push('/kid/$profileId/placement');
                              ref.invalidate(sessionPreviewProvider(profileId));
                              await ref.read(reminderServiceProvider).refresh();
                            }
                          : preview == null || done
                          ? null
                          : () async {
                              await context.push('/kid/$profileId/session');
                              ref.invalidate(sessionPreviewProvider(profileId));
                              // Answers moved review dates: re-plan reminders.
                              await ref.read(reminderServiceProvider).refresh();
                            },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 44,
                        vertical: 14,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 36),
                          SizedBox(width: 6),
                          Text("Let's go!", style: TextStyle(fontSize: 28)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameBadge extends StatelessWidget {
  const _NameBadge({required this.avatar, required this.name});

  final String avatar;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(avatar, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: KidColors.ink,
          ),
        ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: KidColors.shade(color, 0.12),
      ),
    ),
  );
}

class _MyWordsButton extends StatelessWidget {
  const _MyWordsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.9),
    shape: const StadiumBorder(),
    child: InkWell(
      key: const Key('open-progress'),
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 20)),
            SizedBox(width: 4),
            Text(
              'My words',
              style: TextStyle(
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: KidColors.ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
