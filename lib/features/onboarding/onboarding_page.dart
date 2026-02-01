import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Transform.scale(
                scale: 0.6,
                child: Image.asset(
                  'assets/images/PrepProBlue.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Welcome to PrepPro — onboarding placeholder.'),
            ),
          ),
        ],
      ),
    );
  }
}
