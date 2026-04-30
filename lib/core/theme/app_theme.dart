import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color gold = Color(0xFFC5A059);
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: gold,
        surface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardColor: const Color(0xFFF7F7F7),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: gold,
        surface: Color(0xFF1E1E1E),
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E1E1E),
      useMaterial3: true,
    );
  }
}
