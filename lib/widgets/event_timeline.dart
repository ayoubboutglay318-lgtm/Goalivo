import 'package:flutter/material.dart';

import '../models/match_models.dart';

class EventTimeline extends StatelessWidget {
  const EventTimeline({
    super.key,
    required this.events,
    this.homeTeamId,
    this.showAll = false,
  });

  final List<MatchEvent> events;
  final int? homeTeamId;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final sorted = [...events]..sort((a, b) {
        final am = a.time?.elapsed ?? 0;
        final bm = b.time?.elapsed ?? 0;
        return am.compareTo(bm);
      });

    final visible = showAll ? sorted : sorted.take(6).toList();
    final items = _buildItems(visible);

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          if (item is _HalfTimeSeparator)
            _HalfTimeDivider(label: item.label)
          else if (item is MatchEvent)
            _EventRow(event: item, isHome: item.team?.id == homeTeamId),
        if (!showAll && events.length > visible.length)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${events.length - visible.length} more events',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }

  List<dynamic> _buildItems(List<MatchEvent> sorted) {
    final result = <dynamic>[];
    bool htInserted = false;
    bool etInserted = false;

    for (final event in sorted) {
      final min = event.time?.elapsed ?? 0;
      if (!htInserted && min > 45) {
        result.add(_HalfTimeSeparator('Half Time'));
        htInserted = true;
      }
      if (!etInserted && min > 90) {
        result.add(_HalfTimeSeparator('Extra Time'));
        etInserted = true;
      }
      result.add(event);
    }
    return result;
  }
}

class _HalfTimeSeparator {
  const _HalfTimeSeparator(this.label);
  final String label;
}

class _HalfTimeDivider extends StatelessWidget {
  const _HalfTimeDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.isHome});
  final MatchEvent event;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = (event.type ?? '').toLowerCase();
    final detail = (event.detail ?? '').toLowerCase();
    final minute = event.time?.elapsed;
    final extra = event.time?.extra;
    final minuteStr = minute != null
        ? (extra != null ? "$minute+$extra'" : "$minute'")
        : '--';

    final icon = _eventIcon(type, detail);
    final iconColor = _eventColor(type, detail);
    final player = event.player?.name ?? '';
    final assist = event.assist?.name ?? '';

    Widget eventContent = _EventContent(
      icon: icon,
      iconColor: iconColor,
      type: type,
      detail: event.detail ?? '',
      player: player,
      assist: assist,
      isHome: isHome,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Home side
          Expanded(
            child: isHome ? eventContent : const SizedBox.shrink(),
          ),
          // Center: time badge
          Container(
            width: 52,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.4), width: 1),
            ),
            child: Text(
              minuteStr,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: iconColor,
                fontSize: 11,
              ),
            ),
          ),
          // Away side
          Expanded(
            child: !isHome ? eventContent : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _eventIcon(String type, String detail) {
    if (type == 'goal' || type.contains('goal')) {
      if (detail.contains('own goal')) return Icons.sports_soccer;
      if (detail.contains('penalty')) return Icons.sports_soccer;
      return Icons.sports_soccer;
    }
    if (type == 'card') {
      if (detail.contains('red') || detail.contains('second yellow')) {
        return Icons.rectangle;
      }
      return Icons.rectangle;
    }
    if (type == 'subst') return Icons.swap_vert;
    if (type == 'var') return Icons.videocam_outlined;
    return Icons.circle_outlined;
  }

  Color _eventColor(String type, String detail) {
    if (type == 'goal' || type.contains('goal')) {
      if (detail.contains('own goal')) return Colors.red.shade400;
      return Colors.green.shade400;
    }
    if (type == 'card') {
      if (detail.contains('red') || detail.contains('second yellow')) {
        return Colors.red.shade500;
      }
      return Colors.amber.shade600;
    }
    if (type == 'subst') return Colors.blue.shade400;
    if (type == 'var') return Colors.purple.shade400;
    return Colors.grey.shade500;
  }
}

class _EventContent extends StatelessWidget {
  const _EventContent({
    required this.icon,
    required this.iconColor,
    required this.type,
    required this.detail,
    required this.player,
    required this.assist,
    required this.isHome,
  });

  final IconData icon;
  final Color iconColor;
  final String type;
  final String detail;
  final String player;
  final String assist;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoal = type == 'goal' || type.contains('goal');
    final isCard = type == 'card';
    final isSubst = type == 'subst';

    Widget iconWidget;
    if (isCard) {
      final isRed = detail.toLowerCase().contains('red') ||
          detail.toLowerCase().contains('second yellow');
      iconWidget = Container(
        width: 14,
        height: 18,
        decoration: BoxDecoration(
          color: isRed ? Colors.red.shade500 : Colors.amber.shade600,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else {
      iconWidget = Icon(icon, size: 16, color: iconColor);
    }

    String label = player;
    String subLabel = '';

    if (isGoal && assist.isNotEmpty) {
      subLabel = 'Assist: $assist';
    }
    if (isSubst) {
      label = '▲ $player';
      if (assist.isNotEmpty) subLabel = '▼ $assist';
    }
    if (detail.toLowerCase().contains('own goal')) {
      subLabel = 'Own Goal';
    }
    if (detail.toLowerCase().contains('penalty')) {
      subLabel = subLabel.isNotEmpty ? '$subLabel · Penalty' : 'Penalty';
    }

    final children = [
      iconWidget,
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          crossAxisAlignment: isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty)
              Text(
                label,
                textAlign: isHome ? TextAlign.right : TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isGoal ? FontWeight.w800 : FontWeight.w600,
                  color: isGoal ? iconColor : theme.colorScheme.onSurface,
                ),
              ),
            if (subLabel.isNotEmpty)
              Text(
                subLabel,
                textAlign: isHome ? TextAlign.right : TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    ];

    return Row(
      mainAxisAlignment: isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isHome ? children.reversed.toList() : children,
    );
  }
}
