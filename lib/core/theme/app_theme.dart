import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Authentic Swiggy & Zomato Clean White Light Theme
class AppTheme {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFFC8019); // Swiggy Iconic Orange
  static const Color primaryAmber = Color(0xFFFFA700);  // Swiggy One Gold
  static const Color swiggyOneGold = Color(0xFFFF9F1C);
  static const Color swiggyOneBg = Color(0xFFFFF8E7);
  
  // Background & Surfaces (Clean Light Mode)
  static const Color lightBackground = Color(0xFFF4F5F7); // Crisp Swiggy page bg
  static const Color lightSurface = Color(0xFFFFFFFF);    // Pure White surface
  static const Color lightCard = Color(0xFFFFFFFF);       // Pure White cards
  static const Color lightInput = Color(0xFFF0F1F5);      // Soft grey for search & inputs
  static const Color lightDivider = Color(0xFFE9ECEF);    // Crisp divider

  // Semantic Colors
  static const Color emeraldGreen = Color(0xFF60B246);   // Swiggy Rating / Veg Green
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color dangerRed = Color(0xFFE43B4F);      // Non-veg & alerts
  static const Color textDark = Color(0xFF1C1C24);       // Deep Charcoal Header Text
  static const Color textMuted = Color(0xFF686B78);      // Swiggy classic subtext grey
  static const Color textLight = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    final fontName = GoogleFonts.outfit().fontFamily;
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: primaryAmber,
        surface: lightSurface,
        background: lightBackground,
        error: dangerRed,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.04),
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      textTheme: baseTextTheme.apply(
        fontFamily: fontName,
        bodyColor: textDark,
        displayColor: textDark,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightDivider, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurface,
        selectedColor: primaryOrange,
        secondarySelectedColor: primaryOrange,
        labelStyle: TextStyle(fontFamily: fontName, color: textDark, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: lightDivider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
        hintStyle: TextStyle(fontFamily: fontName, color: textMuted, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
