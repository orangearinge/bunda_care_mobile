import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Prevent instantiation
  AppStyles._();

  // --- Colors ---
  static final Color primaryPink = Colors.pink[400]!;
  static final Color lightPink = Colors.pink[200]!;
  static final Color scaffoldBackground = Colors.white;
  static const Color surfaceColor = Colors.white;

  // --- Gradients ---
  static final Gradient pinkGradient = LinearGradient(
    colors: [primaryPink, lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Dimensions ---
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 30.0;

  // --- Theme Data ---
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryPink,
      scaffoldBackgroundColor: scaffoldBackground,

      // Default Typography (Poppins)
      textTheme: GoogleFonts.poppinsTextTheme(),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Elevated Button Theme (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),

      // Outlined Button Theme (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPink,
          side: BorderSide(color: primaryPink, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),

      // Input Decoration Theme (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50], // Or white depending on preference
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: lightPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }
}
