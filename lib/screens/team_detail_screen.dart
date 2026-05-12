import 'package:flutter/material.dart';

import '../models/match_models.dart';
import '../models/team_models.dart';
import '../services/football_api_service.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({
    super.key,
    required this.team,
    required this.apiService,
  });

  final TeamItem team;
  final FootballApiService apiService;

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late Future<List<FootballMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
  }

  Future<List<FootballMatch>> _loadMatches() async {
    final teamId = widget.team.team?.id;
    if (teamId == null) return [];

    final results = await Future.wait([
      widget.apiService.getLiveMatches(),
      widget.apiService.getTodayMatches(),
      widget.apiService.getYesterdayMatches(),
      widget.apiService.getTomorrowMatches(),
    ]);

    final all = results.expand((l) => l).cast<FootballMatch>().toList();
    final filtered = all
        .where((m) => m.teams.home.id == teamId || m.teams.away.id == teamId)
        .toList();

    filtered.sort((a, b) {
      final da = a.fixture.date;
      final db = b.fixture.date;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = widget.team.team;
    final venue = widget.team.venue;
    final country = widget.team.country ?? info?.country ?? '';
    final founded = widget.team.founded ?? info?.founded;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _TeamHeader(
                info: info,
                country: country,
                founded: founded,
                venue: venue,
              ),
            ),
            title: Text(info?.name ?? 'Team', style: const TextStyle(fontSize: 14)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Recent & Upcoming Matches',
                  style:
                      theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          FutureBuilder<List<FootballMatch>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load matches',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
                );
              }
              final matches = snapshot.data ?? [];
              if (matches.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_soccer_outlined,
                              size: 48, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text('No recent or upcoming matches',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.separated(
                  itemCount: matches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final match = matches[i];
                    return MatchCard(
                      match: match,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MatchDetailScreen(match: match)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({
    required this.info,
    required this.country,
    required this.founded,
    required this.venue,
  });

  final TeamInfo? info;
  final String country;
  final int? founded;
  final TeamVenue? venue;

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
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
      child: Row(
        children: [
          _TeamLogo(logo: info?.logo, name: info?.name ?? '', size: 80),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info?.name ?? 'Team',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (country.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(country,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                if (founded != null) ...[
                  const SizedBox(height: 2),
                  Text('Founded $founded',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
                if ((venue?.name ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.stadium_outlined,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            venue!.name!,
                            if ((venue!.city ?? '').isNotEmpty) venue!.city!,
                          ].join(', '),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
                if (venue?.capacity != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCapacity(venue!.capacity!)} capacity',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCapacity(int cap) {
    if (cap >= 1000) return '${(cap / 1000).toStringAsFixed(0)}k';
    return '$cap';
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
      decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            fontSize: size * 0.38, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
