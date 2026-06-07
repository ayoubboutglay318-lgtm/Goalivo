import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/goal_alerts_service.dart';
import '../services/notification_preferences_service.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.goalAlertsService,
    required this.notifPrefs,
  });
  final GoalAlertsService goalAlertsService;
  final NotificationPreferencesService notifPrefs;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        // App logo / name
        Center(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/goalivo_logo.svg',
                width: 200,
                height: 100,
              ),
              const SizedBox(height: 4),
              Text('Live football scores', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Notifications section
        _SectionHeader(title: 'Notifications'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.notifications_active_outlined,
          title: 'Notification Settings',
          subtitle: 'Goals, red cards, results and more',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  NotificationSettingsScreen(service: widget.notifPrefs),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Legal section
        _SectionHeader(title: 'Legal'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TermsScreen()),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'Version 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white24),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white38,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 18, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

// Keep XpToast stub so other files that might reference it don't break
class XpToast {
  static void show(
    BuildContext context, {
    required int xpGained,
    List<dynamic> newBadges = const [],
  }) {}
}
