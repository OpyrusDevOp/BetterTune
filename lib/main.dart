import 'package:bettertune/core/theme.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/presentations/screens/main_screen.dart';
import 'package:bettertune/presentations/screens/player_screen.dart';
import 'package:bettertune/presentations/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
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

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Tune',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: AuthService().isLoggedIn
          ? SafeArea(child: MainScreen())
          : OnboardingScreen(),
      routes: {'/player': (context) => const PlayerScreen()},
    );
  }
}
