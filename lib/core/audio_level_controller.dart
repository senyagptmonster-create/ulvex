import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoiseLogEntry {
  final String id;
  final double decibels;
  final double peakDecibels;
  final double avgDecibels;
  final String locationTag;
  final String notes;
  final String safetyRating;
  final DateTime timestamp;

  NoiseLogEntry({
    required this.id,
    required this.decibels,
    required this.peakDecibels,
    required this.avgDecibels,
    required this.locationTag,
    required this.notes,
    required this.safetyRating,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decibels': decibels,
      'peakDecibels': peakDecibels,
      'avgDecibels': avgDecibels,
      'locationTag': locationTag,
      'notes': notes,
      'safetyRating': safetyRating,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NoiseLogEntry.fromMap(Map<String, dynamic> map) {
    return NoiseLogEntry(
      id: map['id'] as String? ?? '',
      decibels: (map['decibels'] as num?)?.toDouble() ?? 50.0,
      peakDecibels: (map['peakDecibels'] as num?)?.toDouble() ?? 60.0,
      avgDecibels: (map['avgDecibels'] as num?)?.toDouble() ?? 52.0,
      locationTag: map['locationTag'] as String? ?? 'General Area',
      notes: map['notes'] as String? ?? '',
      safetyRating: map['safetyRating'] as String? ?? 'Safe',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ThresholdItem {
  final int dbLevel;
  final String commonSource;
  final String safeExposure;
  final String agency;
  final String riskCategory;

  const ThresholdItem({
    required this.dbLevel,
    required this.commonSource,
    required this.safeExposure,
    required this.agency,
    required this.riskCategory,
  });
}

class AudioLevelController extends ChangeNotifier {
  static const String _prefsLogsKey = 'ulvex_measurement_logs_v1';
  static const String _prefsCalibrationKey = 'ulvex_calibration_offset_v1';
  static const String _prefsWeightingKey = 'ulvex_weighting_v1';
  static const String _prefsSpeedKey = 'ulvex_speed_v1';

  final List<NoiseLogEntry> _logs = [];
  final List<double> _sampleHistory = List.generate(30, (_) => 45.0);

  Timer? _tickerTimer;
  final math.Random _random = math.Random();

  final double _baseNoise = 52.0;
  double _currentDecibels = 52.0;
  double _peakDecibels = 62.4;
  double _minDecibels = 41.2;
  double _sumDecibels = 520.0;
  int _sampleCount = 10;

  double _calibrationOffset = 0.0;
  String _frequencyWeighting = 'dBA'; // 'dBA' or 'dBC'
  String _responseSpeed = 'Fast'; // 'Fast' (125ms) or 'Slow' (1000ms)
  bool _isMeasuring = true;
  bool _isInitialized = false;

  List<NoiseLogEntry> get logs => List.unmodifiable(_logs);
  List<double> get sampleHistory => List.unmodifiable(_sampleHistory);
  double get currentDecibels => _currentDecibels;
  double get peakDecibels => _peakDecibels;
  double get minDecibels => _minDecibels;
  double get averageDecibels => _sampleCount > 0 ? (_sumDecibels / _sampleCount) : _currentDecibels;
  double get calibrationOffset => _calibrationOffset;
  String get frequencyWeighting => _frequencyWeighting;
  String get responseSpeed => _responseSpeed;
  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _isInitialized;

  final List<ThresholdItem> _thresholds = const [
    ThresholdItem(
      dbLevel: 30,
      commonSource: 'Quiet Bedroom, Soft Whisper, Library',
      safeExposure: 'Indefinite (No risk)',
      agency: 'WHO Guideline',
      riskCategory: 'Negligible',
    ),
    ThresholdItem(
      dbLevel: 50,
      commonSource: 'Quiet Office, Light Rainfall, Refrigerator',
      safeExposure: 'Indefinite (No risk)',
      agency: 'WHO Guideline',
      riskCategory: 'Comfort Zone',
    ),
    ThresholdItem(
      dbLevel: 65,
      commonSource: 'Normal Conversation, Air Conditioning Unit',
      safeExposure: 'Indefinite (No risk)',
      agency: 'EPA Standard',
      riskCategory: 'Safe Speech',
    ),
    ThresholdItem(
      dbLevel: 75,
      commonSource: 'Busy City Traffic, Coffee Shop Lunch Rush',
      safeExposure: '24 Hours Max',
      agency: 'WHO Environmental',
      riskCategory: 'Moderate Noise',
    ),
    ThresholdItem(
      dbLevel: 85,
      commonSource: 'Lawnmower, Milling Machine, Food Blender',
      safeExposure: '8 Hours (Action Level)',
      agency: 'OSHA / NIOSH Standard',
      riskCategory: 'Permissible Limit',
    ),
    ThresholdItem(
      dbLevel: 90,
      commonSource: 'Woodworking Router, Passing Freight Train',
      safeExposure: '4 Hours (OSHA) / 2 Hours (NIOSH)',
      agency: 'OSHA Standard',
      riskCategory: 'Hazardous',
    ),
    ThresholdItem(
      dbLevel: 100,
      commonSource: 'Handheld Chainsaw, Pneumatic Drill',
      safeExposure: '15 to 30 Minutes Max',
      agency: 'NIOSH Warning',
      riskCategory: 'Dangerous',
    ),
    ThresholdItem(
      dbLevel: 110,
      commonSource: 'Live Rock Concert, Police Vehicle Siren',
      safeExposure: 'Under 2 Minutes Unprotected',
      agency: 'CDC / OSHA Warning',
      riskCategory: 'Severe Risk',
    ),
    ThresholdItem(
      dbLevel: 130,
      commonSource: 'Pneumatic Riveter, Jet Engine at 100m',
      safeExposure: 'Immediate Permanent Damage',
      agency: 'Threshold of Pain',
      riskCategory: 'Critical',
    ),
  ];

  List<ThresholdItem> get thresholds => _thresholds;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _calibrationOffset = prefs.getDouble(_prefsCalibrationKey) ?? 0.0;
      _frequencyWeighting = prefs.getString(_prefsWeightingKey) ?? 'dBA';
      _responseSpeed = prefs.getString(_prefsSpeedKey) ?? 'Fast';

      final rawLogs = prefs.getString(_prefsLogsKey);
      if (rawLogs != null && rawLogs.isNotEmpty) {
        final decoded = jsonDecode(rawLogs) as List<dynamic>;
        _logs.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _logs.add(NoiseLogEntry.fromMap(item));
          }
        }
        _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else {
        _populateSampleLogs();
      }
    } catch (e) {
      debugPrint('AudioLevelController init error: $e');
      if (_logs.isEmpty) {
        _populateSampleLogs();
      }
    }
    _isInitialized = true;
    _startTicker();
    notifyListeners();
  }

  void _populateSampleLogs() {
    final now = DateTime.now();
    _logs.addAll([
      NoiseLogEntry(
        id: 'log_1',
        decibels: 58.4,
        peakDecibels: 68.2,
        avgDecibels: 56.1,
        locationTag: 'Engineering Office',
        notes: 'Air vents and keyboard mechanical clicks.',
        safetyRating: 'Safe',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      NoiseLogEntry(
        id: 'log_2',
        decibels: 88.5,
        peakDecibels: 96.2,
        avgDecibels: 86.4,
        locationTag: 'CNC Milling Bay',
        notes: 'Spindle running at 12,000 RPM. Earmuffs mandatory.',
        safetyRating: 'Hazardous',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      NoiseLogEntry(
        id: 'log_3',
        decibels: 73.1,
        peakDecibels: 79.5,
        avgDecibels: 71.8,
        locationTag: 'Street Intersection',
        notes: 'Heavy afternoon vehicle traffic and buses.',
        safetyRating: 'Moderate',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
      ),
    ]);
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    final interval = _responseSpeed == 'Fast' ? 150 : 500;
    _tickerTimer = Timer.periodic(Duration(milliseconds: interval), (_) {
      if (!_isMeasuring) return;

      // Realistic acoustic simulation
      final drift = (_random.nextDouble() - 0.5) * 4.5;
      final spike = _random.nextDouble() > 0.93 ? (_random.nextDouble() * 14) : 0.0;
      double newDb = _baseNoise + drift + spike + _calibrationOffset;

      // Clamp within 20 dB to 130 dB
      newDb = double.parse(newDb.clamp(20.0, 130.0).toStringAsFixed(1));

      _currentDecibels = newDb;
      if (newDb > _peakDecibels) _peakDecibels = newDb;
      if (newDb < _minDecibels) _minDecibels = newDb;

      _sumDecibels += newDb;
      _sampleCount++;

      _sampleHistory.removeAt(0);
      _sampleHistory.add(newDb);

      notifyListeners();
    });
  }

  void toggleMeasuring() {
    _isMeasuring = !_isMeasuring;
    notifyListeners();
  }

  void resetMinMax() {
    _peakDecibels = _currentDecibels;
    _minDecibels = _currentDecibels;
    _sumDecibels = _currentDecibels;
    _sampleCount = 1;
    notifyListeners();
  }

  Future<void> setCalibrationOffset(double offset) async {
    _calibrationOffset = double.parse(offset.toStringAsFixed(1));
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsCalibrationKey, _calibrationOffset);
  }

  Future<void> setFrequencyWeighting(String weighting) async {
    _frequencyWeighting = weighting;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsWeightingKey, weighting);
  }

  Future<void> setResponseSpeed(String speed) async {
    _responseSpeed = speed;
    _startTicker();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsSpeedKey, speed);
  }

  Future<void> saveCurrentMeasurement({
    required String locationTag,
    required String notes,
  }) async {
    String rating = 'Safe';
    if (_currentDecibels >= 85) {
      rating = 'Hazardous';
    } else if (_currentDecibels >= 70) {
      rating = 'Moderate';
    }

    final entry = NoiseLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      decibels: _currentDecibels,
      peakDecibels: _peakDecibels,
      avgDecibels: double.parse(averageDecibels.toStringAsFixed(1)),
      locationTag: locationTag.trim().isEmpty ? 'General Station' : locationTag.trim(),
      notes: notes.trim(),
      safetyRating: rating,
      timestamp: DateTime.now(),
    );

    _logs.insert(0, entry);
    notifyListeners();
    await _saveLogs();
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
    await _saveLogs();
  }

  Future<void> clearLogs() async {
    _logs.clear();
    notifyListeners();
    await _saveLogs();
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapped = _logs.map((l) => l.toMap()).toList();
      await prefs.setString(_prefsLogsKey, jsonEncode(mapped));
    } catch (e) {
      debugPrint('Error saving logs: $e');
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
