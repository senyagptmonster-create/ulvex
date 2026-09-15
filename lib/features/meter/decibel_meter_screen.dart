import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio_level_controller.dart';
import '../../core/meter_palette.dart';

class DecibelMeterScreen extends StatelessWidget {
  const DecibelMeterScreen({super.key});

  void _showSaveDialog(BuildContext context) {
    final controller = context.read<AudioLevelController>();
    final locationCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final currentDb = controller.currentDecibels;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: MeterPalette.panelSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MeterPalette.panelBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Log Noise Reading',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: MeterPalette.textMain,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: MeterPalette.getDecibelZoneColor(currentDb).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${currentDb.toStringAsFixed(1)} dB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: MeterPalette.getDecibelZoneColor(currentDb),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Location / Facility Tag',
                    hintText: 'e.g. CNC Bay, Server Rack, Street Corner',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Operational Notes (Optional)',
                    hintText: 'Equipment status, machinery state...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.saveCurrentMeasurement(
                          locationTag: locationCtrl.text,
                          notes: notesCtrl.text,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Measurement recorded to logs'),
                            backgroundColor: MeterPalette.cyanPrecision,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MeterPalette.cyanPrecision,
                        foregroundColor: MeterPalette.darkBg,
                      ),
                      child: const Text('Save Entry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioLevelController>();
    final db = controller.currentDecibels;
    final peak = controller.peakDecibels;
    final min = controller.minDecibels;
    final avg = controller.averageDecibels;
    final zoneColor = MeterPalette.getDecibelZoneColor(db);
    final zoneLabel = MeterPalette.getDecibelZoneLabel(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulvex SPL Analyzer'),
        actions: [
          IconButton(
            icon: Icon(
              controller.isMeasuring ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
              color: controller.isMeasuring ? MeterPalette.amberWarning : MeterPalette.cyanPrecision,
            ),
            tooltip: controller.isMeasuring ? 'Freeze stream' : 'Resume live stream',
            onPressed: controller.toggleMeasuring,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mode selectors: weighting (dBA/dBC) & speed (Fast/Slow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'dBA', label: Text('dBA (Human)')),
                    ButtonSegment(value: 'dBC', label: Text('dBC (Peak)')),
                  ],
                  selected: {controller.frequencyWeighting},
                  onSelectionChanged: (set) {
                    controller.setFrequencyWeighting(set.first);
                  },
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Fast', label: Text('Fast')),
                    ButtonSegment(value: 'Slow', label: Text('Slow')),
                  ],
                  selected: {controller.responseSpeed},
                  onSelectionChanged: (set) {
                    controller.setResponseSpeed(set.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Circular Arc Decibel Gauge
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: _DecibelGaugePainter(
                        decibels: db,
                        peakDecibels: peak,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: zoneColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: zoneColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            zoneLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: zoneColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          db.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: MeterPalette.textMain,
                            letterSpacing: -2,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          controller.frequencyWeighting,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: MeterPalette.cyanPrecision,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Peak / Min / Avg metric cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'MIN',
                    value: '${min.toStringAsFixed(1)} dB',
                    color: MeterPalette.safeGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'AVG',
                    value: '${avg.toStringAsFixed(1)} dB',
                    color: MeterPalette.cyanPrecision,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'PEAK',
                    value: '${peak.toStringAsFixed(1)} dB',
                    color: MeterPalette.dangerRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Live Waveform / Spectrum Bars
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Acoustic Waveform Trace',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MeterPalette.textMuted,
                          ),
                        ),
                        Text(
                          '30 Samples Realtime',
                          style: TextStyle(
                            fontSize: 11,
                            color: MeterPalette.textSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: controller.sampleHistory.map((val) {
                          final normalized = ((val - 30) / 70).clamp(0.05, 1.0);
                          final barColor = MeterPalette.getDecibelZoneColor(val);
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              height: 60 * normalized,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSaveDialog(context),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                    label: const Text('LOG MEASUREMENT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MeterPalette.cyanPrecision,
                      foregroundColor: MeterPalette.darkBg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: controller.resetMinMax,
                  tooltip: 'Reset Min / Max / Avg',
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: MeterPalette.panelElevated,
                    foregroundColor: MeterPalette.textMain,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: MeterPalette.panelSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MeterPalette.panelBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: MeterPalette.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecibelGaugePainter extends CustomPainter {
  final double decibels;
  final double peakDecibels;

  _DecibelGaugePainter({
    required this.decibels,
    required this.peakDecibels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 20;

    // Arc ranges from 135 deg to 405 deg (270 deg sweep)
    const startAngle = 135 * (math.pi / 180);
    const totalSweep = 270 * (math.pi / 180);

    // Background track
    final bgPaint = Paint()
      ..color = MeterPalette.panelElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // Normalized progress (20 to 120 dB range)
    final norm = ((decibels - 20) / 100).clamp(0.0, 1.0);
    final activeSweep = totalSweep * norm;
    final activeColor = MeterPalette.getDecibelZoneColor(decibels);

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );

    // Peak Marker Needle
    final peakNorm = ((peakDecibels - 20) / 100).clamp(0.0, 1.0);
    final peakAngle = startAngle + (totalSweep * peakNorm);

    final peakPaint = Paint()
      ..color = MeterPalette.dangerRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final p1 = Offset(
      center.dx + (radius - 10) * math.cos(peakAngle),
      center.dy + (radius - 10) * math.sin(peakAngle),
    );
    final p2 = Offset(
      center.dx + (radius + 10) * math.cos(peakAngle),
      center.dy + (radius + 10) * math.sin(peakAngle),
    );
    canvas.drawLine(p1, p2, peakPaint);
  }

  @override
  bool shouldRepaint(covariant _DecibelGaugePainter oldDelegate) {
    return oldDelegate.decibels != decibels || oldDelegate.peakDecibels != peakDecibels;
  }
}
