import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/audio_level_controller.dart';
import 'core/meter_palette.dart';
import 'features/calibration/calibration_screen.dart';
import 'features/logs/measurement_log_screen.dart';
import 'features/meter/decibel_meter_screen.dart';
import 'features/thresholds/thresholds_guide_screen.dart';

class UlvexMeterApp extends StatelessWidget {
  const UlvexMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioLevelController()..init(),
      child: MaterialApp(
        title: 'Ulvex Decibel Analyzer',
        debugShowCheckedModeBanner: false,
        theme: MeterPalette.themeData(),
        home: const UlvexMainShell(),
      ),
    );
  }
}

class UlvexMainShell extends StatefulWidget {
  const UlvexMainShell({super.key});

  @override
  State<UlvexMainShell> createState() => _UlvexMainShellState();
}

class _UlvexMainShellState extends State<UlvexMainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      DecibelMeterScreen(),
      ThresholdsGuideScreen(),
      MeasurementLogScreen(),
      CalibrationScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed_rounded),
            label: 'Live Meter',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart_rounded),
            label: 'Thresholds',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Calibrate',
          ),
        ],
      ),
    );
  }
}
