import 'package:flutter/material.dart';

class GradeScreen extends StatelessWidget {
  const GradeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grade')),
      body: const Center(child: Text('Grade')),
    );
  }
}