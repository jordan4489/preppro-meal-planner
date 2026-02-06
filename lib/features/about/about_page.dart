import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('About PrepPro'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('PrepPro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('Meal planning and shopping lists designed to reduce waste and save time.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Privacy (short)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'We collect only what we need to provide the service: account info, your profile/plan data, '
            'and optional diagnostics if you opt in. We do not sell your data.',
          ),
          const SizedBox(height: 16),
          const Text('Terms (short)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Use the app responsibly. Meal plans are informational and not medical advice. '
            'Calorie estimates are approximate and may vary. The service is provided “as is.”',
          ),
          const SizedBox(height: 16),
          const Text('Copyright', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            '© 2026 PrepPro. All app content, recipes, and branding are protected by copyright. '
            'No part may be copied, redistributed, or reused without prior written permission.',
          ),
          const SizedBox(height: 16),
          const Text('Support', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const SelectableText('support@preppro.app'),
        ],
      ),
    );
  }
}
