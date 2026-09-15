import 'package:flutter/material.dart';
import 'theme/ulvex_theme.dart';
import 'screens/sound_meter_screen.dart';

void main() {
  runApp(const UlvexApp());
}

class UlvexApp extends StatelessWidget {
  const UlvexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ulvex Sound Meter',
      debugShowCheckedModeBanner: false,
      theme: UlvexTheme.themeData,
      home: const SoundMeterScreen(),
    );
  }
}
