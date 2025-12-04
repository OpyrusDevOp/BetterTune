import 'package:bettertune/core/theme.dart';
import 'package:bettertune/presentations/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Tune',
      theme: appTheme,
      home: SafeArea(child: MainScreen()),
    );
  }
}
