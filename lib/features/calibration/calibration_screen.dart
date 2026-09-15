import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio_level_controller.dart';
import '../../core/meter_palette.dart';

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioLevelController>();
    final offset = controller.calibrationOffset;
    final currentDb = controller.currentDecibels;
    final rawDb = (currentDb - offset).clamp(20.0, 130.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Calibration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live Calibration Telemetry Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRANSDUCER SENSITIVITY TRIM',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: MeterPalette.cyanPrecision,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Raw Input Signal',
                            style: TextStyle(
                              fontSize: 12,
                              color: MeterPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rawDb.toStringAsFixed(1)} dB',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: MeterPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded,
                          color: MeterPalette.panelBorder),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Calibrated Output',
                            style: TextStyle(
                              fontSize: 12,
                              color: MeterPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentDb.toStringAsFixed(1)} dB',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: MeterPalette.cyanPrecision,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: MeterPalette.panelBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Offset Trim:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MeterPalette.textMain,
                        ),
                      ),
                      Text(
                        '${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)} dB',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: offset == 0
                              ? MeterPalette.textMain
                              : (offset > 0 ? MeterPalette.amberWarning : MeterPalette.cyanPrecision),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: offset,
                    min: -15.0,
                    max: 15.0,
                    divisions: 60,
                    label: '${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)} dB',
                    activeColor: MeterPalette.cyanPrecision,
                    onChanged: (val) {
                      controller.setCalibrationOffset(val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            controller.setCalibrationOffset((offset - 0.5).clamp(-15.0, 15.0)),
                        child: const Text('-0.5 dB'),
                      ),
                      TextButton(
                        onPressed: () => controller.setCalibrationOffset(0.0),
                        child: const Text('Reset to 0.0 dB'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            controller.setCalibrationOffset((offset + 0.5).clamp(-15.0, 15.0)),
                        child: const Text('+0.5 dB'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Acoustic Parameters Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequency & Damping Configuration',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: MeterPalette.textMain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Frequency Weighting Filter',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MeterPalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'dBA',
                        label: Text('dBA (A-Weighting)'),
                        icon: Icon(Icons.hearing_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: 'dBC',
                        label: Text('dBC (C-Weighting)'),
                        icon: Icon(Icons.equalizer_rounded, size: 16),
                      ),
                    ],
                    selected: {controller.frequencyWeighting},
                    onSelectionChanged: (set) =>
                        controller.setFrequencyWeighting(set.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.frequencyWeighting == 'dBA'
                        ? 'A-weighting attenuates low and high frequencies to replicate human ear sensitivity.'
                        : 'C-weighting provides linear response for low-frequency industrial rumble and engine vibrations.',
                    style: const TextStyle(fontSize: 11, color: MeterPalette.textSubtle),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Time Weighting Dynamic Response',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MeterPalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Fast',
                        label: Text('Fast (125 ms)'),
                        icon: Icon(Icons.bolt_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: 'Slow',
                        label: Text('Slow (1000 ms)'),
                        icon: Icon(Icons.speed_rounded, size: 16),
                      ),
                    ],
                    selected: {controller.responseSpeed},
                    onSelectionChanged: (set) =>
                        controller.setResponseSpeed(set.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Calibration Standard Procedure Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MeterPalette.panelSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MeterPalette.panelBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: MeterPalette.cyanPrecision,
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Standard Calibrator Alignment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MeterPalette.textMain,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Insert microphone capsule into an IEC 60942 Class 1 acoustic calibrator (94.0 dB SPL at 1 kHz). Adjust slider trim until display reads exactly 94.0 dB.',
                        style: TextStyle(
                          fontSize: 12,
                          color: MeterPalette.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
