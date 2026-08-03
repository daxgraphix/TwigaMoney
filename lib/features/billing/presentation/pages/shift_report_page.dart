import 'package:flutter/material.dart';

class ShiftReportPage extends StatelessWidget {
  final String shiftId;

  const ShiftReportPage({super.key, required this.shiftId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Report'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text('Shift Report Page - Coming Soon'),
      ),
    );
  }
}