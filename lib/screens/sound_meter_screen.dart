import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/ulvex_theme.dart';
import '../painters/decibel_gauge_painter.dart';

class SoundMeterScreen extends StatefulWidget {
  const SoundMeterScreen({super.key});

  @override
  State<SoundMeterScreen> createState() => _SoundMeterScreenState();
}

class _SoundMeterScreenState extends State<SoundMeterScreen> {
  double _currentDb = 58.4;
  double _peakDb = 72.1;
  bool _isSampling = true;
  Timer? _sampleTimer;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _startSampling();
  }

  @override
  void dispose() {
    _sampleTimer?.cancel();
    super.dispose();
  }

  void _startSampling() {
    _sampleTimer?.cancel();
    _sampleTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) {
        setState(() {
          final delta = (_rnd.nextDouble() * 6) - 3;
          _currentDb = (_currentDb + delta).clamp(35.0, 105.0);
          if (_currentDb > _peakDb) _peakDb = _currentDb;
        });
      }
    });
  }

  void _toggleSampling() {
    setState(() {
      _isSampling = !_isSampling;
      if (_isSampling) {
        _startSampling();
      } else {
        _sampleTimer?.cancel();
      }
    });
  }

  void _resetPeak() {
    setState(() {
      _peakDb = _currentDb;
    });
  }

  void _showThresholdsSheet() {
    final thresholds = [
      {'range': '30 - 40 dB', 'env': 'Whisper, Quiet Library', 'risk': 'Safe'},
      {'range': '50 - 65 dB', 'env': 'Normal Conversation, Office', 'risk': 'Safe'},
      {'range': '70 - 80 dB', 'env': 'Busy Highway, Vacuum Cleaner', 'risk': 'Prolonged Exposure Risk'},
      {'range': '85 - 95 dB', 'env': 'Lawnmower, Heavy City Traffic', 'risk': 'OSHA 8-hour Limit'},
      {'range': '100+ dB', 'env': 'Live Concert, Chainsaw, Siren', 'risk': 'Immediate Hearing Damage'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: UlvexTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Noise Safety Exposure Table', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...thresholds.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: UlvexTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: UlvexTheme.edge),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['range']!, style: const TextStyle(fontWeight: FontWeight.bold, color: UlvexTheme.accent)),
                          Text(t['env']!, style: const TextStyle(color: UlvexTheme.muted, fontSize: 12)),
                        ],
                      ),
                      Text(t['risk']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDanger = _currentDb > 85;
    final isCaution = _currentDb > 70 && !isDanger;

    final statusColor = isDanger
        ? UlvexTheme.danger
        : (isCaution ? UlvexTheme.warning : UlvexTheme.accent);

    final statusLabel = isDanger
        ? 'DANGER: HIGH EXPOSURE'
        : (isCaution ? 'CAUTION: ELEVATED' : 'SAFE SOUND LEVEL');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ULVEX SOUND METER', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 16),
              // Gauge
              Center(
                child: SizedBox(
                  width: 280,
                  height: 180,
                  child: CustomPaint(
                    painter: DecibelGaugePainter(dbValue: _currentDb),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Big Decibel Number
              Text(
                _currentDb.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: UlvexTheme.ink,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'DECIBELS (dBA)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: UlvexTheme.accent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              // Stat Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: UlvexTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: UlvexTheme.edge),
                        ),
                        child: Column(
                          children: [
                            const Text('Peak dB', style: TextStyle(color: UlvexTheme.muted, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${_peakDb.toStringAsFixed(1)} dB', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: UlvexTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: UlvexTheme.edge),
                        ),
                        child: Column(
                          children: [
                            const Text('Sensor', style: TextStyle(color: UlvexTheme.muted, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(_isSampling ? 'ACTIVE' : 'PAUSED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isSampling ? UlvexTheme.accent : UlvexTheme.muted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Toggle Sampling Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSampling ? Colors.amber.shade800 : UlvexTheme.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _toggleSampling,
                    icon: Icon(_isSampling ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      _isSampling ? 'PAUSE SENSOR SAMPLING' : 'RESUME SENSOR SAMPLING',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _resetPeak,
                    icon: const Icon(Icons.refresh, size: 16, color: UlvexTheme.muted),
                    label: const Text('Reset Peak', style: TextStyle(color: UlvexTheme.muted)),
                  ),
                  const SizedBox(width: 20),
                  TextButton.icon(
                    onPressed: _showThresholdsSheet,
                    icon: const Icon(Icons.shield_outlined, size: 16, color: UlvexTheme.accentLight),
                    label: const Text('Safety Table', style: TextStyle(color: UlvexTheme.ink)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
