import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NazarApp());
}

class NazarApp extends StatelessWidget {
  const NazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nazar',
      debugShowCheckedModeBanner: false,
      theme: NazarTheme.light,
      home: const HomeScreen(),
    );
  }
}
