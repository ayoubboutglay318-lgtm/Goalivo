import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/league_models.dart';
import '../models/match_models.dart';
import '../models/standing_models.dart';
import '../models/team_models.dart';
import '../services/favorites_service.dart';
import '../services/commentary_service.dart';
import '../services/notification_preferences_service.dart';
import '../services/football_api_service.dart';
import '../services/goal_alerts_service.dart';
import '../services/news_service.dart';
import '../services/reactions_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/match_card.dart';
import '../widgets/section_header.dart';
import 'league_detail_screen.dart';
import 'match_detail_screen.dart';
import 'profile_screen.dart';
import 'team_detail_screen.dart';

// ignore_for_file: unused_field

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.favoritesService,
    required this.reactionsService,
    required this.goalAlertsService,
    required this.notifPrefs,
    required this.newsService,
    required this.commentaryService,
    this.themeMode = ThemeMode.dark,
    this.onToggleTheme,
  });
  final FootballApiService apiService;
  final FavoritesService favoritesService;
  final ReactionsService reactionsService;
  final GoalAlertsService goalAlertsService;
  final NotificationPreferencesService notifPrefs;
  final NewsService newsService;
  final CommentaryService commentaryService;
  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // Bottom nav
  int _bottomIndex = 0;

  // Top tab controllers per section
  late TabController _homeTabCtrl;    // Live, Today
  late TabController _matchesTabCtrl; // Yesterday, Tomorrow, Standings
  late TabController _exploreTabCtrl; // Favorites, Teams, Leagues, Commentary

  final TextEditingController _searchController = TextEditingController();
  Timer? _liveRefreshTimer;
  bool _isSearching = false;
  String _searchQuery = '';

  late Future<List<FootballMatch>> _liveFuture;
  // _dayFutures: keyed by day offset from today (-3 to +3)
  final Map<int, Future<List<FootballMatch>>> _dayFutures = {};
  late Future<List<StandingGroup>> _standingsFuture;
  late Future<List<TeamItem>> _teamsFuture;
  late Future<List<LeagueItem>> _leaguesFuture;
  late Future<List<MatchCommentary>> _commentaryFuture;

  @override
  void initState() {
    super.initState();
    _homeTabCtrl = TabController(length: 2, vsync: this);
    _matchesTabCtrl = TabController(length: 4, vsync: this, initialIndex: 1);
    _exploreTabCtrl = TabController(length: 4, vsync: this);
    _homeTabCtrl.addListener(_onHomeTabChanged);
    _matchesTabCtrl.addListener(_onMatchesTabChanged);
    _primeFutures();
    _startLiveTimer();
    widget.favoritesService.addListener(_onFavoritesChanged);
    widget.apiService.addListener(_onApiStateChanged);
    widget.goalAlertsService.addListener(_onGoalAlertsChanged);
  }

  void _onApiStateChanged() { if (mounted) setState(() {}); }
  void _onGoalAlertsChanged() { if (mounted) setState(() {}); }
  void _onFavoritesChanged() => setState(() {});

  void _onHomeTabChanged() {
    if (!_homeTabCtrl.indexIsChanging) return;
    HapticFeedback.selectionClick();
    if (_homeTabCtrl.index == 0) {
      _startLiveTimer();
    } else {
      _liveRefreshTimer?.cancel();
    }
    if (_isSearching) _closeSearch();
  }

  void _onMatchesTabChanged() {
    if (!_matchesTabCtrl.indexIsChanging) return;
    HapticFeedback.selectionClick();
    final idx = _matchesTabCtrl.index;
    if (idx < 7) {
      final offset = idx - 3;
      if (!_dayFutures.containsKey(offset)) {
        setState(() => _loadDay(offset));
      }
    }
  }

  Future<List<FootballMatch>> _loadDay(int offset) {
    final date = DateTime.now().add(Duration(days: offset));
    final f = widget.apiService.getMatchesByDate(date);
    _dayFutures[offset] = f;
    return f;
  }

  String _dayTabLabel(int offset) {
    if (offset == 0) return 'Today';
    final d = DateTime.now().add(Duration(days: offset));
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${names[d.weekday - 1]} ${d.day}';
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    _searchController.dispose();
    _homeTabCtrl.removeListener(_onHomeTabChanged);
    _matchesTabCtrl.removeListener(_onMatchesTabChanged);
    _homeTabCtrl.dispose();
    _matchesTabCtrl.dispose();
    _exploreTabCtrl.dispose();
    widget.apiService.removeListener(_onApiStateChanged);
    widget.goalAlertsService.removeListener(_onGoalAlertsChanged);
    widget.favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _startLiveTimer() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && _bottomIndex == 0 && _homeTabCtrl.index == 0) {
        setState(() { _liveFuture = widget.apiService.getLiveMatches(); });
      }
    });
  }

  void _primeFutures() {
    _liveFuture = widget.apiService.getLiveMatches();
    _dayFutures[-1] = widget.apiService.getYesterdayMatches();
    _dayFutures[0]  = widget.apiService.getTodayMatches();
    _dayFutures[1]  = widget.apiService.getTomorrowMatches();
    _standingsFuture = widget.apiService.getStandings();
    _teamsFuture = widget.apiService.getTeams();
    _leaguesFuture = widget.apiService.getLeagues();
    _commentaryFuture = widget.commentaryService.getLiveCommentary();
  }

  Future<void> _refreshCurrent() async {
    switch (_bottomIndex) {
      case 0:
        setState(() {
          if (_homeTabCtrl.index == 0) {
            _liveFuture = widget.apiService.getLiveMatches();
          } else {
            _dayFutures[0] = widget.apiService.getTodayMatches();
          }
        });
      case 1:
        setState(() {
          switch (_matchesTabCtrl.index) {
            case 0: _loadDay(-1);
            case 1: _loadDay(0);
            case 2: _loadDay(1);
            case 3: _standingsFuture = widget.apiService.getStandings();
          }
        });
      case 2:
        switch (_exploreTabCtrl.index) {
          case 0:
            setState(() {
              _liveFuture = widget.apiService.getLiveMatches();
              _dayFutures[0]  = widget.apiService.getTodayMatches();
              _dayFutures[-1] = widget.apiService.getYesterdayMatches();
              _teamsFuture = widget.apiService.getTeams();
            });
          case 1: setState(() { _teamsFuture = widget.apiService.getTeams(); });
          case 2: setState(() { _leaguesFuture = widget.apiService.getLeagues(); });
          case 3: setState(() { _commentaryFuture = widget.commentaryService.getLiveCommentary(); });
        }
    }
  }

  void _openMatchDetail(BuildContext context, FootballMatch match) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => MatchDetailScreen(
          match: match,
          apiService: widget.apiService,
        ),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _closeSearch() {
    setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); });
  }

  PreferredSizeWidget? _buildTopTabs() {
    switch (_bottomIndex) {
      case 0:
        return TabBar(
          controller: _homeTabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.circle, size: 8, color: Colors.red), text: 'Live'),
            Tab(text: 'Today'),
          ],
        );
      case 1:
        return TabBar(
          controller: _matchesTabCtrl,
          tabs: [
            Tab(text: _dayTabLabel(-1)),
            const Tab(text: 'Today'),
            Tab(text: _dayTabLabel(1)),
            const Tab(text: 'Standings'),
          ],
        );
      case 2:
        final favCount = widget.favoritesService.ids.length;
        return TabBar(
          controller: _exploreTabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_outline, size: 14),
                const SizedBox(width: 4),
                const Text('Favorites'),
                if (favCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                    child: Text('$favCount', style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
            ),
            const Tab(text: 'Teams'),
            const Tab(text: 'Leagues'),
            const Tab(text: 'Commentary'),
          ],
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    final favIds = widget.favoritesService.ids;
    switch (_bottomIndex) {
      case 0:
        return TabBarView(
          controller: _homeTabCtrl,
          children: [
            _MatchesView(
              title: 'Live', subtitle: 'Currently in play',
              future: _liveFuture,
              emptyMessage: 'The pitch is quiet right now.\nPull down to refresh.',
              emptyTitle: 'No live matches', emptyIcon: Icons.sports_soccer,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
              searchQuery: _searchQuery,
            ),
            _MatchesView(
              title: 'Today', subtitle: "Today's fixtures",
              future: _dayFutures[0] ?? _loadDay(0),
              emptyMessage: 'No fixtures today.\nCheck back later or browse Matches.',
              emptyTitle: 'Rest day', emptyIcon: Icons.today_outlined,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
              searchQuery: _searchQuery,
            ),
          ],
        );
      case 1:
        return TabBarView(
          controller: _matchesTabCtrl,
          children: [
            _MatchesView(
              title: _dayTabLabel(-1), subtitle: 'Results and scores',
              future: _dayFutures[-1] ?? _loadDay(-1),
              emptyMessage: 'No results for yesterday.',
              emptyTitle: 'No results', emptyIcon: Icons.history,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
              searchQuery: _searchQuery,
            ),
            _MatchesView(
              title: 'Today', subtitle: "Today's fixtures",
              future: _dayFutures[0] ?? _loadDay(0),
              emptyMessage: 'No fixtures today.\nCheck back later.',
              emptyTitle: 'Rest day', emptyIcon: Icons.today_outlined,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
              searchQuery: _searchQuery,
            ),
            _MatchesView(
              title: _dayTabLabel(1), subtitle: 'Upcoming fixtures',
              future: _dayFutures[1] ?? _loadDay(1),
              emptyMessage: 'No fixtures scheduled.',
              emptyTitle: 'Nothing scheduled', emptyIcon: Icons.event_outlined,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
              searchQuery: _searchQuery,
            ),
            _StandingsView(future: _standingsFuture, onRefresh: _refreshCurrent),
          ],
        );
      case 2:
        return TabBarView(
          controller: _exploreTabCtrl,
          children: [
            _FavoritesView(
              liveFuture: _liveFuture,
              todayFuture: _dayFutures[0] ?? _loadDay(0),
              yesterdayFuture: _dayFutures[-1] ?? _loadDay(-1),
              teamsFuture: _teamsFuture,
              favoriteTeamIds: favIds,
              onRefresh: _refreshCurrent,
              onMatchTap: (m) => _openMatchDetail(context, m),
            ),
            _TeamsView(
              future: _teamsFuture, onRefresh: _refreshCurrent,
              favoritesService: widget.favoritesService, searchQuery: _searchQuery,
              onTeamTap: (team) => Navigator.push(context, MaterialPageRoute(
                builder: (_) => TeamDetailScreen(team: team, apiService: widget.apiService, newsService: widget.newsService),
              )),
            ),
            _LeaguesView(
              future: _leaguesFuture, onRefresh: _refreshCurrent, searchQuery: _searchQuery,
              onLeagueTap: (league) => Navigator.push(context, MaterialPageRoute(
                builder: (_) => LeagueDetailScreen(league: league, apiService: widget.apiService),
              )),
            ),
            _CommentaryFeedView(
              future: _commentaryFuture, onRefresh: _refreshCurrent,
              onMatchTap: (match) => _openMatchDetail(context, match),
            ),
          ],
        );
      case 3:
        return ProfileScreen(goalAlertsService: widget.goalAlertsService, notifPrefs: widget.notifPrefs);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topTabs = _buildTopTabs();
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _closeSearch)
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) => setState(() => _searchQuery = q.toLowerCase().trim()),
                decoration: const InputDecoration(
                  hintText: 'Search teams, leagues...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : SvgPicture.asset('assets/goalivo_logo.svg', height: 36),
        actions: [
          if (_bottomIndex < 3) ...[
            if (_isSearching && _searchQuery.isNotEmpty)
              IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() { _searchQuery = ''; _searchController.clear(); }))
            else if (!_isSearching)
              IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = true)),
          ],
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
        bottom: topTabs,
      ),
      body: Column(
        children: [
          if (widget.apiService.isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(children: [
                Icon(Icons.cloud_off, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text('Offline â€” showing cached data',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          if (widget.goalAlertsService.enabled)
            Container(
              width: double.infinity,
              color: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Row(children: [
                const Icon(Icons.sports_soccer, size: 14, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  widget.favoritesService.ids.isEmpty
                      ? 'Goal alerts are on â€” add favorite teams to receive notifications.'
                      : 'Goal alerts are active for your favorite teams.',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                )),
              ]),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
        selectedIndex: _bottomIndex,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          if (_isSearching) _closeSearch();
          setState(() => _bottomIndex = i);
          if (i == 0 && _homeTabCtrl.index == 0) {
            _startLiveTimer();
          } else {
            _liveRefreshTimer?.cancel();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Matches Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MatchesView extends StatelessWidget {
  const _MatchesView({
    required this.title,
    required this.subtitle,
    required this.future,
    required this.emptyMessage,
    required this.onRefresh,
    this.emptyTitle = 'Nothing here yet',
    this.emptyIcon = Icons.sports_soccer_outlined,
    this.onMatchTap,
    this.searchQuery = '',
  });

  final String title;
  final String subtitle;
  final Future<List<FootballMatch>> future;
  final String emptyMessage;
  final String emptyTitle;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final void Function(FootballMatch)? onMatchTap;
  final String searchQuery;

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
                      icon: searchQuery.isNotEmpty ? Icons.search_off : emptyIcon,
                      title: searchQuery.isNotEmpty
                          ? 'No matches found'
                          : emptyTitle,
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
                        trailing: _MatchCountBadge(count: matches.length),
                      );
                    }
                    final match = matches[index - 1];
                    return MatchCard(
                      match: match,
                      onTap: onMatchTap != null
                          ? () => onMatchTap!(match)
                          : null,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _MatchCountBadge extends StatelessWidget {
  const _MatchCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$count ${count == 1 ? 'match' : 'matches'}',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _CommentaryFeedView extends StatelessWidget {
  const _CommentaryFeedView({
    required this.future,
    required this.onRefresh,
    required this.onMatchTap,
  });

  final Future<List<MatchCommentary>> future;
  final Future<void> Function() onRefresh;
  final void Function(FootballMatch) onMatchTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchCommentary>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Loading live commentary...');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }

        final commentary = snapshot.data ?? [];
        if (commentary.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                SectionHeader(
                  title: 'Live Commentary',
                  subtitle: 'Tracking every moment from the pitch.',
                ),
                SizedBox(height: 24),
                EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No live commentary yet',
                  message:
                      'Check back when more matches start or refresh for updates.',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: commentary.length,
            itemBuilder: (context, index) {
              final item = commentary[index];
              return Card(
                child: InkWell(
                  onTap: () => onMatchTap(item.match),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(item.badge, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

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
                'Go to the Teams tab and tap â˜… to follow your favorite teams.',
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
                        : subtitleParts.join(' â€¢ '),
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

// â”€â”€â”€ Standings Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                          '${league!.country!}${league.season != null ? ' Â· ${league.season}' : ''}',
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

// â”€â”€â”€ Teams Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
        // Famous clubs first, then alphabetical
        const famousRank = [
          'real madrid', 'barcelona', 'manchester city', 'liverpool',
          'paris saint-germain', 'psg', 'bayern', 'chelsea', 'arsenal',
          'manchester united', 'juventus', 'inter', 'ac milan', 'milan',
          'atletico', 'dortmund', 'napoli', 'tottenham', 'ajax',
          'benfica', 'porto', 'sevilla', 'roma', 'lazio',
          'al nassr', 'al hilal', 'marseille', 'monaco',
        ];
        int teamRank(TeamItem t) {
          final name = (t.team?.name ?? '').toLowerCase();
          final idx = famousRank.indexWhere((k) => name.contains(k));
          return idx == -1 ? famousRank.length + 1 : idx;
        }
        final sorted = [...all]..sort((a, b) {
          final r = teamRank(a).compareTo(teamRank(b));
          if (r != 0) return r;
          return (a.team?.name ?? '').compareTo(b.team?.name ?? '');
        });
        final teams = searchQuery.isEmpty
            ? sorted
            : sorted
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
                              : subtitleParts.join(' â€¢ '),
                        ),
                        onTap: onTeamTap != null
                            ? () => onTeamTap!(team)
                            : null,
                        trailing: teamId != null
                            ? IconButton(
                                icon: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                  color: isFav ? Colors.amber : Colors.white38,
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  favoritesService.toggle(teamId);
                                },
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

// â”€â”€â”€ Leagues Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                              : subtitleParts.join(' â€¢ '),
                        ),
                        onTap: onLeagueTap != null
                            ? () => onLeagueTap!(league)
                            : null,
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

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

