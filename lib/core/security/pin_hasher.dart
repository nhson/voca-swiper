import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted, iterated SHA-256 for the parent PIN. A 4–6 digit PIN is a gate for
/// children, not strong security; this keeps it out of the database in clear.
class PinHasher {
  const PinHasher({this.iterations = 10000});

  final int iterations;

  static final _pinPattern = RegExp(r'^\d{4,6}$');

  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  String newSalt([Random? random]) {
    final r = random ?? Random.secure();
    return base64UrlEncode(List.generate(16, (_) => r.nextInt(256)));
  }

  String hash(String pin, String salt) {
    List<int> bytes = utf8.encode('$salt:$pin');
    for (var i = 0; i < iterations; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64UrlEncode(bytes);
  }

  bool verify(String pin, {required String salt, required String hash}) {
    final actual = this.hash(pin, salt);
    if (actual.length != hash.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ hash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
