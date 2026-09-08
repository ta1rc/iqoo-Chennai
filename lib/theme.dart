import 'package:flutter/material.dart';

/// Nazar visual tokens — notice-paper and ink stamp, not a hacker dashboard.
class NazarColors {
  static const paper = Color(0xFFEDEFF2);
  static const ink = Color(0xFF14181D);
  static const rule = Color(0xFFC8CCD2);
  static const safe = Color(0xFF2F6F5B);
  static const caution = Color(0xFFB4762A);
  static const danger = Color(0xFFA3231E);
}

class NazarTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NazarColors.paper,
      fontFamily: 'IBMPlexSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: NazarColors.ink,
        brightness: Brightness.light,
        surface: NazarColors.paper,
      ),
      dividerColor: NazarColors.rule,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: NazarColors.ink,
        displayColor: NazarColors.ink,
        fontFamily: 'IBMPlexSans',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NazarColors.paper,
        foregroundColor: NazarColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}

const String monoFontFamily = 'IBMPlexMono';
