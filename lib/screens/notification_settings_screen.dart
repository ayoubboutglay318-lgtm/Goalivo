import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/notification_preferences_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.service});
  final NotificationPreferencesService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07060F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07060F),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
        ),
        title: const Text('Notifications',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Master toggle
              _MasterToggle(service: service),
              const SizedBox(height: 28),

              // MATCH section
              _SectionLabel(label: 'MATCH'),
              const SizedBox(height: 10),
              _NotifTile(
                icon: Icons.alarm_outlined,
                title: 'Match reminder',
                subtitle: '1 hour before kickoff',
                type: NotifType.matchReminder,
                service: service,
              ),
              _NotifTile(
                icon: Icons.people_outline,
                title: 'Lineups available',
                subtitle: 'When starting XI is announced',
                type: NotifType.lineups,
                service: service,
              ),
              _NotifTile(
                icon: Icons.sports_soccer_outlined,
                title: 'Kickoff',
                subtitle: 'When the match starts',
                type: NotifType.kickoff,
                service: service,
              ),
              _NotifTile(
                icon: Icons.sports_soccer,
                title: 'Goal',
                subtitle: 'Every time a goal is scored',
                type: NotifType.goal,
                service: service,
              ),
              _NotifTile(
                icon: Icons.style_outlined,
                title: 'Red card',
                subtitle: 'When a player is sent off',
                type: NotifType.redCard,
                service: service,
              ),
              _NotifTile(
                icon: Icons.timer_outlined,
                title: 'Half-time result',
                subtitle: 'Score at the break',
                type: NotifType.halftime,
                service: service,
              ),
              _NotifTile(
                icon: Icons.flag_outlined,
                title: 'Final result',
                subtitle: 'Full-time score',
                type: NotifType.finalResult,
                service: service,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _MasterToggle extends StatelessWidget {
  const _MasterToggle({required this.service});
  final NotificationPreferencesService service;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0D1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: service.masterEnabled
                ? primary.withValues(alpha: 0.15)
                : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Icon(
            service.masterEnabled
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            color: service.masterEnabled ? primary : Colors.white38,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enable notifications',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(
            service.masterEnabled ? 'You will receive alerts' : 'All notifications disabled',
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ])),
        Switch(
          value: service.masterEnabled,
          onChanged: (_) {
            HapticFeedback.selectionClick();
            service.toggleMaster();
          },
          activeTrackColor: primary,
          inactiveThumbColor: Colors.white38,
        ),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Colors.white38, letterSpacing: 1.5));
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.service,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final NotifType type;
  final NotificationPreferencesService service;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final enabled = service.rawEnabled(type);
    final masterOn = service.masterEnabled;

    return GestureDetector(
      onTap: masterOn
          ? () {
              HapticFeedback.selectionClick();
              service.toggle(type);
            }
          : null,
      child: AnimatedOpacity(
        opacity: masterOn ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0D1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled && masterOn
                  ? primary.withValues(alpha: 0.3)
                  : Colors.white10,
            ),
          ),
          child: Row(children: [
            Icon(icon, size: 20,
                color: enabled && masterOn ? primary : Colors.white38),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled && masterOn ? Colors.white : Colors.white60)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ])),
            Switch(
              value: enabled,
              onChanged: masterOn
                  ? (_) {
                      HapticFeedback.selectionClick();
                      service.toggle(type);
                    }
                  : null,
              activeTrackColor: primary,
              inactiveThumbColor: Colors.white24,
            ),
          ]),
        ),
      ),
    );
  }
}
