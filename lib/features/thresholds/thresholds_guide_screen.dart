import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio_level_controller.dart';
import '../../core/meter_palette.dart';

class ThresholdsGuideScreen extends StatefulWidget {
  const ThresholdsGuideScreen({super.key});

  @override
  State<ThresholdsGuideScreen> createState() => _ThresholdsGuideScreenState();
}

class _ThresholdsGuideScreenState extends State<ThresholdsGuideScreen> {
  double _calculatorDb = 85.0;

  String _calculatePermissibleExposure(double db) {
    if (db <= 75) {
      return 'Continuous (>24 hours) with negligible hearing risk.';
    } else if (db <= 80) {
      return 'Up to 24 hours safe daily limit.';
    } else if (db <= 85) {
      return '8 hours (OSHA Action Level & NIOSH Baseline).';
    } else {
      // NIOSH 3dB exchange rate: T = 8 / (2 ^ ((L - 85) / 3))
      final hours = 8.0 / math.pow(2, (db - 85) / 3);
      if (hours >= 1.0) {
        return '${hours.toStringAsFixed(1)} hours maximum without certified ear defense.';
      } else {
        final minutes = (hours * 60).toInt();
        if (minutes >= 1) {
          return '$minutes minutes maximum permissible exposure limit.';
        } else {
          final seconds = (hours * 3600).toInt();
          return '$seconds seconds maximum before acoustic trauma threshold.';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioLevelController>();
    final thresholds = controller.thresholds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exposure Limits & Standards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Exposure Duration Interactive Calculator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_outlined,
                          color: MeterPalette.cyanPrecision, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'NIOSH Exposure Calculator',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MeterPalette.textMain,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: MeterPalette.getDecibelZoneColor(_calculatorDb).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MeterPalette.getDecibelZoneColor(_calculatorDb),
                          ),
                        ),
                        child: Text(
                          '${_calculatorDb.toInt()} dB',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: MeterPalette.getDecibelZoneColor(_calculatorDb),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _calculatorDb,
                    min: 70,
                    max: 115,
                    divisions: 45,
                    label: '${_calculatorDb.toInt()} dB',
                    activeColor: MeterPalette.getDecibelZoneColor(_calculatorDb),
                    onChanged: (val) {
                      setState(() {
                        _calculatorDb = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MeterPalette.panelElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MAX UNPROTECTED DURATION:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: MeterPalette.textSubtle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculatePermissibleExposure(_calculatorDb),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: MeterPalette.textMain,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Regulatory Reference Table
          const Text(
            'OSHA & WHO Reference Spectrum',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: MeterPalette.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...thresholds.map((item) {
            final color = MeterPalette.getDecibelZoneColor(item.dbLevel.toDouble());
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.dbLevel}\ndB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: color,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.riskCategory.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                item.agency,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: MeterPalette.textSubtle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.commonSource,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: MeterPalette.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Limit: ${item.safeExposure}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: MeterPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
