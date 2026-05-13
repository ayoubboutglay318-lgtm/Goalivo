import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match_models.dart';
import '../services/reactions_service.dart';
import '../utils/match_vibe.dart';
import 'match_aura.dart';
import 'match_vibe_bar.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, this.onTap, this.reactionsService});
  final FootballMatch match;
  final VoidCallback? onTap;
  final ReactionsService? reactionsService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = match.fixture.status?.short ?? 'NS';
    final isLive = {'1H', '2H', 'HT', 'ET', 'P'}.contains(status);
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

    return MatchAura(
      vibe: vibe,
      child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: isLive
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              : null,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
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
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(width: 16),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      [leagueName, if ((round ?? '').isNotEmpty) round!].join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
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
              const SizedBox(height: 14),
              // Teams + Score
              Row(
                children: [
                  Expanded(
                    child: _TeamBlock(
                      name: homeName,
                      logo: homeLogo,
                      winner: homeWinner,
                      align: CrossAxisAlignment.center,
                    ),
                  ),
                  _ScoreCenter(
                    homeGoals: homeGoals,
                    awayGoals: awayGoals,
                    isLive: isLive,
                    status: status,
                  ),
                  Expanded(
                    child: _TeamBlock(
                      name: awayName,
                      logo: awayLogo,
                      winner: awayWinner,
                      align: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(child: MatchVibeBar(match: match, compact: true)),
            ],
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
    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Icon(
              Icons.circle,
              size: 6,
              color: Colors.white.withValues(alpha: _pulse.value),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.elapsed != null ? "${widget.elapsed}'" : 'LIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
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
    final label = _label();
    final isFinished = status == 'FT' || status == 'AET' || status == 'PEN';
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isFinished
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
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
    required this.align,
  });
  final String name;
  final String? logo;
  final bool winner;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: align,
      children: [
        _LogoWidget(logo: logo, name: name, size: 52),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: winner ? FontWeight.w800 : FontWeight.w500,
            color: winner
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
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
  });
  final int? homeGoals;
  final int? awayGoals;
  final bool isLive;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasScore = homeGoals != null || awayGoals != null;
    final scoreColor = isLive ? Colors.red : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: hasScore
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${homeGoals ?? 0}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '-',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1,
                    ),
                  ),
                ),
                Text(
                  '${awayGoals ?? 0}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                    height: 1,
                  ),
                ),
              ],
            )
          : Text(
              'vs',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
    );
  }
}
