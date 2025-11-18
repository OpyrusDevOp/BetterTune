import 'package:bettertune/screens/setup_screen.dart';
import 'package:bettertune/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contexts/auth_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication context
  final authContext = AuthContext();
  await authContext.initialize();

  runApp(
    ChangeNotifierProvider(create: (context) => authContext, child: MyApp()),
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
