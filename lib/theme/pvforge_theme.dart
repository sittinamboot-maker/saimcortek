import 'package:flutter/material.dart';

abstract final class PVForgeColors {
  static const background = Color(0xFFF5FBFE);
  static const backgroundHighlight = Color(0xFFE1F5FE);
  static const primaryLight = Color(0xFFB3E5FC);
  static const activeBlue = Color(0xFF29B6F6);
  static const primary = activeBlue;
  static const accent = activeBlue;
  static const solar = activeBlue;
  static const battery = Color(0xFF25B56A);
  static const grid = Color(0xFF8B95A5);
  static const load = Color(0xFF4D82FF);
  static const warning = Color(0xFFF59E0B);
  static const critical = Color(0xFFEF4444);
  static const card = Colors.white;
  static const text = Color(0xFF18202A);
  static const secondaryText = Color(0xFF7A8491);
  static const divider = Color(0xFFE5EAF0);
}

ThemeData buildPVForgeTheme({bool monochrome = false}) {
  final primary = monochrome ? const Color(0xFF424242) : PVForgeColors.primary;
  final scheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
    primary: primary,
    onPrimary: Colors.white,
    secondary: monochrome ? const Color(0xFF616161) : PVForgeColors.activeBlue,
    onSecondary: PVForgeColors.text,
    primaryContainer: monochrome
        ? const Color(0xFFE2E2E2)
        : PVForgeColors.backgroundHighlight,
    secondaryContainer: monochrome
        ? const Color(0xFFE8E8E8)
        : PVForgeColors.backgroundHighlight,
    surface: Colors.white,
    onSurface: PVForgeColors.text,
    outlineVariant: PVForgeColors.divider,
  );
  return ThemeData(
    fontFamily: 'NotoSansThai',
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withValues(alpha: .88),
      foregroundColor: PVForgeColors.text,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: PVForgeColors.text,
        fontFamily: 'NotoSansThai',
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: const Color(0x220277BD),
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: .42),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: .82), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor:
            monochrome ? const Color(0xFF424242) : PVForgeColors.activeBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            monochrome ? const Color(0xFFBDBDBD) : PVForgeColors.primaryLight,
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            monochrome ? const Color(0xFF424242) : PVForgeColors.activeBlue,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            monochrome ? const Color(0xFF303030) : const Color(0xFF0277BD),
        side: BorderSide(
          color:
              monochrome ? const Color(0xFF616161) : PVForgeColors.activeBlue,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:
            monochrome ? const Color(0xFF303030) : const Color(0xFF0277BD),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor:
            monochrome ? const Color(0xFF303030) : const Color(0xFF0277BD),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (monochrome
                  ? const Color(0xFF424242)
                  : PVForgeColors.activeBlue)
              : Colors.white.withValues(alpha: .72),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : PVForgeColors.text,
        ),
      ),
    ),
  );
}
