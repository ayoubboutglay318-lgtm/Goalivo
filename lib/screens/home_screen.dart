import 'dart:async';

import 'package:flutter/material.dart';

import '../models/league_models.dart';
import '../models/match_models.dart';
import '../models/standing_models.dart';
import '../models/team_models.dart';
import '../services/favorites_service.dart';
import '../services/football_api_service.dart';
import '../services/prediction_service.dart';
import '../services/reactions_service.dart';
import '../services/xp_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/match_card.dart';
import '../widgets/section_header.dart';
import 'league_detail_screen.dart';
import 'match_detail_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'team_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.favoritesService,
    required this.xpService,
    required this.reactionsService,
    required this.predictionService,
    this.themeMode = ThemeMode.dark,
    this.onToggleTheme,
  });
  final FootballApiService apiService;
  final FavoritesService favoritesService;
  final XpService xpService;
  final ReactionsService reactionsService;
  final PredictionService predictionService;
  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _liveRefreshTimer;

  bool _isSearching = false;
  String _searchQuery = '';

  late Future<List<FootballMatch>> _liveFuture;
  late Future<List<FootballMatch>> _todayFuture;
  late Future<List<FootballMatch>> _yesterdayFuture;
  late Future<List<FootballMatch>> _tomorrowFuture;
  late Future<List<StandingGroup>> _standingsFuture;
  late Future<List<TeamItem>> _teamsFuture;
  late Future<List<LeagueItem>> _leaguesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _primeFutures();
    _startLiveTimer();
    _tabController.addListener(_onTabChanged);
    widget.favoritesService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    widget.favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() => setState(() {});

  void _onTabChanged() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }
    if (_tabController.index == 0) {
      _startLiveTimer();
    } else {
      _liveRefreshTimer?.cancel();
    }
  }

  void _startLiveTimer() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && _tabController.index == 0) {
        setState(() {
          _liveFuture = widget.apiService.getLiveMatches();
        });
      }
    });
  }

  void _primeFutures() {
    _liveFuture = widget.apiService.getLiveMatches();
    _todayFuture = widget.apiService.getTodayMatches();
    _yesterdayFuture = widget.apiService.getYesterdayMatches();
    _tomorrowFuture = widget.apiService.getTomorrowMatches();
    _standingsFuture = widget.apiService.getStandings();
    _teamsFuture = widget.apiService.getTeams();
    _leaguesFuture = widget.apiService.getLeagues();
  }

  Future<void> _refreshTab(int index) async {
    setState(() {
      switch (index) {
        case 0:
          _liveFuture = widget.apiService.getLiveMatches();
          break;
        case 1:
          _todayFuture = widget.apiService.getTodayMatches();
          break;
        case 2:
          _yesterdayFuture = widget.apiService.getYesterdayMatches();
          break;
        case 3:
          _tomorrowFuture = widget.apiService.getTomorrowMatches();
          break;
        case 4:
          _standingsFuture = widget.apiService.getStandings();
          break;
        case 5:
          _teamsFuture = widget.apiService.getTeams();
          break;
        case 6:
          _leaguesFuture = widget.apiService.getLeagues();
          break;
        case 7:
          _liveFuture = widget.apiService.getLiveMatches();
          _todayFuture = widget.apiService.getTodayMatches();
          _yesterdayFuture = widget.apiService.getYesterdayMatches();
          _teamsFuture = widget.apiService.getTeams();
          break;
      }
    });
  }

  void _openMatchDetail(BuildContext context, FootballMatch match) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => MatchDetailScreen(
          match: match,
          xpService: widget.xpService,
          reactionsService: widget.reactionsService,
          predictionService: widget.predictionService,
        ),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favIds = widget.favoritesService.ids;

    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _closeSearch,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) =>
                    setState(() => _searchQuery = q.toLowerCase().trim()),
                decoration: const InputDecoration(
                  hintText: 'Search teams, leagues...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : Image.asset(
                'assets/logo.png',
                height: 36,
              ),
        actions: [
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _searchQuery = '';
                _searchController.clear();
              }),
            )
          else if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(
              icon: Icon(Icons.circle, size: 10, color: Colors.red),
              text: 'Live',
            ),
            const Tab(text: 'Today'),
            const Tab(text: 'Yesterday'),
            const Tab(text: 'Tomorrow'),
            const Tab(text: 'Standings'),
            const Tab(text: 'Teams'),
            const Tab(text: 'Leagues'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14),
                  const SizedBox(width: 4),
                  const Text('Favorites'),
                  if (favIds.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${favIds.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              icon: Icon(Icons.quiz_outlined, size: 14),
              text: 'Quiz',
            ),
            const Tab(
              icon: Icon(Icons.emoji_events, size: 14),
              text: 'Profile',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MatchesView(
            title: 'Live Matches',
            subtitle: 'Currently in play',
            future: _liveFuture,
            emptyMessage: 'No live matches right now.',
            onRefresh: () => _refreshTab(0),
            onMatchTap: (m) => _openMatchDetail(context, m),
            searchQuery: _searchQuery,
            reactionsService: widget.reactionsService,
          ),
          _MatchesView(
            title: 'Today',
            subtitle: "Today's football fixtures",
            future: _todayFuture,
            emptyMessage: 'No matches scheduled for today.',
            onRefresh: () => _refreshTab(1),
            onMatchTap: (m) => _openMatchDetail(context, m),
            searchQuery: _searchQuery,
            reactionsService: widget.reactionsService,
          ),
          _MatchesView(
            title: 'Yesterday',
            subtitle: 'Completed fixtures and results',
            future: _yesterdayFuture,
            emptyMessage: 'No matches found for yesterday.',
            onRefresh: () => _refreshTab(2),
            onMatchTap: (m) => _openMatchDetail(context, m),
            searchQuery: _searchQuery,
            reactionsService: widget.reactionsService,
          ),
          _MatchesView(
            title: 'Tomorrow',
            subtitle: 'Upcoming fixtures',
            future: _tomorrowFuture,
            emptyMessage: 'No matches scheduled for tomorrow.',
            onRefresh: () => _refreshTab(3),
            onMatchTap: (m) => _openMatchDetail(context, m),
            searchQuery: _searchQuery,
            reactionsService: widget.reactionsService,
          ),
          _StandingsView(
            future: _standingsFuture,
            onRefresh: () => _refreshTab(4),
          ),
          _TeamsView(
            future: _teamsFuture,
            onRefresh: () => _refreshTab(5),
            favoritesService: widget.favoritesService,
            searchQuery: _searchQuery,
            onTeamTap: (team) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TeamDetailScreen(team: team, apiService: widget.apiService),
              ),
            ),
          ),
          _LeaguesView(
            future: _leaguesFuture,
            onRefresh: () => _refreshTab(6),
            searchQuery: _searchQuery,
            onLeagueTap: (league) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LeagueDetailScreen(league: league, apiService: widget.apiService),
              ),
            ),
          ),
          _FavoritesView(
            liveFuture: _liveFuture,
            todayFuture: _todayFuture,
            yesterdayFuture: _yesterdayFuture,
            teamsFuture: _teamsFuture,
            favoriteTeamIds: favIds,
            onRefresh: () => _refreshTab(7),
            onMatchTap: (m) => _openMatchDetail(context, m),
          ),
          QuizScreen(xpService: widget.xpService),
          ProfileScreen(xpService: widget.xpService),
        ],
      ),
    );
  }
}

