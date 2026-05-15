import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match_models.dart';
import '../services/notification_service.dart';
import '../services/prediction_service.dart';
import '../services/reactions_service.dart';
import '../services/xp_service.dart';
import '../widgets/event_timeline.dart';
import '../widgets/info_chip.dart';
import '../widgets/man_of_match_widget.dart';
import '../utils/match_vibe.dart';
import '../widgets/match_aura.dart';
import '../widgets/player_ratings_widget.dart';
import '../widgets/prediction_widget.dart';
import '../widgets/reaction_bar.dart';
import 'profile_screen.dart';
import 'watch_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.match,
    this.xpService,
    this.reactionsService,
    this.predictionService,
  });
  final FootballMatch match;
  final XpService? xpService;
  final ReactionsService? reactionsService;
  final PredictionService? predictionService;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    _trackXp();
  }

  Future<void> _trackXp() async {
    final svc = widget.xpService;
    if (svc == null) return;
    final result = await svc.trackEvent(XpEvent.viewMatchDetail);
    if (mounted && result.xpGained > 0) {
      XpToast.show(context, xpGained: result.xpGained, newBadges: result.newBadges);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final theme = Theme.of(context);
    final status = match.fixture.status?.short ?? 'NS';
    final isLive = {'1H', '2H', 'HT', 'ET', 'P'}.contains(status);
    final homeGoals = match.goals.home;
    final awayGoals = match.goals.away;
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroScoreBoard(
                match: match,
                isLive: isLive,
                status: status,
                homeGoals: homeGoals,
                awayGoals: awayGoals,
              ),
            ),
            title: Text(
              match.league.name ?? 'Match',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              if (isLive)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _LiveBadge(elapsed: match.fixture.status?.elapsed),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Remind Me button (upcoming matches only)
                  if (status == 'NS' &&
                      match.fixture.date != null &&
                      match.fixture.date!.isAfter(DateTime.now())) ...[
                    _RemindMeButton(match: match),
                    const SizedBox(height: 10),
                  ],
                  // Watch button
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WatchScreen(
                          homeName: homeName,
                          awayName: awayName,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.live_tv),
                    label: const Text('Watch Live'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuraAtmosphere(vibe: MatchVibe.from(match)),
                  const SizedBox(height: 12),
                  if (widget.reactionsService != null && match.fixture.id != null)
                    ReactionBar(
                      fixtureId: match.fixture.id!,
                      reactionsService: widget.reactionsService!,
                    ),
                  const SizedBox(height: 16),
                  if (widget.predictionService != null)
                    PredictionWidget(
                      match: match,
                      predictionService: widget.predictionService!,
                      xpService: widget.xpService,
                    ),
                  if (widget.predictionService != null) const SizedBox(height: 16),
                  _InfoRow(match: match),
                  if (match.score?.halftime != null) ...[
                    const SizedBox(height: 16),
                    _ScoreBreakdown(score: match.score!),
                  ],
                  if (match.events.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Match Events',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EventTimeline(
                      events: match.events,
                      homeTeamId: match.teams.home.id,
                      showAll: true,
                    ),
                    const SizedBox(height: 16),
                    PlayerRatingsWidget(match: match),
                    const SizedBox(height: 16),
                    ManOfMatchWidget(match: match),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _HeroScoreBoard extends StatelessWidget {
  const _HeroScoreBoard({
    required this.match,
    required this.isLive,
    required this.status,
    required this.homeGoals,
    required this.awayGoals,
  });

  final FootballMatch match;
  final bool isLive;
  final String status;
  final int? homeGoals;
  final int? awayGoals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';
    final homeLogo = match.teams.home.logo;
    final awayLogo = match.teams.away.logo;
    final homeWinner = match.teams.home.winner == true;
    final awayWinner = match.teams.away.winner == true;
    final statusLong = match.fixture.status?.long ?? status;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [Colors.red.shade900, Colors.black87]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _TeamCol(name: homeName, logo: homeLogo, winner: homeWinner),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      homeGoals?.toString() ?? '-',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '-',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w200,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    Text(
                      awayGoals?.toString() ?? '-',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  statusLong,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: _TeamCol(name: awayName, logo: awayLogo, winner: awayWinner),
          ),
        ],
      ),
    );
  }
}

