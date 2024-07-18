import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenue sur Studies !',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
            ),
            const SizedBox(height: 32),
            FractionallySizedBox(
              widthFactor: 0.3,
              child: Image.asset('assets/teacher-asset.png'),
            ),
          ],
        ),
      ),
    );
  }
}
