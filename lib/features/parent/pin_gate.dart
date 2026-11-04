import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'parent_providers.dart';

/// Shows [child] only when the parent area is unlocked; otherwise a PIN pad.
class ParentGate extends ConsumerWidget {
  const ParentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(parentUnlockedProvider) ? child : const PinGateScreen();
}

class PinGateScreen extends ConsumerStatefulWidget {
  const PinGateScreen({super.key});

  @override
  ConsumerState<PinGateScreen> createState() => _PinGateScreenState();
}

class _PinGateScreenState extends ConsumerState<PinGateScreen> {
  final _pin = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _checking = true);
    final ok = await ref.read(parentRepositoryProvider).verifyPin(_pin.text);
    if (!mounted) return;
    if (ok) {
      ref.read(parentUnlockedProvider.notifier).unlock();
    } else {
      setState(() {
        _error = 'Wrong PIN. Try again.';
        _checking = false;
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parents only')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('pin-field'),
                  controller: _pin,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Parent PIN',
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('unlock'),
                  onPressed: _checking ? null : _submit,
                  child: Text(_checking ? 'Checking…' : 'Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
