import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiamondEdge Stat Analyzer',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: Text('DiamondEdge Stat Analyzer v2.4.1'),
        ),
      ),
    );
  }
}
