import 'package:flutter/material.dart';

import '../models/match_models.dart';
import '../utils/match_vibe.dart';

class MatchVibeBar extends StatelessWidget {
  const MatchVibeBar({super.key, required this.match, this.compact = false});
  final FootballMatch match;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final vibe = MatchVibe.from(match);
    return compact
        ? _CompactVibe(vibe: vibe)
        : _FullVibeCard(vibe: vibe, match: match);
  }
}

// ── Compact chip shown on match cards ─────────────────────────────────────────

class _CompactVibe extends StatelessWidget {
  const _CompactVibe({required this.vibe});
  final MatchVibe vibe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: vibe.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: vibe.color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(vibe.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            vibe.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: vibe.color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full card shown in match detail ───────────────────────────────────────────

class _FullVibeCard extends StatelessWidget {
  const _FullVibeCard({required this.vibe, required this.match});
  final MatchVibe vibe;
  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Match Vibe',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _CompactVibe(vibe: vibe),
              ],
            ),
            const SizedBox(height: 14),

            // Excitement bar
            _SectionLabel(label: 'Excitement', theme: theme),
            const SizedBox(height: 6),
            _GlowBar(value: vibe.score / 100, color: vibe.color),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vibe.score.round()}/100',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: vibe.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  vibe.dramaLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Momentum bar
            _SectionLabel(label: 'Momentum', theme: theme),
            const SizedBox(height: 6),
            _MomentumBar(
              homeMomentum: vibe.homeMomentum,
              homeName: homeName,
              awayName: awayName,
            ),

            if (vibe.goalsCount > 0 || vibe.redCards > 0) ...[
              const SizedBox(height: 16),
              _StatChips(vibe: vibe),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.theme});
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            // Track
            Container(
              height: 8,
              width: width,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 8,
              width: width * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.7), color],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MomentumBar extends StatelessWidget {
  const _MomentumBar({
    required this.homeMomentum,
    required this.homeName,
    required this.awayName,
  });
  final double homeMomentum;
  final String homeName;
  final String awayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColor = Colors.green.shade400;
    final awayColor = Colors.blue.shade400;
    final homeW = homeMomentum;
    final awayW = 1.0 - homeMomentum;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final total = constraints.maxWidth;
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 8,
                    width: total * homeW,
                    color: homeColor,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 8,
                    width: total * awayW,
                    color: awayColor,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(homeMomentum * 100).round()}% ${_truncate(homeName)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: homeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_truncate(awayName)} ${((1 - homeMomentum) * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: awayColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _truncate(String name) {
    final words = name.split(' ');
    return words.length > 1 ? words.first : name;
  }
}

class _StatChips extends StatelessWidget {
  const _StatChips({required this.vibe});
  final MatchVibe vibe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (vibe.goalsCount > 0)
          _Chip(
            label: '${vibe.goalsCount} goal${vibe.goalsCount == 1 ? '' : 's'}',
            icon: '⚽',
            color: Colors.green,
          ),
        if (vibe.redCards > 0)
          _Chip(
            label: '${vibe.redCards} red card${vibe.redCards == 1 ? '' : 's'}',
            icon: '🟥',
            color: Colors.red,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});
  final String label;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