// ─── Matches Tab ──────────────────────────────────────────────────────────────

class _MatchesView extends StatelessWidget {
  const _MatchesView({
    required this.title,
    required this.subtitle,
    required this.future,
    required this.emptyMessage,
    required this.onRefresh,
    this.onMatchTap,
    this.searchQuery = '',
    this.reactionsService,
  });

  final String title;
  final String subtitle;
  final Future<List<FootballMatch>> future;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final void Function(FootballMatch)? onMatchTap;
  final String searchQuery;
  final ReactionsService? reactionsService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FootballMatch>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading matches...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }
        final all = snapshot.data ?? <FootballMatch>[];
        final matches = searchQuery.isEmpty
            ? all
            : all
                  .where(
                    (m) =>
                        (m.teams.home.name ?? '').toLowerCase().contains(
                          searchQuery,
                        ) ||
                        (m.teams.away.name ?? '').toLowerCase().contains(
                          searchQuery,
                        ) ||
                        (m.league.name ?? '').toLowerCase().contains(
                          searchQuery,
                        ),
                  )
                  .toList();

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: matches.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    SectionHeader(title: title, subtitle: subtitle),
                    const SizedBox(height: 24),
                    EmptyState(
                      icon: Icons.sports_soccer_outlined,
                      title: searchQuery.isNotEmpty
                          ? 'No matches found'
                          : 'Nothing here yet',
                      message: searchQuery.isNotEmpty
                          ? 'No matches for "$searchQuery"'
                          : emptyMessage,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SectionHeader(
                        title: title,
                        subtitle: subtitle,
                        trailing: Text(
                          '${matches.length} match${matches.length == 1 ? '' : 'es'}',
                        ),
                      );
                    }
                    final match = matches[index - 1];
                    return MatchCard(
                      match: match,
                      onTap: onMatchTap != null ? () => onMatchTap!(match) : null,
                      reactionsService: reactionsService,
                    );
                  },
                ),
        );
      },
    );
  }
}

