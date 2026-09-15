import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio_level_controller.dart';
import '../../core/meter_palette.dart';

class MeasurementLogScreen extends StatefulWidget {
  const MeasurementLogScreen({super.key});

  @override
  State<MeasurementLogScreen> createState() => _MeasurementLogScreenState();
}

class _MeasurementLogScreenState extends State<MeasurementLogScreen> {
  String _selectedFilter = 'All';

  String _formatTimestamp(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, ${dt.year} • $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioLevelController>();
    final logs = controller.logs;

    final filteredLogs = logs.where((l) {
      if (_selectedFilter == 'All') return true;
      return l.safetyRating.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    double avgSpl = 0;
    double highestPeak = 0;
    if (logs.isNotEmpty) {
      avgSpl = logs.fold<double>(0, (s, l) => s + l.decibels) / logs.length;
      highestPeak = logs.fold<double>(0, (m, l) => l.peakDecibels > m ? l.peakDecibels : m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Dossier'),
        actions: [
          if (logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Log Dossier',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: MeterPalette.panelSurface,
                    title: const Text('Clear Measurement History?'),
                    content: const Text(
                      'All saved acoustic telemetry logs will be deleted permanently.',
                      style: TextStyle(color: MeterPalette.textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.clearLogs();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MeterPalette.dangerRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear Dossier'),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Telemetry Stats Overview Strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MeterPalette.panelSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MeterPalette.panelBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${logs.length}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MeterPalette.cyanPrecision,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Logs Saved',
                        style: TextStyle(fontSize: 11, color: MeterPalette.textMuted),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 32, color: MeterPalette.panelBorder),
                  Column(
                    children: [
                      Text(
                        logs.isEmpty ? '0.0 dB' : '${avgSpl.toStringAsFixed(1)} dB',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MeterPalette.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Average SPL',
                        style: TextStyle(fontSize: 11, color: MeterPalette.textMuted),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 32, color: MeterPalette.panelBorder),
                  Column(
                    children: [
                      Text(
                        logs.isEmpty ? '0.0 dB' : '${highestPeak.toStringAsFixed(1)} dB',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MeterPalette.dangerRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Max Surge',
                        style: TextStyle(fontSize: 11, color: MeterPalette.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['All', 'Safe', 'Moderate', 'Hazardous'].map((filter) {
                final isSelected = _selectedFilter == filter;
                Color chipColor = MeterPalette.cyanPrecision;
                if (filter == 'Safe') chipColor = MeterPalette.safeGreen;
                if (filter == 'Moderate') chipColor = MeterPalette.amberWarning;
                if (filter == 'Hazardous') chipColor = MeterPalette.dangerRed;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: chipColor.withValues(alpha: 0.2),
                    checkmarkColor: chipColor,
                    backgroundColor: MeterPalette.panelSurface,
                    side: BorderSide(
                      color: isSelected ? chipColor : MeterPalette.panelBorder,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? chipColor : MeterPalette.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Log items list
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 48, color: MeterPalette.panelBorder),
                        const SizedBox(height: 12),
                        const Text(
                          'No acoustic measurements recorded',
                          style: TextStyle(color: MeterPalette.textMuted),
                        ),
                      ],
                    ),
                  )
                : filteredLogs.isEmpty
                    ? Center(
                        child: Text(
                          'No entries in category "$_selectedFilter"',
                          style: const TextStyle(color: MeterPalette.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final item = filteredLogs[index];
                          final zoneColor = MeterPalette.getDecibelZoneColor(item.decibels);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: zoneColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.safetyRating.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: zoneColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.locationTag,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: MeterPalette.textMain,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.decibels.toStringAsFixed(1)} dB',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: zoneColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Peak: ${item.peakDecibels.toStringAsFixed(1)} dB',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: MeterPalette.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Avg: ${item.avgDecibels.toStringAsFixed(1)} dB',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: MeterPalette.textMuted,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatTimestamp(item.timestamp),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: MeterPalette.textSubtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.notes.isNotEmpty) ...[
                                    const Divider(
                                      height: 16,
                                      color: MeterPalette.panelBorder,
                                    ),
                                    Text(
                                      item.notes,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: MeterPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded,
                                            size: 18),
                                        color: MeterPalette.textSubtle,
                                        tooltip: 'Delete Log',
                                        onPressed: () =>
                                            controller.deleteLog(item.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
