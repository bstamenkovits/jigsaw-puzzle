import 'package:flutter/material.dart';

class AppStyle {
  // Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFF3D5AFE);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color success = Color(0xFF00E676);
  static const Color border = Color(0xFF333333);

  // Dimensions
  static const double borderRadius = 24.0;
  static const double borderWidth = 1.0;
  static const double paddingLarge = 24.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 8.0;

  // Text Styles
  static const TextStyle heading = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle body = TextStyle(
    color: textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonLabel = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Decorative
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: border, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
