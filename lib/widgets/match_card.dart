import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match_models.dart';
import '../services/reactions_service.dart';
import '../utils/match_vibe.dart';
import 'match_aura.dart';

class MatchCard extends StatefulWidget {
  const MatchCard({super.key, required this.match, this.onTap, this.reactionsService});
  final FootballMatch match;
  final VoidCallback? onTap;
  final ReactionsService? reactionsService;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final match = widget.match;
    final status = match.fixture.status?.short ?? 'NS';
    final isLive = {'1H', '2H', 'HT', 'ET', 'P'}.contains(status);
    final isFinished = {'FT', 'AET', 'PEN'}.contains(status);
    final elapsed = match.fixture.status?.elapsed;
    final homeGoals = match.goals.home;
    final awayGoals = match.goals.away;
    final leagueName = match.league.name ?? '';
    final leagueLogo = match.league.logo;
    final round = match.league.round;
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';
    final homeLogo = match.teams.home.logo;
    final awayLogo = match.teams.away.logo;
    final homeWinner = match.teams.home.winner == true;
    final awayWinner = match.teams.away.winner == true;
    final vibe = MatchVibe.from(match);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: MatchAura(
      vibe: vibe,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? const Color(0xFF111111) : Colors.white,
          border: Border.all(
            color: isLive
                ? Colors.red.withValues(alpha: 0.5)
                : isDark
                    ? const Color(0xFF252525)
                    : const Color(0xFFE0E0E0),
            width: isLive ? 1.5 : 1,
          ),
          boxShadow: isLive
              ? [BoxShadow(color: Colors.red.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: (isLive ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // League row
                  Row(
                    children: [
                      if ((leagueLogo ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            leagueLogo!,
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox(width: 15),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          [leagueName, if ((round ?? '').isNotEmpty) round!].join(' · '),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLive)
                        _LivePill(elapsed: elapsed)
                      else
                        _StatusLabel(status: status, date: match.fixture.date),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Teams + Score
                  Row(
                    children: [
                      Expanded(
                        child: _TeamBlock(
                          name: homeName,
                          logo: homeLogo,
                          winner: homeWinner,
                          isFinished: isFinished,
                        ),
                      ),
                      _ScoreCenter(
                        homeGoals: homeGoals,
                        awayGoals: awayGoals,
                        isLive: isLive,
                        status: status,
                        isDark: isDark,
                      ),
                      Expanded(
                        child: _TeamBlock(
                          name: awayName,
                          logo: awayLogo,
                          winner: awayWinner,
                          isFinished: isFinished,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}

class _LivePill extends StatefulWidget {
  const _LivePill({this.elapsed});
  final int? elapsed;

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: _pulse.value),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.elapsed != null ? "${widget.elapsed}'" : 'LIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status, this.date});
  final String status;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = {'FT', 'AET', 'PEN'}.contains(status);
    final isScheduled = status == 'NS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFinished
            ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
            : isScheduled
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFinished
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _label() {
    if (status == 'FT') return 'FT';
    if (status == 'AET') return 'AET';
    if (status == 'PEN') return 'PEN';
    if (status == 'HT') return 'HT';
    if (status == 'NS' && date != null) {
      return DateFormat('HH:mm').format(date!.toLocal());
    }
    return status;
  }
}

class _TeamBlock extends StatelessWidget {
  const _TeamBlock({
    required this.name,
    required this.logo,
    required this.winner,
    required this.isFinished,
  });
  final String name;
  final String? logo;
  final bool winner;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (winner && isFinished)
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            _LogoWidget(logo: logo, name: name, size: 56),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: winner ? FontWeight.w800 : FontWeight.w500,
            color: winner && isFinished
                ? Colors.amber.shade400
                : theme.colorScheme.onSurface,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.logo, required this.name, this.size = 44});
  final String? logo;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if ((logo ?? '').isNotEmpty) {
      return Image.network(
        logo!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScoreCenter extends StatelessWidget {
  const _ScoreCenter({
    required this.homeGoals,
    required this.awayGoals,
    required this.isLive,
    required this.status,
    required this.isDark,
  });
  final int? homeGoals;
  final int? awayGoals;
  final bool isLive;
  final String status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasScore = homeGoals != null || awayGoals != null;
    final scoreColor = isLive ? Colors.red : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (hasScore)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isLive
                    ? Colors.red.withValues(alpha: 0.12)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLive
                      ? Colors.red.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${homeGoals ?? 0}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    '${awayGoals ?? 0}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                      height: 1,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'VS',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
