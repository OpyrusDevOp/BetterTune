import 'package:flutter/material.dart';

final Color primaryBlue = Color(0xFF00A9E0);
final Color primaryBlueContainer = Color(0xFFD9F5FF);
final Color accentBlue = Color(0xFF70D6FF);
final Color darkSurface = Color(0xFF1E1E1E);

final darkTheme = ThemeData(
  useMaterial3: true,
  // --- Core Color Scheme ---
  colorScheme: ColorScheme.dark(
    primary: primaryBlue, // Jellyfin Blue
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF004D66), // Dark blue background for elements
    secondary: accentBlue, // Accent for smaller details
    surfaceContainer: Color(0xFF121212), // OLED-friendly background
    surface: darkSurface, // Card/Nav bar background
    onSurface: Colors.white, // White text on surfaces
    error: Colors.red,
    tertiary: Colors.white54,
  ),

  // --- Specific Widget Customization ---
  // App Bar (Top Navigation)
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  // Card (Album Art, Song Lists)
  cardTheme: CardThemeData(
    color: darkSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkSurface,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey[400],
  ),

  // Text Selection Handles (for better contrast)
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryBlue,
    selectionColor: primaryBlue.withOpacity(0.4),
    selectionHandleColor: primaryBlue,
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 3,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    activeTrackColor: Colors.white,
    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
    thumbColor: Colors.white,
  ),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  // --- Core Color Scheme ---
  colorScheme: ColorScheme.light(
    primary: primaryBlue, // Jellyfin Blue
    onPrimary: Colors.white,
    primaryContainer:
        primaryBlueContainer, // Light blue background for elements
    secondary: accentBlue, // Accent for smaller details
    surfaceContainer: Colors.white, // Pure white background
    surface: Color(0xFFF0F0F0), // Card/Nav bar background
    onSurface: Color(0xFF0A0A0A), // Black text on surfaces
    error: Colors.red,
    tertiary: Colors.grey,
  ),

  // --- Specific Widget Customization ---
  // App Bar (Top Navigation)
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF0A0A0A),
    elevation: 0,
  ),

  // Card (Album Art, Song Lists)
  cardTheme: CardThemeData(
    color: Color(0xFFF0F0F0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF0F0F0),
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey[600],
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 3,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    activeTrackColor: Colors.black87,
    inactiveTrackColor: Colors.black87.withValues(alpha: 0.2),
    thumbColor: Colors.black87,
  ),
);
