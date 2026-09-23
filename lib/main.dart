import 'package:flutter/material.dart';
import 'hell_bench_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hell CPU Benchmark',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HellBenchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
