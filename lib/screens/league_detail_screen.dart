import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/league_models.dart';
import '../models/match_models.dart';
import '../models/standing_models.dart';
import '../services/football_api_service.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class LeagueDetailScreen extends StatefulWidget {
  const LeagueDetailScreen({
    super.key,
    required this.league,
    required this.apiService,
  });

  final LeagueItem league;
  final FootballApiService apiService;

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen> {
  late Future<_LeagueData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_LeagueData> _loadData() async {
    final leagueId = widget.league.league?.id;
    final results = await Future.wait([
      widget.apiService.getStandings(),
      widget.apiService.getTodayMatches(),
      widget.apiService.getYesterdayMatches(),
      widget.apiService.getTomorrowMatches(),
    ]);

    final standings = results[0] as List<StandingGroup>;
    final allMatches = [
      ...(results[1] as List<FootballMatch>),
      ...(results[2] as List<FootballMatch>),
      ...(results[3] as List<FootballMatch>),
    ];

    final group = leagueId != null
        ? standings.where((g) => g.league?.id == leagueId).firstOrNull
        : null;

    final matches = leagueId != null
        ? allMatches.where((m) => m.league.id == leagueId).toList()
        : <FootballMatch>[];

    matches.sort((a, b) {
      final da = a.fixture.date;
      final db = b.fixture.date;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return _LeagueData(standingGroup: group, matches: matches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = widget.league.league;
    final country = widget.league.country;
    final currentSeason =
        widget.league.seasons.where((s) => s.current == true).firstOrNull;

    return Scaffold(
      body: FutureBuilder<_LeagueData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _LeagueHeader(
                    info: info,
                    country: country,
                    season: currentSeason,
                  ),
                ),
                title: Text(info?.name ?? 'League', style: const TextStyle(fontSize: 14)),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load data\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else ...[
                if (snapshot.data?.standingGroup != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text('Standings',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _StandingsCard(group: snapshot.data!.standingGroup!),
                    ),
                  ),
                ],
                if (snapshot.data?.matches.isNotEmpty == true) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('Matches',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList.separated(
                      itemCount: snapshot.data!.matches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final match = snapshot.data!.matches[i];
                        return MatchCard(
                          match: match,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MatchDetailScreen(match: match, apiService: widget.apiService)),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No recent or upcoming matches',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LeagueData {
  const _LeagueData({required this.standingGroup, required this.matches});
  final StandingGroup? standingGroup;
  final List<FootballMatch> matches;
}

class _LeagueHeader extends StatelessWidget {
  const _LeagueHeader({required this.info, required this.country, required this.season});
  final LeagueInfo? info;
  final LeagueCountry? country;
  final LeagueSeason? season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.surfaceContainerHighest, theme.colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Row(
        children: [
          if ((info?.logo ?? '').isNotEmpty)
            Image.network(
              info!.logo!,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 72),
            ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info?.name ?? 'League',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((country?.name ?? '').isNotEmpty)
                  Row(
                    children: [
                      if ((country?.flag ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            country!.flag!,
                            width: 18,
                            height: 12,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      Text(
                        country!.name!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                if (season != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Season ${season!.year}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (season!.current == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Current',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        if ((info?.type ?? '').isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            info!.type!,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsCard extends StatelessWidget {
  const _StandingsCard({required this.group});
  final StandingGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = group.standings;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: 28),
                const Expanded(child: SizedBox()),
                ...[' P', ' W', ' D', ' L', 'GD', 'Pts'].map(
                  (h) => SizedBox(
                    width: h == 'Pts' ? 36 : 28,
                    child: Text(h.trim(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return _StandingRowWidget(row: row, isLast: i == rows.length - 1);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StandingRowWidget extends StatelessWidget {
  const _StandingRowWidget({required this.row, required this.isLast});
  final StandingRow row;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desc = (row.description ?? '').toLowerCase();
    final rankColor = _rankColor(desc);
    final logo = row.team?.logo ?? '';
    final name = row.team?.name ?? '';
    final gd = row.goalsDiff ?? 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                            color: rankColor, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Text('${row.rank ?? '-'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: rankColor != Colors.transparent
                              ? rankColor
                              : theme.colorScheme.onSurface,
                        )),
                  ],
                ),
              ),
              logo.isNotEmpty
                  ? Image.network(logo,
                      width: 18, height: 18, fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _circle(name))
                  : _circle(name),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ),
              ...[
                '${row.all?.played ?? '-'}',
                '${row.all?.win ?? '-'}',
                '${row.all?.draw ?? '-'}',
                '${row.all?.lose ?? '-'}',
                gd > 0 ? '+$gd' : '$gd',
              ].map((v) => SizedBox(
                    width: 28,
                    child: Text(v,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  )),
              SizedBox(
                width: 36,
                child: Text('${row.points ?? '-'}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface)),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 12, endIndent: 12, color: Color(0xFF222222)),
      ],
    );
  }

  Color _rankColor(String desc) {
    if (desc.contains('relegation')) return Colors.red.shade400;
    if (desc.contains('playoff') || desc.contains('play-off')) {
      return Colors.orange.shade400;
    }
    if (desc.contains('promotion') ||
        desc.contains('champions league') ||
        desc.contains('europa')) {
      return Colors.green.shade400;
    }
    return Colors.transparent;
  }

  Widget _circle(String name) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white70),
      ),
    );
  }
}

// ignore: unused_element
String _formatDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('d MMM').format(date.toLocal());
}
