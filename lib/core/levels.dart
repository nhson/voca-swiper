/// CEFR levels used by the app, lowest first.
enum CefrLevel {
  preA1('preA1', 'Pre-A1'),
  a1('A1', 'A1'),
  a2('A2', 'A2'),
  b1('B1', 'B1'),
  b2('B2', 'B2');

  const CefrLevel(this.code, this.label);

  /// Stored value (matches the word bank's `cefr` field).
  final String code;
  final String label;

  static CefrLevel fromCode(String code) =>
      values.firstWhere((l) => l.code == code);

  /// Default starting level by age band (docs/SPEC.md — Age bands), capped to
  /// levels that have content.
  static CefrLevel defaultForAge(int age, {CefrLevel maxAvailable = a1}) {
    final byAge = age <= 6
        ? preA1
        : age <= 9
            ? a1
            : age <= 12
                ? a2
                : b1;
    return byAge.index <= maxAvailable.index ? byAge : maxAvailable;
  }
}