// ─── Favorites Tab ────────────────────────────────────────────────────────────

class _FavoritesView extends StatefulWidget {
  const _FavoritesView({
    required this.liveFuture,
    required this.todayFuture,
    required this.yesterdayFuture,
    required this.teamsFuture,
    required this.favoriteTeamIds,
    required this.onRefresh,
    this.onMatchTap,
  });

  final Future<List<FootballMatch>> liveFuture;
  final Future<List<FootballMatch>> todayFuture;
  final Future<List<FootballMatch>> yesterdayFuture;
  final Future<List<TeamItem>> teamsFuture;
  final Set<int> favoriteTeamIds;
  final Future<void> Function() onRefresh;
  final void Function(FootballMatch)? onMatchTap;

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  late Future<({List<FootballMatch> matches, List<TeamItem> teams})>
  _favoriteData;

  @override
  void initState() {
    super.initState();
    _buildFavoriteData();
  }

  @override
  void didUpdateWidget(_FavoritesView old) {
    super.didUpdateWidget(old);
    if (old.liveFuture != widget.liveFuture ||
        old.todayFuture != widget.todayFuture ||
        old.yesterdayFuture != widget.yesterdayFuture ||
        old.teamsFuture != widget.teamsFuture ||
        old.favoriteTeamIds != widget.favoriteTeamIds) {
      _buildFavoriteData();
    }
  }

