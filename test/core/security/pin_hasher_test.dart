import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/security/pin_hasher.dart';

void main() {
  const hasher = PinHasher(iterations: 100);

  test('verifies the right PIN and rejects a wrong one', () {
    final salt = hasher.newSalt();
    final hash = hasher.hash('1234', salt);
    expect(hasher.verify('1234', salt: salt, hash: hash), isTrue);
    expect(hasher.verify('1235', salt: salt, hash: hash), isFalse);
  });

  test('hash does not contain the PIN and differs per salt', () {
    final a = hasher.hash('1234', 'salt-a');
    final b = hasher.hash('1234', 'salt-b');
    expect(a, isNot(contains('1234')));
    expect(a, isNot(b));
  });

  test('valid PINs are 4–6 digits', () {
    expect(PinHasher.isValidPin('1234'), isTrue);
    expect(PinHasher.isValidPin('123456'), isTrue);
    expect(PinHasher.isValidPin('123'), isFalse);
    expect(PinHasher.isValidPin('12a4'), isFalse);
    expect(PinHasher.isValidPin('1234567'), isFalse);
  });

  test('new PINs are exactly 6 digits; older 4–5 digit PINs still unlock', () {
    expect(PinHasher.newPinLength, 6);
    expect(PinHasher.isValidNewPin('123456'), isTrue);
    expect(PinHasher.isValidNewPin('1234'), isFalse);
    expect(PinHasher.isValidNewPin('12345a'), isFalse);
    expect(PinHasher.isValidNewPin('1234567'), isFalse);
    expect(PinHasher.isValidPin('1234'), isTrue, reason: 'existing PINs');
  });
}
