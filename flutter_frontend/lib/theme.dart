import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFB11116);
const kAccentColor = Color(0xFFE8B24F);
const kBackgroundColor = Color(0xFFF5F7FB);
const kSurfaceTint = Color(0xFFFFF6EF);
const kTextDark = Color(0xFF1F2937);
const kTextLight = Color(0xFF6B7280);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    primary: kPrimaryColor,
    secondary: kAccentColor,
    surface: Colors.white,
  ),
  cardTheme: CardThemeData(
    elevation: 5,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: kTextDark, fontSize: 16),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kPrimaryColor,
      fontSize: 26,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(color: kTextLight),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    labelStyle: const TextStyle(color: kTextLight),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kSurfaceTint,
    selectedColor: kPrimaryColor.withValues(alpha: 0.14),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
