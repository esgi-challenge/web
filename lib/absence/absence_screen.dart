import 'package:flutter/material.dart';

class AbsenceScreen extends StatelessWidget {
  const AbsenceScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absence')),
      body: const Center(child: Text('Absence')),
    );
  }
}