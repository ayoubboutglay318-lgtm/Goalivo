import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Terms of Use', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Last updated: May 2025', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          _Section(title: '1. Acceptance of Terms', body:
            'By downloading or using Kickkora, you agree to be bound by these Terms of Use. '
            'If you do not agree, please do not use the app.'),
          _Section(title: '2. Use of the App', body:
            'Kickkora is provided for personal, non-commercial use. You may not copy, modify, distribute, or reverse-engineer any part of the app.'),
          _Section(title: '3. Football Data', body:
            'Match data, standings, and fixtures are sourced from third-party sports APIs. '
            'We strive for accuracy but cannot guarantee that all data is correct or up to date.'),
          _Section(title: '4. User-Generated Content', body:
            'The Fan Zone lets you post messages visible within the app. You are responsible for what you post. '
            'We reserve the right to remove content that is offensive, harmful, or otherwise inappropriate.'),
          _Section(title: '5. XP and Achievements', body:
            'XP points, levels, and achievements are for entertainment purposes only. '
            'They hold no monetary value and cannot be transferred or redeemed.'),
          _Section(title: '6. Intellectual Property', body:
            'Team logos and league emblems displayed in the app are the property of their respective owners. '
            'Kickkora does not claim ownership of any third-party trademarks.'),
          _Section(title: '7. Disclaimer of Warranties', body:
            'The app is provided "as is" without any warranties. We do not guarantee uninterrupted or error-free service.'),
          _Section(title: '8. Limitation of Liability', body:
            'To the fullest extent permitted by law, Kickkora is not liable for any indirect, incidental, or consequential damages arising from use of the app.'),
          _Section(title: '9. Changes to Terms', body:
            'We may update these terms at any time. Continued use of the app after changes means you accept the new terms.'),
          _Section(title: '10. Contact', body:
            'For questions about these terms, contact us at:\nayoubboutglay318@gmail.com'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, color: theme.colorScheme.onSurface.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}
