import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/match_models.dart';
import '../services/football_api_service.dart';
import '../services/notification_service.dart';
import '../widgets/event_timeline.dart';
import '../widgets/info_chip.dart';
import '../widgets/man_of_match_widget.dart';
import '../widgets/player_ratings_widget.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.match,
    this.apiService,
  });
  final FootballMatch match;
  final FootballApiService? apiService;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Future<List<MatchTeamStats>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Preload stats immediately
    final id = widget.match.fixture.id;
    if (id != null && widget.apiService != null) {
      _statsFuture = widget.apiService!.getMatchStats(id);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    HapticFeedback.selectionClick();
    final id = widget.match.fixture.id;
    if (id == null || widget.apiService == null) return;
    if (_tabController.index == 2 && _statsFuture == null) {
      setState(() => _statsFuture = widget.apiService!.getMatchStats(id));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          // Hero header
          _HeroScoreBoard(
            match: match,
            isLive: isLive,
            status: status,
            homeGoals: homeGoals,
            awayGoals: awayGoals,
          ),
          // Tabs
          Material(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Events'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  match: match,
                  homeName: homeName,
                  awayName: awayName,
                  status: status,
                ),
                _EventsTab(match: match),
                _StatsTab(
                  future: _statsFuture,
                  match: match,
                  hasApiService: widget.apiService != null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.match,
    required this.homeName,
    required this.awayName,
    required this.status,
  });
  final FootballMatch match;
  final String homeName;
  final String awayName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (status == 'NS' && match.fixture.date != null && match.fixture.date!.isAfter(DateTime.now())) ...[
          _RemindMeButton(match: match),
          const SizedBox(height: 10),
        ],
        _InfoRow(match: match),
        const SizedBox(height: 14),
        if (match.score?.halftime != null)
          _ScoreBreakdown(score: match.score!),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Events tab ────────────────────────────────────────────────────────────────

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.match});
  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    if (match.events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.sports_soccer_outlined, size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No events yet',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Match events will appear here once the game kicks off.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EventTimeline(
            events: match.events,
            homeTeamId: match.teams.home.id,
            showAll: true),
        const SizedBox(height: 16),
        PlayerRatingsWidget(match: match),
        const SizedBox(height: 16),
        ManOfMatchWidget(match: match),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Stats tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.future, required this.match, required this.hasApiService});
  final Future<List<MatchTeamStats>>? future;
  final FootballMatch match;
  final bool hasApiService;

  @override
  Widget build(BuildContext context) {
    if (future == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.bar_chart_outlined, size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Stats not available', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Stats will appear once live data becomes available.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
    }
    return FutureBuilder<List<MatchTeamStats>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _StatsSkeleton();
        }
        final stats = snap.data ?? [];
        if (stats.isEmpty || stats.every((s) => s.stats.isEmpty)) {
          return Center(
            child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bar_chart_outlined, size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text('Stats will appear once live data becomes available.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ])),
          );
        }
        final home = stats.isNotEmpty ? stats[0] : null;
        final away = stats.length > 1 ? stats[1] : null;
        return _StatsView(home: home, away: away, match: match);
      },
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.home, required this.away, required this.match});
  final MatchTeamStats? home;
  final MatchTeamStats? away;
  final FootballMatch match;

  static const _wantedStats = [
    'Ball Possession', 'Total Shots', 'Shots on Goal',
    'Blocked Shots', 'Corner Kicks', 'Fouls',
    'Yellow Cards', 'Red Cards', 'Offsides', 'Passes accurate',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <_StatRow>[];
    for (final label in _wantedStats) {
      final hVal = home?.get(label) ?? '0';
      final aVal = away?.get(label) ?? '0';
      final hNum = double.tryParse(hVal.replaceAll('%', '')) ?? 0;
      final aNum = double.tryParse(aVal.replaceAll('%', '')) ?? 0;
      final total = hNum + aNum;
      rows.add(_StatRow(
        label: label,
        homeRaw: hVal,
        awayRaw: aVal,
        homeRatio: total > 0 ? hNum / total : 0.5,
      ));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Team headers
        Row(children: [
          Expanded(child: Text(match.teams.home.name ?? 'Home',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('STATS', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: theme.colorScheme.onSurfaceVariant)),
          Expanded(child: Text(match.teams.away.name ?? 'Away',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 16),
        ...rows.map((r) => _StatBarRow(row: r)),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _StatRow {
  const _StatRow({required this.label, required this.homeRaw, required this.awayRaw, required this.homeRatio});
  final String label;
  final String homeRaw;
  final String awayRaw;
  final double homeRatio;
}

class _StatBarRow extends StatelessWidget {
  const _StatBarRow({required this.row});
  final _StatRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(children: [
            Text(row.homeRaw,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: primary)),
            Expanded(child: Text(row.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
            Text(row.awayRaw,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Row(children: [
                Expanded(
                  flex: (row.homeRatio * 100).round(),
                  child: Container(color: primary),
                ),
                Expanded(
                  flex: ((1 - row.homeRatio) * 100).round(),
                  child: Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


// ── Hero score board ──────────────────────────────────────────────────────────

class _HeroScoreBoard extends StatefulWidget {
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
  State<_HeroScoreBoard> createState() => _HeroScoreBoardState();
}

class _HeroScoreBoardState extends State<_HeroScoreBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.isLive) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeName = widget.match.teams.home.name ?? 'Home';
    final awayName = widget.match.teams.away.name ?? 'Away';
    final homeLogo = widget.match.teams.home.logo;
    final awayLogo = widget.match.teams.away.logo;
    final homeWinner = widget.match.teams.home.winner == true;
    final awayWinner = widget.match.teams.away.winner == true;
    final statusLong = widget.match.fixture.status?.long ?? widget.status;
    final isLive = widget.isLive;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [const Color(0xFF0F0000), const Color(0xFF200404), const Color(0xFF141414)]
              : [const Color(0xFF0A0A0A), const Color(0xFF141414)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: isLive ? const [0, 0.55, 1] : const [0, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back button row
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(children: [
                  Text(
                    widget.match.league.name ?? 'Match',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if ((widget.match.league.round ?? '').isNotEmpty)
                    Text(
                      widget.match.league.round!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                ]),
              ),
              if (isLive)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _LiveBadge(elapsed: widget.match.fixture.status?.elapsed),
                )
              else
                const SizedBox(width: 48),
            ]),
            // Score area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 22),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(child: _TeamCol(name: homeName, logo: homeLogo, winner: homeWinner)),
                // Score block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // Score numbers with live pulse
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) => Transform.scale(
                        scale: isLive ? _pulse.value : 1.0,
                        child: child,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isLive
                              ? Colors.red.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLive
                                ? Colors.red.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            widget.homeGoals?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: isLive ? Colors.redAccent.shade100 : Colors.white,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                color: Colors.white38,
                                height: 1,
                              ),
                            ),
                          ),
                          Text(
                            widget.awayGoals?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: isLive ? Colors.redAccent.shade100 : Colors.white,
                              height: 1,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLong,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ),
                Expanded(child: _TeamCol(name: awayName, logo: awayLogo, winner: awayWinner)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCol extends StatelessWidget {
  const _TeamCol({required this.name, required this.logo, required this.winner});
  final String name;
  final String? logo;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _TeamLogo(logo: logo, name: name, size: 54),
      const SizedBox(height: 8),
      Text(name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: winner ? Colors.greenAccent : Colors.white,
            fontWeight: winner ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          )),
      if (winner) ...[
        const SizedBox(height: 3),
        const Icon(Icons.emoji_events, size: 13, color: Colors.amber),
      ],
    ]);
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
        width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.bold, color: Colors.white)),
  );
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({this.elapsed});
  final int? elapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.circle, size: 8, color: Colors.white),
        const SizedBox(width: 4),
        Text(elapsed != null ? "$elapsed'" : 'LIVE',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.match});
  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final date = match.fixture.date;
    final formatted = date != null ? DateFormat('EEEE, d MMMM yyyy • HH:mm').format(date.toLocal()) : null;
    final venue = match.fixture.venue;
    final referee = match.fixture.referee;
    final round = match.league.round;

    return Wrap(spacing: 8, runSpacing: 8, children: [
      if (formatted != null) InfoChip(icon: Icons.schedule_outlined, label: formatted),
      if ((venue?.name ?? '').isNotEmpty)
        InfoChip(icon: Icons.location_on_outlined,
            label: [venue!.name!, if ((venue.city ?? '').isNotEmpty) venue.city!].join(', ')),
      if ((referee ?? '').isNotEmpty) InfoChip(icon: Icons.sports_outlined, label: referee!),
      if ((round ?? '').isNotEmpty) InfoChip(icon: Icons.flag_outlined, label: round!),
    ]);
  }
}

// ── Score breakdown ───────────────────────────────────────────────────────────

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.score});
  final MatchScore score;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, int?, int?)>[
      if (score.halftime != null) ('Half Time', score.halftime!.home, score.halftime!.away),
      if (score.fulltime != null && (score.fulltime!.home != null || score.fulltime!.away != null))
        ('Full Time', score.fulltime!.home, score.fulltime!.away),
      if (score.extratime != null && (score.extratime!.home != null || score.extratime!.away != null))
        ('Extra Time', score.extratime!.home, score.extratime!.away),
      if (score.penalty != null && (score.penalty!.home != null || score.penalty!.away != null))
        ('Penalty', score.penalty!.home, score.penalty!.away),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Score Breakdown',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...rows.map((row) {
            final (label, home, away) = row;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: Text('${home ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(label, textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall)),
                Expanded(child: Text('${away ?? '-'}', textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

// ── Skeleton loaders ──────────────────────────────────────────────────────────

class _PitchSkeleton extends StatefulWidget {
  const _PitchSkeleton();
  @override
  State<_PitchSkeleton> createState() => _PitchSkeletonState();
}

class _PitchSkeletonState extends State<_PitchSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final alpha = 0.05 + _anim.value * 0.08;
        final c = Colors.white.withValues(alpha: alpha);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(height: 200, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Container(height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)))),
              const SizedBox(width: 40),
              Expanded(child: Container(height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)))),
            ]),
            const SizedBox(height: 12),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (_) => Container(
                width: 40, height: 40, margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ))),
            )),
          ]),
        );
      },
    );
  }
}

class _StatsSkeleton extends StatefulWidget {
  const _StatsSkeleton();
  @override
  State<_StatsSkeleton> createState() => _StatsSkeletonState();
}

class _StatsSkeletonState extends State<_StatsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final alpha = 0.05 + _anim.value * 0.08;
        final c = Colors.white.withValues(alpha: alpha);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(8, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(children: [
              Row(children: [
                Container(width: 36, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5))),
                const Spacer(),
                Container(width: 80, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5))),
                const Spacer(),
                Container(width: 36, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5))),
              ]),
              const SizedBox(height: 8),
              Container(height: 5, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
            ]),
          )),
        );
      },
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
          const SnackBar(content: Text('Please enable notifications in Settings.')));
      return;
    }
    final id = widget.match.fixture.id ?? 0;
    final home = widget.match.teams.home.name ?? 'Home';
    final away = widget.match.teams.away.name ?? 'Away';
    await NotificationService.instance.scheduleMatchReminder(
        fixtureId: id, homeTeam: home, awayTeam: away, kickOff: widget.match.fixture.date!);
    if (mounted) {
      setState(() => _reminded = true);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set — 15 min before $home vs $away!')));
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
