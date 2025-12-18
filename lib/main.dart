import 'package:bettertune/core/theme.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/presentations/screens/main_screen.dart';
import 'package:bettertune/presentations/screens/player_screen.dart';
import 'package:bettertune/presentations/screens/onboarding_screen.dart';
import 'package:bettertune/services/home_widget_service.dart';
import 'package:bettertune/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final authService = AuthService();
  await authService.init();
  bool isLoggedIn = authService.isLoggedIn;

  // Initialize home widget
  if (isLoggedIn) {
    await HomeWidgetService().initialize();

    // Check if app was launched from widget
    final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      await HomeWidgetService.backgroundCallback(initialUri);
    }

    // Setup Method Channel for Native->Dart calls (Queue Click)
    const channel = MethodChannel('com.example.bettertune/widget');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'playSongById') {
        final songId = call.arguments as String;
        await HomeWidgetService().handleWidgetAction(
          HomeWidgetService.playQueueItemAction,
          songId: songId,
        );
      }
    });
  }

  // Initialize Settings
  await SettingsService().init();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        final bgColor = SettingsService().backgroundColor;

        // Create custom theme based on selection
        // We override the scaffold background color
        // We assume Dark Mode primarily as requested "background color/image" usually implies custom override
        // But let's respect the base theme structure if possible.

        final customTheme = darkTheme.copyWith(
          scaffoldBackgroundColor: bgColor,
          // Start with dark theme base, override bg
        );

        return MaterialApp(
          title: 'Better Tune',
          theme: customTheme, // For now forcing dark-ish theme with custom BG
          darkTheme: customTheme,
          themeMode: ThemeMode.dark, // Enforce dark mode with custom BG for now
          home: SafeArea(
            child: AuthService().isLoggedIn ? MainScreen() : OnboardingScreen(),
          ),
          routes: {'/player': (context) => const PlayerScreen()},
        );
      },
    );
  }
}
