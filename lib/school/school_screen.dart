import 'package:flutter/material.dart';

class SchoolScreen extends StatelessWidget {
  const SchoolScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School')),
      body: const Center(child: Text('School')),
    );
  }
}