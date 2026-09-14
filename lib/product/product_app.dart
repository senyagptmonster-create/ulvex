import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/brand.dart';
import 'screens.dart';
import 'ulvex_store.dart';

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UlvexStore()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ulvex',
        home: Scaffold(
          backgroundColor: cBg,
          appBar: AppBar(backgroundColor: cSurface, title: Text('Ulvex', style: TextStyle(color: cInk))),
          body: PageView(
            children: [
              UlvexMeterScreen(),
              UlvexGuideScreen(),
              UlvexLogScreen(),
              UlvexCalibrationScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
