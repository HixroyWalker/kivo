import 'package:flutter/material.dart';

void main() {
  runApp(const KiVoApp());
}

class KiVoApp extends StatelessWidget {
  const KiVoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiVo Global',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiVo Global'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'KiVo Global',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'High-Efficiency Fintech for Santa Cruz',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
