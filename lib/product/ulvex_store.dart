import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UlvexStore extends ChangeNotifier {
  double currentDb = 45.0;
  List<Map<String, dynamic>> logs = [];
  double calibrationOffset = 0.0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final logsStr = prefs.getString('logs');
    if (logsStr != null) {
      logs = List<Map<String, dynamic>>.from(jsonDecode(logsStr));
    }
    calibrationOffset = prefs.getDouble('calibration') ?? 0.0;
    notifyListeners();
  }

  void addLog(String note, double db) {
    logs.insert(0, {'note': note, 'db': db, 'time': DateTime.now().toIso8601String()});
    _save();
  }

  void updateDb(double val) {
    currentDb = val + calibrationOffset;
    notifyListeners();
  }

  void setCalibration(double val) {
    calibrationOffset = val;
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logs', jsonEncode(logs));
    await prefs.setDouble('calibration', calibrationOffset);
    notifyListeners();
  }
}
