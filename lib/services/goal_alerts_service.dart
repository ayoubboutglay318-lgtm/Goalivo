import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'football_api_service.dart';
import 'favorites_service.dart';
import 'notification_service.dart';
import '../models/match_models.dart';

class GoalAlertsService extends ChangeNotifier {
  static const _prefKey = 'goal_alerts_enabled';

  GoalAlertsService({
    required this.favoritesService,
    required this.apiService,
  }) {
    favoritesService.addListener(_onFavoritesChanged);
  }

  final FavoritesService favoritesService;
  final FootballApiService apiService;

  bool _enabled = false;
  Timer? _pollTimer;
  final Map<int, _ScoreSnapshot> _matchScores = {};

  bool get enabled => _enabled;
  bool get active => _pollTimer?.isActive == true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? false;
    if (_enabled) {
      _startWatching();
    }
    notifyListeners();
  }

  Future<void> toggleEnabled() async {
    _enabled = !_enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _enabled);
    if (_enabled) {
      _startWatching();
    } else {
      _stopWatching();
    }
    notifyListeners();
  }

  void _onFavoritesChanged() {
    if (_enabled && !active) {
      _startWatching();
    }
  }

  void _startWatching() {
    _pollTimer?.cancel();
    _pollLiveMatches();
    _pollTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _pollLiveMatches();
    });
  }

  void _stopWatching() {
    _pollTimer?.cancel();
    _matchScores.clear();
  }

  Future<void> _pollLiveMatches() async {
    if (!_enabled) return;

    try {
      final liveMatches = await apiService.getLiveMatches();
      for (final match in liveMatches) {
        if (!_isFavoriteMatch(match)) continue;
        final fixtureId = match.fixture.id;
        if (fixtureId == null) continue;

        final homeGoals = match.goals.home ?? 0;
        final awayGoals = match.goals.away ?? 0;
        final snapshot = _matchScores[fixtureId];

        if (snapshot != null) {
          if (homeGoals > snapshot.home) {
            _sendGoalNotification(match);
          }
          if (awayGoals > snapshot.away) {
            _sendGoalNotification(match);
          }
        }

        _matchScores[fixtureId] = _ScoreSnapshot(
          home: homeGoals,
          away: awayGoals,
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('GoalAlertsService polling failed: $error');
      }
    }
  }

  bool _isFavoriteMatch(FootballMatch match) {
    final homeId = match.teams.home.id;
    final awayId = match.teams.away.id;
    return (homeId != null && favoritesService.isFavorite(homeId)) ||
        (awayId != null && favoritesService.isFavorite(awayId));
  }

  Future<void> _sendGoalNotification(FootballMatch match) async {
    final home = match.teams.home.name ?? 'Home';
    final away = match.teams.away.name ?? 'Away';
    await NotificationService.instance.showGoalAlert(
      homeTeam: home,
      awayTeam: away,
      homeGoals: match.goals.home ?? 0,
      awayGoals: match.goals.away ?? 0,
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}

class _ScoreSnapshot {
  _ScoreSnapshot({required this.home, required this.away});

  final int home;
  final int away;
}
