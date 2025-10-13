import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFB11116); // VVCOE Red
const kAccentColor = Color(0xFFFFD700); // Gold
const kBackgroundColor = Color(0xFFFFF8F8); // Light warm white
const kTextDark = Color(0xFF222222);
const kTextLight = Color(0xFF666666);

final ThemeData appTheme = ThemeData(
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: kTextDark, fontSize: 16),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kPrimaryColor,
      fontSize: 26,
      letterSpacing: 0.5,
    ),
    labelLarge: TextStyle(color: kTextLight),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
    ),
    labelStyle: const TextStyle(color: kTextLight),
  ),
);
