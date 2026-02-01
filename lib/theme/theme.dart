import 'package:flutter/material.dart';

class AppTheme {
  static const seedBlue = Color(0xFF3A7BD5);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedBlue, brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFEFF6FF),
    textTheme: ThemeData.light().textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: seedBlue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedBlue, brightness: Brightness.dark),
    textTheme: ThemeData(brightness: Brightness.dark).textTheme,
  );
}
