import 'package:flutter/material.dart';

class AppConstants {
  // Colors (matching theme)
  static const Color primaryBackground = Color(0xFF121212);
  static const Color accentRed = Color(0xFFFF0000);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color secondaryGray = Color(0xFF333333);
  static const Color highlightGold = Color(0xFFFFD700);

  // Stats list (for consistency across app)
  static const List<String> stats = [
    'Strength',
    'Agility',
    'Vitality',
    'Intelligence',
    'Wisdom',
    'Charisma',
  ];

  // Default starting stats (pre-populated samples from onboarding spec)
  static const Map<String, double> defaultStats = {
    'Strength': 3.4,
    'Agility': 2.8,
    'Vitality': 3.0,
    'Intelligence': 4.2,
    'Wisdom': 3.5,
    'Charisma': 2.9,
  };

  // Other constants like max duration warning (480 mins)
  static const int maxDurationWarning = 480;

  // Future: Add configurable activity mappings here
}