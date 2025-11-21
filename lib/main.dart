import 'package:bettertune/screens/setup_screen.dart';
import 'package:bettertune/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';

import 'contexts/auth_context.dart';

import 'services/player_service.dart';

late AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.opyrusdev.bettertune.channel.audio',
      androidNotificationChannelName: 'BetterTune Audio',
      androidNotificationOngoing: true,
    ),
  );

  // Initialize authentication context
  final authContext = AuthContext();
  await authContext.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authContext),
        ChangeNotifierProvider(create: (_) => PlayerService(_audioHandler)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        primaryColor: const Color(0xFF0A1628),
      ),
      home: Consumer<AuthContext>(
        builder: (context, authContext, child) => authContext.isAuthenticated
            ? const WelcomeScreen()
            : const SetupScreen(),
      ),
    );
  }
}