  void _buildFavoriteData() {
    _favoriteData =
        Future.wait([
          widget.liveFuture,
          widget.todayFuture,
          widget.yesterdayFuture,
          widget.teamsFuture,
        ]).then((lists) {
          final allMatches = <FootballMatch>[];
          allMatches.addAll(lists[0] as List<FootballMatch>);
          allMatches.addAll(lists[1] as List<FootballMatch>);
          allMatches.addAll(lists[2] as List<FootballMatch>);
          final favoriteTeams = (lists[3] as List<TeamItem>)
              .where((team) => widget.favoriteTeamIds.contains(team.team?.id))
              .toList();
          return (matches: allMatches, teams: favoriteTeams);
        });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.favoriteTeamIds.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(title: 'Favorites', subtitle: 'Your saved teams'),
          SizedBox(height: 24),
          EmptyState(
            icon: Icons.star_border_outlined,
            title: 'No favorites yet',
            message:
                'Go to the Teams tab and tap ★ to follow your favorite teams.',
          ),
        ],
      );
    }

    return FutureBuilder<({List<FootballMatch> matches, List<TeamItem> teams})>(
      future: _favoriteData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading favorites...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: widget.onRefresh,
          );
        }
        final combined = snapshot.data;
        final all = combined?.matches ?? [];
        final favoriteTeams = combined?.teams ?? [];
        final matches = all
            .where(
              (m) =>
                  widget.favoriteTeamIds.contains(m.teams.home.id) ||
                  widget.favoriteTeamIds.contains(m.teams.away.id),
            )
            .toList();

        final children = <Widget>[];

        if (favoriteTeams.isNotEmpty) {
          children.addAll([
            SectionHeader(
              title: 'Favorite Teams',
              subtitle: 'Your saved teams',
              trailing: Text(
                '${favoriteTeams.length} team${favoriteTeams.length == 1 ? '' : 's'}',
              ),
            ),
            const SizedBox(height: 12),
            ...favoriteTeams.map((team) {
              final info = team.team;
              final venue = team.venue;
              final subtitleParts = <String>[
                if ((team.country ?? info?.country ?? '').isNotEmpty)
                  team.country ?? info?.country ?? '',
                if ((team.founded ?? info?.founded) != null)
                  'Founded ${team.founded ?? info?.founded}',
                if ((venue?.name ?? '').isNotEmpty) venue!.name!,
              ];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (info?.logo ?? '').isNotEmpty
                        ? NetworkImage(info!.logo!)
                        : null,
                    child: (info?.logo ?? '').isEmpty
                        ? Text(_initials(info?.name))
                        : null,
                  ),
                  title: Text(info?.name ?? 'Unknown team'),
                  subtitle: Text(
                    subtitleParts.isEmpty
                        ? 'Team details unavailable'
                        : subtitleParts.join(' • '),
                  ),
                ),
              );
            }),
            const SizedBox(height: 22),
          ]);
        }

        if (matches.isEmpty) {
          children.addAll(const [
            SectionHeader(
              title: 'Favorites',
              subtitle: 'Matches for your teams',
            ),
            SizedBox(height: 24),
            EmptyState(
              icon: Icons.sports_soccer_outlined,
              title: 'No matches right now',
              message:
                  'None of your favorite teams have live or recent matches.',
            ),
          ]);
        } else {
          children.addAll([
            SectionHeader(
              title: 'Favorites',
              subtitle: 'Matches for your teams',
              trailing: Text(
                '${matches.length} match${matches.length == 1 ? '' : 'es'}',
              ),
            ),
            const SizedBox(height: 12),
            ...matches.map(
              (match) => MatchCard(
                match: match,
                onTap: widget.onMatchTap != null
                    ? () => widget.onMatchTap!(match)
                    : null,
              ),
            ),
          ]);
        }

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: children,
          ),
        );
      },
    );
  }
}

// ─── Standings Tab ────────────────────────────────────────────────────────────

class _StandingsView extends StatelessWidget {
  const _StandingsView({required this.future, required this.onRefresh});
  final Future<List<StandingGroup>> future;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StandingGroup>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading standings...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }
        final groups = snapshot.data ?? <StandingGroup>[];
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: groups.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SectionHeader(
                      title: 'Standings',
                      subtitle: 'League tables and rankings',
                    ),
                    SizedBox(height: 24),
                    EmptyState(
                      icon: Icons.leaderboard_outlined,
                      title: 'No standings',
                      message: 'Standings data is currently unavailable.',
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: groups.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const SectionHeader(
                        title: 'Standings',
                        subtitle: 'League tables and team positions',
                      );
                    }
                    return _StandingGroupCard(group: groups[index - 1]);
                  },
                ),
        );
      },
    );
  }
}