class _TeamCol extends StatelessWidget {
  const _TeamCol({
    required this.name,
    required this.logo,
    required this.winner,
  });
  final String name;
  final String? logo;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TeamLogo(logo: logo, name: name, size: 56),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: winner ? Colors.greenAccent : Colors.white,
            fontWeight: winner ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        if (winner) ...[
          const SizedBox(height: 4),
          const Icon(Icons.emoji_events, size: 14, color: Colors.amber),
        ],
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.logo, required this.name, required this.size});
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
      decoration: const BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({this.elapsed});
  final int? elapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            elapsed != null ? "$elapsed'" : 'LIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.match});
  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final date = match.fixture.date;
    final formatted = date != null
        ? DateFormat('EEEE, d MMMM yyyy • HH:mm').format(date.toLocal())
        : null;
    final venue = match.fixture.venue;
    final referee = match.fixture.referee;
    final round = match.league.round;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (formatted != null)
          InfoChip(icon: Icons.schedule_outlined, label: formatted),
        if ((venue?.name ?? '').isNotEmpty)
          InfoChip(
            icon: Icons.location_on_outlined,
            label: [
              venue!.name!,
              if ((venue.city ?? '').isNotEmpty) venue.city!,
            ].join(', '),
          ),
        if ((referee ?? '').isNotEmpty)
          InfoChip(icon: Icons.sports_outlined, label: referee!),
        if ((round ?? '').isNotEmpty)
          InfoChip(icon: Icons.flag_outlined, label: round!),
      ],
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.score});
  final MatchScore score;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, int?, int?)>[
      if (score.halftime != null)
        ('Half Time', score.halftime!.home, score.halftime!.away),
      if (score.fulltime != null &&
          (score.fulltime!.home != null || score.fulltime!.away != null))
        ('Full Time', score.fulltime!.home, score.fulltime!.away),
      if (score.extratime != null &&
          (score.extratime!.home != null || score.extratime!.away != null))
        ('Extra Time', score.extratime!.home, score.extratime!.away),
      if (score.penalty != null &&
          (score.penalty!.home != null || score.penalty!.away != null))
        ('Penalty', score.penalty!.home, score.penalty!.away),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...rows.map((row) {
              final (label, home, away) = row;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${home ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${away ?? '-'}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Remind Me button ──────────────────────────────────────────────────────────

class _RemindMeButton extends StatefulWidget {
  const _RemindMeButton({required this.match});
  final FootballMatch match;

  @override
  State<_RemindMeButton> createState() => _RemindMeButtonState();
}

class _RemindMeButtonState extends State<_RemindMeButton> {
  bool _reminded = false;

  Future<void> _setReminder() async {
    final granted = await NotificationService.instance.requestPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable notifications in Settings.')),
      );
      return;
    }
    final id = widget.match.fixture.id ?? 0;
    final home = widget.match.teams.home.name ?? 'Home';
    final away = widget.match.teams.away.name ?? 'Away';
    final kickOff = widget.match.fixture.date!;
    await NotificationService.instance.scheduleMatchReminder(
      fixtureId: id,
      homeTeam: home,
      awayTeam: away,
      kickOff: kickOff,
    );
    if (mounted) {
      setState(() => _reminded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set — 15 min before $home vs $away!')),
      );
    }
  }

  Future<void> _cancel() async {
    await NotificationService.instance.cancelReminder(widget.match.fixture.id ?? 0);
    if (mounted) setState(() => _reminded = false);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _reminded ? _cancel : _setReminder,
      icon: Icon(_reminded ? Icons.notifications_active : Icons.notifications_outlined, size: 18),
      label: Text(_reminded ? 'Reminder Set ✓' : 'Remind Me'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _reminded ? Colors.amber : Colors.white70,
        side: BorderSide(color: _reminded ? Colors.amber : Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
