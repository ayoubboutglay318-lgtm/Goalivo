import 'package:flutter/material.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({
    super.key,
    this.userName,
    this.userLevel,
    this.userXP,
    this.totalXP = 1000,
  });

  final String? userName;
  final int? userLevel;
  final int? userXP;
  final int totalXP;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark
                ? const Color(0xFF0A0E27).withValues(alpha: 0.8)
                : Colors.blue.shade50,
            isDark
                ? const Color(0xFF1B2555).withValues(alpha: 0.5)
                : Colors.cyan.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Welcome back, ${userName ?? "Champion"}! ⚽',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready for today\'s matches?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