class _StandingGroupCard extends StatelessWidget {
  const _StandingGroupCard({required this.group});
  final StandingGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final league = group.league;
    final rows = group.standings;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: const Color(0xFF2A2A2A)),
              ),
            ),
            child: Row(
              children: [
                if ((league?.logo ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.network(
                      league!.logo!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox(width: 28),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league?.name ?? 'Standings',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((league?.country ?? '').isNotEmpty)
                        Text(
                          '${league!.country!}${league.season != null ? ' · ${league.season}' : ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if ((league?.flag ?? '').isNotEmpty)
                  Image.network(
                    league!.flag!,
                    width: 22,
                    height: 14,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: 8),
                const Expanded(child: SizedBox()),
                ...[' P', ' W', ' D', ' L', 'GD', 'Pts'].map(
                  (h) => SizedBox(
                    width: h == 'Pts' ? 36 : 28,
                    child: Text(
                      h.trim(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const SizedBox(width: 60, child: Text('')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return _StandingRow(row: row, isLast: i == rows.length - 1);
          }),
          const SizedBox(height: 4),
          _StandingLegend(rows: rows),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.row, required this.isLast});
  final StandingRow row;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desc = (row.description ?? '').toLowerCase();
    final rankColor = _rankColor(desc);
    final logo = row.team?.logo ?? '';
    final name = row.team?.name ?? 'Unknown';
    final gd = row.goalsDiff ?? 0;
    final gdStr = gd > 0 ? '+$gd' : '$gd';
    final form = row.form ?? '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rankColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${row.rank ?? '-'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: rankColor != Colors.transparent
                            ? rankColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              logo.isNotEmpty
                  ? Image.network(
                      logo,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _fallbackLogo(name, 20),
                    )
                  : _fallbackLogo(name, 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...[
                '${row.all?.played ?? '-'}',
                '${row.all?.win ?? '-'}',
                '${row.all?.draw ?? '-'}',
                '${row.all?.lose ?? '-'}',
                gdStr,
              ].map(
                (v) => SizedBox(
                  width: 28,
                  child: Text(
                    v,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${row.points ?? '-'}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 60,
                child: form.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: form
                            .split('')
                            .take(5)
                            .map((c) => _FormDot(result: c))
                            .toList(),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: Color(0xFF222222),
          ),
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

  Widget _fallbackLogo(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _FormDot extends StatelessWidget {
  const _FormDot({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.toUpperCase()) {
      'W' => Colors.green.shade500,
      'D' => Colors.amber.shade600,
      'L' => Colors.red.shade500,
      _ => Colors.grey.shade700,
    };
    final label = result.toUpperCase();
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label == 'W' || label == 'D' || label == 'L' ? label : '?',
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StandingLegend extends StatelessWidget {
  const _StandingLegend({required this.rows});
  final List<StandingRow> rows;

  @override
  Widget build(BuildContext context) {
    final descriptions = rows
        .map((r) => r.description ?? '')
        .where((d) => d.isNotEmpty)
        .toSet();

    if (descriptions.isEmpty) return const SizedBox.shrink();

    final legend = <(Color, String)>[];
    final lower = descriptions.map((d) => d.toLowerCase()).toSet();

    if (lower.any(
      (d) =>
          d.contains('promotion') &&
          !d.contains('playoff') &&
          !d.contains('play-off'),
    )) {
      legend.add((Colors.green.shade400, 'Promotion'));
    }
    if (lower.any((d) => d.contains('playoff') || d.contains('play-off'))) {
      legend.add((Colors.orange.shade400, 'Playoffs'));
    }
    if (lower.any((d) => d.contains('relegation'))) {
      legend.add((Colors.red.shade400, 'Relegation'));
    }

    if (legend.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Wrap(
        spacing: 16,
        children: legend.map((item) {
          final (color, label) = item;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Teams Tab ────────────────────────────────────────────────────────────────

class _TeamsView extends StatelessWidget {
  const _TeamsView({
    required this.future,
    required this.onRefresh,
    required this.favoritesService,
    this.searchQuery = '',
    this.onTeamTap,
  });
  final Future<List<TeamItem>> future;
  final Future<void> Function() onRefresh;
  final FavoritesService favoritesService;
  final String searchQuery;
  final void Function(TeamItem)? onTeamTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeamItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading teams...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }
        final all = snapshot.data ?? <TeamItem>[];
        final teams = searchQuery.isEmpty
            ? all
            : all
                  .where(
                    (t) => (t.team?.name ?? '').toLowerCase().contains(
                      searchQuery,
                    ),
                  )
                  .toList();

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: teams.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Teams',
                      subtitle: 'Clubs and national teams',
                    ),
                    const SizedBox(height: 24),
                    EmptyState(
                      icon: Icons.groups_2_outlined,
                      title: searchQuery.isNotEmpty
                          ? 'No teams found'
                          : 'No teams',
                      message: searchQuery.isNotEmpty
                          ? 'No teams matching "$searchQuery"'
                          : 'No team data is available right now.',
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: teams.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SectionHeader(
                        title: 'Teams',
                        subtitle: 'Browse participating teams',
                        trailing: Text('${teams.length} total'),
                      );
                    }
                    final team = teams[index - 1];
                    final info = team.team;
                    final venue = team.venue;
                    final subtitleParts = <String>[
                      if ((team.country ?? info?.country ?? '').isNotEmpty)
                        team.country ?? info?.country ?? '',
                      if ((team.founded ?? info?.founded) != null)
                        'Founded ${team.founded ?? info?.founded}',
                      if ((venue?.name ?? '').isNotEmpty) venue!.name!,
                    ];
                    final teamId = info?.id;
                    final isFav =
                        teamId != null && favoritesService.isFavorite(teamId);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (info?.logo ?? '').isNotEmpty
                              ? NetworkImage(info!.logo!)
                              : null,
                          child: (info?.logo ?? '').isEmpty
                              ? Text(_initials(info?.name))
                              : null,
                        ),
                        title: Text(info?.name ?? 'Unknown team'),
                        subtitle: Text(
                          subtitleParts.isEmpty
                              ? 'Team details unavailable'
                              : subtitleParts.join(' • '),
                        ),
                        onTap: onTeamTap != null ? () => onTeamTap!(team) : null,
                        trailing: teamId != null
                            ? IconButton(
                                icon: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                  color: isFav ? Colors.amber : Colors.white38,
                                ),
                                onPressed: () =>
                                    favoritesService.toggle(teamId),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ─── Leagues Tab ──────────────────────────────────────────────────────────────

class _LeaguesView extends StatelessWidget {
  const _LeaguesView({
    required this.future,
    required this.onRefresh,
    this.searchQuery = '',
    this.onLeagueTap,
  });
  final Future<List<LeagueItem>> future;
  final Future<void> Function() onRefresh;
  final String searchQuery;
  final void Function(LeagueItem)? onLeagueTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeagueItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading leagues...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }
        final all = snapshot.data ?? <LeagueItem>[];
        final leagues = searchQuery.isEmpty
            ? all
            : all
                  .where(
                    (l) =>
                        (l.league?.name ?? '').toLowerCase().contains(
                          searchQuery,
                        ) ||
                        (l.country?.name ?? '').toLowerCase().contains(
                          searchQuery,
                        ),
                  )
                  .toList();

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: leagues.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Leagues',
                      subtitle: 'Competitions and tournaments',
                    ),
                    const SizedBox(height: 24),
                    EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: searchQuery.isNotEmpty
                          ? 'No leagues found'
                          : 'No leagues',
                      message: searchQuery.isNotEmpty
                          ? 'No leagues matching "$searchQuery"'
                          : 'League data is currently unavailable.',
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: leagues.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SectionHeader(
                        title: 'Leagues',
                        subtitle: 'Available football competitions',
                        trailing: Text('${leagues.length} total'),
                      );
                    }
                    final league = leagues[index - 1];
                    final info = league.league;
                    final currentSeason = league.seasons
                        .where((s) => s.current == true)
                        .cast<LeagueSeason?>()
                        .firstOrNull;
                    final subtitleParts = <String>[
                      if ((league.country?.name ?? '').isNotEmpty)
                        league.country!.name!,
                      if ((info?.type ?? '').isNotEmpty) info!.type!,
                      if (currentSeason?.year != null)
                        'Season ${currentSeason!.year}',
                    ];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (info?.logo ?? '').isNotEmpty
                              ? NetworkImage(info!.logo!)
                              : null,
                          child: (info?.logo ?? '').isEmpty
                              ? Text(_initials(info?.name))
                              : null,
                        ),
                        title: Text(info?.name ?? 'Unknown league'),
                        subtitle: Text(
                          subtitleParts.isEmpty
                              ? 'Competition details unavailable'
                              : subtitleParts.join(' • '),
                        ),
                        onTap: onLeagueTap != null ? () => onLeagueTap!(league) : null,
                        trailing: currentSeason?.current == true
                            ? const Icon(Icons.check_circle_outline)
                            : null,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _initials(String? value) {
  final words = (value ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return '${words.first[0]}${words[1][0]}'.toUpperCase();
}
