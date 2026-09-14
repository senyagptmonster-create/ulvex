import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/brand.dart';
import '../app/theme.dart';
import 'ulvex_store.dart';

class UlvexMeterScreen extends StatelessWidget {
  const UlvexMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<UlvexStore>();
    return Container(
      color: cBg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sound Level', style: AppTheme.text(context).copyWith(color: cInk)),
            Text('${store.currentDb.toStringAsFixed(1)} dB', style: AppTheme.display(context).copyWith(color: cAccent)),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cSurface),
              onPressed: () {
                store.addLog('Manual Snapshot', store.currentDb);
              },
              child: Text('Log Measurement', style: AppTheme.text(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class UlvexGuideScreen extends StatelessWidget {
  const UlvexGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBg,
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Thresholds Guide', style: AppTheme.display(context).copyWith(color: cInk)),
          ListTile(title: Text('10-30 dB', style: AppTheme.text(context)), subtitle: Text('Whisper, Rustling leaves', style: AppTheme.text(context).copyWith(color: cAccent2))),
          ListTile(title: Text('40-60 dB', style: AppTheme.text(context)), subtitle: Text('Normal conversation', style: AppTheme.text(context).copyWith(color: cAccent2))),
          ListTile(title: Text('70-90 dB', style: AppTheme.text(context)), subtitle: Text('City traffic, Lawnmower', style: AppTheme.text(context).copyWith(color: cAccent2))),
          ListTile(title: Text('100-120 dB', style: AppTheme.text(context)), subtitle: Text('Concert, Sirens (Harmful)', style: AppTheme.text(context).copyWith(color: cAccent2))),
        ],
      ),
    );
  }
}

class UlvexLogScreen extends StatelessWidget {
  const UlvexLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<UlvexStore>();
    return Container(
      color: cBg,
      child: ListView.builder(
        itemCount: store.logs.length,
        itemBuilder: (context, index) {
          final log = store.logs[index];
          return Card(
            color: cSurface,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('${log['db']} dB - ${log['note']}', style: AppTheme.text(context)),
              subtitle: Text(log['time'], style: AppTheme.text(context).copyWith(color: cAccent2)),
            ),
          );
        },
      ),
    );
  }
}

class UlvexCalibrationScreen extends StatelessWidget {
  const UlvexCalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<UlvexStore>();
    return Container(
      color: cBg,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calibration Tool', style: AppTheme.display(context)),
          SizedBox(height: 20),
          Text('Offset: ${store.calibrationOffset.toStringAsFixed(1)} dB', style: AppTheme.text(context)),
          Slider(
            activeColor: cAccent,
            inactiveColor: cSurface,
            value: store.calibrationOffset,
            min: -20,
            max: 20,
            onChanged: (val) {
              store.setCalibration(val);
            },
          ),
        ],
      ),
    );
  }
}
