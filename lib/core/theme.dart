import 'package:flutter/material.dart';

// --- Premium Blue Palette ---
// Primary Blue - Deep, vibrant, and professional.
final Color primaryBlue = Color(0xFF2979FF);
final Color primaryDarkBlue = Color(0xFF0D47A1);
final Color primaryLightBlue = Color(0xFFE3F2FD);

// Accent/Secondary - Complementary lighter blue/teal for highlights.
final Color accentBlue = Color(0xFF40C4FF);

// Backgrounds
final Color darkBackground = Color(0xFF121212); // True Dark
final Color darkSurface = Color(0xFF1E1E1E); // Slightly lighter for cards
final Color lightBackground = Color(0xFFF5F7FA); // Soft Grey-White
final Color lightSurface = Colors.white;

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // --- Color Scheme ---
  colorScheme: ColorScheme.dark(
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF003C8F), // Darker shade of primary
    onPrimaryContainer: Colors.white,
    secondary: accentBlue,
    onSecondary: Colors.black,
    surface: darkSurface,
    onSurface: Colors.white,
    surfaceContainer: darkBackground,
    error: Color(0xFFCF6679),
  ),

  // --- Typography ---
  // Using default M3 typography but you could customize fontFamily here if needed.
  // typography: Typography.material2021(),

  // --- Component Themes ---

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: darkBackground,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: darkSurface,
    elevation: 2,
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.all(4),
  ),

  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    selectedTileColor: primaryBlue.withAlpha(25), // Subtle selection
    selectedColor: primaryBlue,
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
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryBlue, width: 2),
    ),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryBlue,
    inactiveTrackColor: Colors.white24,
    thumbColor: primaryBlue,
    overlayColor: primaryBlue.withAlpha(50),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return primaryBlue;
      return null; // transparent/default
    }),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // --- Color Scheme ---
  colorScheme: ColorScheme.light(
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: primaryLightBlue,
    onPrimaryContainer: primaryDarkBlue,
    secondary: accentBlue,
    onSecondary: Colors.white,
    surface: lightSurface,
    onSurface: Colors.black87,
    surfaceContainer: lightBackground,
    error: Color(0xFFB00020),
  ),

  // --- Component Themes ---

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: lightBackground,
    foregroundColor: Colors.black87,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      letterSpacing: 0.5,
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: lightSurface,
    elevation: 3,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.all(4),
  ),

  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: Colors.transparent,
    selectedTileColor: primaryBlue.withAlpha(25),
    selectedColor: primaryBlue,
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
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryBlue, width: 2),
    ),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryBlue,
    inactiveTrackColor: Colors.black12, // More visible on light bg
    thumbColor: primaryBlue,
    overlayColor: primaryBlue.withAlpha(50),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return primaryBlue;
      return null;
    }),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);
