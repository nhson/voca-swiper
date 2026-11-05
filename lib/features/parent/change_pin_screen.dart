import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/security/pin_hasher.dart';
import '../../ui/pin_boxes.dart';
import 'pin_gate.dart';
import '../../ui/readable_width.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!PinHasher.isValidNewPin(_pin.text) ||
        !PinHasher.isValidNewPin(_confirm.text)) {
      setState(() => _error = 'Enter all 6 digits.');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'The two PINs are different.');
      return;
    }
    await ref.read(parentRepositoryProvider).changePin(_pin.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN changed')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ParentGate(
    child: Scaffold(
      appBar: AppBar(title: const Text('Change PIN')),
      body: ListView(
        padding: readablePadding(context, side: 24, top: 24, bottom: 24),
        children: [
          PinBoxes(
            key: const Key('change-pin'),
            controller: _pin,
            autofocus: true,
            label: 'New PIN (6 digits)',
            onCompleted: (_) => _confirmFocus.requestFocus(),
          ),
          const SizedBox(height: 20),
          PinBoxes(
            key: const Key('change-confirm'),
            controller: _confirm,
            focusNode: _confirmFocus,
            label: 'Repeat PIN',
            errorText: _error,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('change-save'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
