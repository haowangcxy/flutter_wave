import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_wave/flutter_wave.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_wave'),
        ),
        body: const Center(child: MyWidget()),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  double vol = 0;

  @override
  void initState() {
    super.initState();
    var ticker = Ticker((elapsed) {
      setState(() {
        vol = Random().nextDouble() * 10;
      });
    });
    ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterWave(
      volume: vol,
    );
  }
}
