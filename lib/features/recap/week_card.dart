import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/word_repository.dart';
import '../../ui/kid_look.dart';
import '../session/speaker.dart';
import 'recap_service.dart';

/// "This week" on the child home (feat-019): new words, minutes, the word
/// of the week, and 1–2 mastered words to recall so they don't fade.
class WeekCard extends ConsumerWidget {
  const WeekCard({super.key, required this.profileId, required this.look});

  final int profileId;
  final KidLook look;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(weeklyRecapProvider(profileId)).value;
    if (data == null || data.recap.isEmpty) return const SizedBox.shrink();
    final r = data.recap;
    final say = ref.read(speakerProvider).say;
    final best = data.wordOfWeek;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        key: const Key('week-card'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            const Text('⭐ This week', style: _title),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _Stat(
                  key: const Key('week-new'),
                  text:
                      '🆕 ${r.newWords} new ${r.newWords == 1 ? 'word' : 'words'}',
                  color: KidColors.knew,
                ),
                _Stat(
                  key: const Key('week-minutes'),
                  text: '⏱ ${r.minutes} min',
                  color: look.accent,
                ),
              ],
            ),
            if (best != null) ...[
              const SizedBox(height: 10),
              const Text('Word of the week', style: _label),
              const SizedBox(height: 4),
              InkWell(
                key: const Key('week-word'),
                borderRadius: BorderRadius.circular(18),
                onTap: () => say(best.word.word),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (best.word.emoji case final e?)
                        Text(e, style: const TextStyle(fontSize: 34)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          best.word.word,
                          style: _word,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: KidColors.inkSoft,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (data.recall.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Still remember these?', style: _label),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in data.recall) _RecallChip(card: c, say: say),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _title = TextStyle(
    fontFamily: 'Baloo2',
    fontWeight: FontWeight.w800,
    fontSize: 22,
    color: KidColors.ink,
  );
  static const _label = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: KidColors.inkSoft,
  );
  static const _word = TextStyle(
    fontFamily: 'Baloo2',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    color: KidColors.ink,
  );
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: KidColors.shade(color, 0.12),
      ),
    ),
  );
}

/// A mastered word: tap to hear it and see what it means.
class _RecallChip extends StatefulWidget {
  const _RecallChip({required this.card, required this.say});

  final WordCard card;
  final void Function(String) say;

  @override
  State<_RecallChip> createState() => _RecallChipState();
}

class _RecallChipState extends State<_RecallChip> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.card.word;
    final meaning = widget.card.translation ?? w.definition;
    return Material(
      color: KidColors.pastelFor(w.id),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('recall-${w.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          widget.say(w.word);
          setState(() => _open = true);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                [?w.emoji, w.word].join(' '),
                style: const TextStyle(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: KidColors.ink,
                ),
              ),
              if (_open && meaning.isNotEmpty)
                Text(
                  meaning,
                  key: Key('recall-meaning-${w.id}'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: KidColors.inkSoft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
