import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Privacy Policy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Last updated: May 2025', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          _Section(title: '1. Information We Collect', body:
            'Kickkora does not collect personal information. The app displays publicly available football data from third-party APIs. '
            'Match scores, standings, and fixtures are fetched in real time and not stored on our servers.'),
          _Section(title: '2. Usage Data', body:
            'We do not track your usage or behavior within the app. No analytics or crash-reporting SDKs are used that transmit personal data.'),
          _Section(title: '3. Local Storage', body:
            'Your preferences (favorite teams, theme, notifications) are stored locally on your device using standard OS mechanisms. '
            'This data never leaves your device.'),
          _Section(title: '4. Notifications', body:
            'If you enable goal alerts, your device will receive local push notifications. '
            'No personal data is sent to external servers for this feature.'),
          _Section(title: '5. Third-Party Services', body:
            'The app fetches football data from a third-party sports API. That provider may log IP addresses as part of standard server operation. '
            'Please review their privacy policy for details.'),
          _Section(title: '6. Children\'s Privacy', body:
            'Kickkora is not directed at children under 13. We do not knowingly collect information from children.'),
          _Section(title: '7. Changes to This Policy', body:
            'We may update this privacy policy from time to time. Changes will be reflected with a new "Last updated" date.'),
          _Section(title: '8. Contact', body:
            'For privacy-related questions, contact us at:\nayoubboutglay318@gmail.com'),
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
