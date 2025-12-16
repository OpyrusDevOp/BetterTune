import 'package:flutter/material.dart';

// --- Jellyfin-inspired Blue Palette ---
// Deep, vibrant blue
final Color primaryBlue = Color(0xFF00A4DC); // Jellyfin Brand Blueish
final Color primaryDark = Color(0xFF007A9E);
final Color primaryLight = Color(0xFF80D2EE);

// Backgrounds
final Color darkBackground = Color(0xFF050505); // Almost Black
final Color darkSurface = Color(0xFF151515); // Dark Grey
final Color darkCard = Color(0xFF1F1F1F);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackground,

  // --- Color Scheme ---
  colorScheme: ColorScheme.dark(
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF0A2E3D),
    onPrimaryContainer: Colors.white,
    secondary: primaryBlue,
    onSecondary: Colors.black,
    surface: darkSurface,
    onSurface: Colors.white,
    surfaceContainer: darkCard,
    error: Color(0xFFCF6679),
  ),

  // --- Typography ---
  // Clean, readable defaults
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    titleLarge: TextStyle(fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
  ),

  // --- Component Themes ---

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: darkBackground,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: darkCard,
    elevation: 0, // Flat style
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    selectedTileColor: primaryBlue.withAlpha(30),
    selectedColor: primaryBlue,
    iconColor: Colors.grey[400],
    textColor: Colors.white,
  ),

  // FAB
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Bottom Navigation
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkSurface,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey[600],
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    showSelectedLabels: true,
    showUnselectedLabels: false,
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    activeIndicatorBorder: BorderSide.none, // M3 fix
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryBlue, width: 2),
    ),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryBlue,
    inactiveTrackColor: Colors.white10,
    thumbColor: primaryBlue,
    overlayColor: primaryBlue.withAlpha(50),
    trackHeight: 2,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return primaryBlue;
      return Colors.transparent;
    }),
    side: BorderSide(color: Colors.grey, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);

// Light Palette
final Color lightBackground = Color(0xFFF5F5F5); // Very light grey
final Color lightSurface = Colors.white;
final Color lightCard = Colors.white;

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightBackground,

  // --- Color Scheme ---
  colorScheme: ColorScheme.light(
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0F7FA),
    onPrimaryContainer: Color(0xFF006064),
    secondary: primaryBlue,
    onSecondary: Colors.white,
    surface: lightSurface,
    onSurface: Colors.black,
    surfaceContainer: lightCard,
    error: Color(0xFFB00020),
  ),

  // --- Typography ---
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: Colors.black,
    ),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black54),
  ),

  // --- Component Themes ---

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: lightBackground,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: lightCard,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    // Subtle border for light theme cards to stand out
  ),

  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    selectedTileColor: primaryBlue.withAlpha(30),
    selectedColor: primaryBlue,
    iconColor: Colors.grey[600],
    textColor: Colors.black,
  ),

  // FAB
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Bottom Navigation
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightSurface,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey[600],
    type: BottomNavigationBarType.fixed,
    elevation: 8, // Little bit of shadow for separation
    showSelectedLabels: true,
    showUnselectedLabels: false,
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryBlue, width: 2),
    ),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryBlue,
    inactiveTrackColor: Colors.grey[300],
    thumbColor: primaryBlue,
    overlayColor: primaryBlue.withAlpha(50),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return primaryBlue;
      return Colors.transparent;
    }),
    side: BorderSide(color: Colors.grey[600]!, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);
