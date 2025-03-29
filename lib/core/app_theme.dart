import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFFBB86FC);
  static const Color darkBlue = Color(0xFF1F265E);
  static const Color periwinkle = Color(0xFF8E97FD);
  static const Color lightPurple = Color(0xFFF6F1FB);
  static const Color lightGray = Color(0xFFEBEAEC);
  static const Color blueGray = Color(0xFFE6E7F2);
  static const Color peach = Color(0xFFFFECCC);
  static const Color gray = Color(0xFFD9D9D9);
  static const Color darkGray = Color(0xFF1E1E1E);
  static const Color green = Color(0xFF02FF4E);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: white,
      );

  static TextStyle get titleStyle => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: white,
      );

  static TextStyle get subtitleStyle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: white,
      );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: white,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: primary,
      ),
      scaffoldBackgroundColor: primary,
      textTheme: TextTheme(
        headlineLarge: headingStyle,
        titleLarge: titleStyle,
        titleMedium: subtitleStyle,
        bodyMedium: bodyStyle,
        labelLarge: buttonTextStyle,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: buttonTextStyle,
        ),
      ),
      cardTheme: CardTheme(
        color: white.withAlpha(25),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: white.withAlpha(51), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: white.withAlpha(76), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

