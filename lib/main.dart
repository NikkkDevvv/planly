import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:planly/core/theme/app_theme.dart';
import 'package:planly/features/splash/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
      home: const SplashScreen(),
    );
  }
}