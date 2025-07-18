import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep black primary background
    primaryColor: const Color(0xFFFF0000), // Vibrant red accent
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF0000), // Red for buttons, EXP bars
      secondary: Color(0xFFFFD700), // Gold for level-up highlights
      surface: Color(0xFF333333), // Dark gray for secondary elements
      background: Color(0xFF121212),
      onPrimary: Color(0xFFFFFFFF), // White text on primary
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onBackground: Color(0xFFFFFFFF),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      // Add more styles as needed later
    ),
    // Future: Add theme selector for light/dark modes or customizations
  );
}