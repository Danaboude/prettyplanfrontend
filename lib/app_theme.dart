import 'package:flutter/material.dart';

class AppTheme {
  static const Color blushPink = Color(0xFFFADADD);
  static const Color roseGold = Color(0xFfcbacec);
  static const Color ivoryWhite = Color(0xFFFFF9F9);
  static const Color sageGreen = Color(0xFFC3E4C2);

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ivoryWhite,
    fontFamily: 'PlayfairDisplay',

    colorScheme: ColorScheme.fromSeed(
      seedColor: roseGold,
      primary: roseGold,
      secondary: blushPink,
      background: ivoryWhite,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onBackground: Colors.black,
      onSurface: Colors.black87,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: roseGold,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'PlayfairDisplay',
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: roseGold,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: roseGold,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  );
}
