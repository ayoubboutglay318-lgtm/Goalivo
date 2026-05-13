import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/match_vibe.dart';

/// Animated glowing border + background aura that wraps a child widget.
/// Pulse speed and intensity are driven by VibeLevel.
class MatchAura extends StatefulWidget {
  const MatchAura({
    super.key,
    required this.vibe,
    required this.child,
    this.borderRadius = 18,
  });
  final MatchVibe vibe;
  final Widget child;
  final double borderRadius;

  @override
  State<MatchAura> createState() => _MatchAuraState();
}

class _MatchAuraState extends State<MatchAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration());
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (_shouldAnimate()) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MatchAura old) {
    super.didUpdateWidget(old);
    if (old.vibe.level != widget.vibe.level) {
      _ctrl.duration = _duration();
      if (_shouldAnimate()) {
        _ctrl.repeat(reverse: true);
      } else {
        _ctrl.stop();
        _ctrl.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Duration _duration() => switch (widget.vibe.level) {
    VibeLevel.chaos    => const Duration(milliseconds: 350),
    VibeLevel.electric => const Duration(milliseconds: 600),
    VibeLevel.hot      => const Duration(milliseconds: 1000),
    _                  => const Duration(milliseconds: 1400),
  };

  bool _shouldAnimate() =>
      widget.vibe.level == VibeLevel.chaos ||
      widget.vibe.level == VibeLevel.electric ||
      widget.vibe.level == VibeLevel.hot;

  double _glowBlur() => switch (widget.vibe.level) {
    VibeLevel.chaos    => 28,
    VibeLevel.electric => 20,
    VibeLevel.hot      => 14,
    VibeLevel.average  => 6,
    _                  => 0,
  };

  double _glowSpread() => switch (widget.vibe.level) {
    VibeLevel.chaos    => 2,
    VibeLevel.electric => 1.5,
    VibeLevel.hot      => 1,
    _                  => 0,
  };

  @override
  Widget build(BuildContext context) {
    if (widget.vibe.level == VibeLevel.cold) return widget.child;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final alpha = _shouldAnimate() ? _pulse.value : 0.5;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.vibe.color.withValues(alpha: alpha * 0.55),
                blurRadius: _glowBlur(),
                spreadRadius: _glowSpread(),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Full-width atmospheric aura strip shown below the score in match detail.
class AuraAtmosphere extends StatefulWidget {
  const AuraAtmosphere({super.key, required this.vibe});
  final MatchVibe vibe;

  @override
  State<AuraAtmosphere> createState() => _AuraAtmosphereState();
}

class _AuraAtmosphereState extends State<AuraAtmosphere>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.vibe.color;
    final level = widget.vibe.level;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Text(
                  widget.vibe.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Aura',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      widget.vibe.dramaLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _AuraLevelBadge(vibe: widget.vibe),
              ],
            ),
            const SizedBox(height: 16),

            // Animated aura bar
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return _AuraBar(
                  progress: widget.vibe.score / 100,
                  color: color,
                  level: level,
                  animValue: _ctrl.value,
                );
              },
            ),
            const SizedBox(height: 16),

            // Momentum
            _MomentumSection(vibe: widget.vibe),

            // Crowd noise meter (animated)
            const SizedBox(height: 16),
            _CrowdNoiseMeter(vibe: widget.vibe, ctrl: _ctrl),

            // Stat chips
            if (widget.vibe.goalsCount > 0 || widget.vibe.redCards > 0) ...[
              const SizedBox(height: 14),
              _AuraStats(vibe: widget.vibe),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuraLevelBadge extends StatelessWidget {
  const _AuraLevelBadge({required this.vibe});
  final MatchVibe vibe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: vibe.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: vibe.color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(vibe.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            vibe.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: vibe.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraBar extends StatelessWidget {
  const _AuraBar({
    required this.progress,
    required this.color,
    required this.level,
    required this.animValue,
  });
  final double progress;
  final Color color;
  final VibeLevel level;
  final double animValue;

  @override
  Widget build(BuildContext context) {
    // For chaos/electric, the bar sparkles
    final sparkleFactor = level == VibeLevel.chaos
        ? (0.5 + 0.5 * sin(animValue * 2 * pi))
        : level == VibeLevel.electric
            ? (0.6 + 0.4 * sin(animValue * 2 * pi))
            : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXCITEMENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              '${(progress * 100).round()}/100',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                // Track
                Container(
                  height: 10,
                  width: w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Fill
                Container(
                  height: 10,
                  width: w * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.6),
                        color,
                        color.withValues(alpha: sparkleFactor),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6 * sparkleFactor),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MomentumSection extends StatelessWidget {
  const _MomentumSection({required this.vibe});
  final MatchVibe vibe;

  @override
  Widget build(BuildContext context) {
    final homeColor = Colors.green.shade400;
    final awayColor = Colors.blue.shade400;
    final homePct = vibe.homeMomentum;
    final awayPct = 1.0 - homePct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOMENTUM',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: w * homePct,
                    color: homeColor,
                  ),
                  Container(
                    height: 10,
                    width: w * awayPct,
                    color: awayColor,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(homePct * 100).round()}% Home',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: homeColor,
              ),
            ),
            Text(
              'Away ${(awayPct * 100).round()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: awayColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CrowdNoiseMeter extends StatelessWidget {
  const _CrowdNoiseMeter({required this.vibe, required this.ctrl});
  final MatchVibe vibe;
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    final baseLevel = vibe.score / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CROWD NOISE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            return Row(
              children: List.generate(20, (i) {
                final barBase = baseLevel;
                final noise = 0.15 * sin((ctrl.value * 2 * pi) + i * 0.8);
                final height = ((barBase + noise) * 32).clamp(2.0, 32.0);
                final active = (i / 20) < barBase;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: height,
                    decoration: BoxDecoration(
                      color: active
                          ? vibe.color.withValues(alpha: 0.7 + noise.abs())
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _AuraStats extends StatelessWidget {
  const _AuraStats({required this.vibe});
  final MatchVibe vibe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (vibe.goalsCount > 0)
          _chip('⚽ ${vibe.goalsCount} goal${vibe.goalsCount == 1 ? '' : 's'}', Colors.green),
        if (vibe.redCards > 0)
          _chip('🟥 ${vibe.redCards} red card${vibe.redCards == 1 ? '' : 's'}', Colors.red),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}
