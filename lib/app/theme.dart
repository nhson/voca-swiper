import 'package:flutter/material.dart';

import '../ui/kid_look.dart';

/// App theme: Baloo 2 (rounded, playful) for headings, Nunito for body
/// text; both bundled (OFL, assets/fonts) and cover Vietnamese.
ThemeData buildTheme() {
  const ink = KidColors.ink;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7B5CFF),
    surface: const Color(0xFFFBF9FF),
  ).copyWith(onSurface: ink);

  TextStyle display(double size, [FontWeight w = FontWeight.w800]) => TextStyle(
    fontFamily: 'Baloo2',
    fontSize: size,
    fontWeight: w,
    height: 1.15,
    color: ink,
  );
  TextStyle body(double size, [FontWeight w = FontWeight.w600]) => TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontWeight: w,
    height: 1.35,
    color: ink,
  );

  final text = TextTheme(
    displayLarge: display(64),
    displayMedium: display(52),
    displaySmall: display(40),
    headlineLarge: display(34),
    headlineMedium: display(30),
    headlineSmall: display(24, FontWeight.w700),
    titleLarge: body(21, FontWeight.w800),
    titleMedium: body(17, FontWeight.w700),
    titleSmall: body(15, FontWeight.w700),
    bodyLarge: body(17),
    bodyMedium: body(15),
    bodySmall: body(13),
    labelLarge: body(15, FontWeight.w800),
    labelMedium: body(13, FontWeight.w700),
    labelSmall: body(11, FontWeight.w700),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Nunito',
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: ink,
      titleTextStyle: display(24, FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFECE8F5), width: 1.5),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: display(20, FontWeight.w700),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: body(16, FontWeight.w800),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: body(15, FontWeight.w800)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2DDEF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2DDEF)),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: body(15, FontWeight.w700),
      shape: const StadiumBorder(),
    ),
  );
}
