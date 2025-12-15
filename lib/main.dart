import 'package:bettertune/core/theme.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/presentations/screens/main_screen.dart';
import 'package:bettertune/presentations/screens/player_screen.dart';
import 'package:bettertune/presentations/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
