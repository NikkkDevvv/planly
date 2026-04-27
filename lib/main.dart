import 'package:flutter/material.dart';
import 'package:planly/core/theme/app_theme.dart';
import 'package:planly/features/splash/splash_screen.dart';

void main() {
  runApp(const PlanlyApp());
}

class PlanlyApp extends StatelessWidget {
  const PlanlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Aplikasi dimulai dari Splash Screen
      home: const SplashScreen(),
    );
  }
}
