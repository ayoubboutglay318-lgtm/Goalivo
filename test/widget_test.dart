import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kickkora/main.dart';
import 'package:kickkora/models/league_models.dart';
import 'package:kickkora/models/match_models.dart';
import 'package:kickkora/models/standing_models.dart';
import 'package:kickkora/models/team_models.dart';
import 'package:kickkora/services/commentary_service.dart';
import 'package:kickkora/services/football_api_service.dart';
import 'package:kickkora/services/favorites_service.dart';
import 'package:kickkora/services/goal_alerts_service.dart';
import 'package:kickkora/services/news_service.dart';
import 'package:kickkora/services/notification_preferences_service.dart';
import 'package:kickkora/services/reactions_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});

    final apiService = _EmptyFootballApiService();
    final favs = FavoritesService();
    await tester.pumpWidget(
      FootbalLiveApp(
        apiService: apiService,
        favoritesService: favs,
        reactionsService: ReactionsService(),
        goalAlertsService: GoalAlertsService(
          favoritesService: favs,
          apiService: apiService,
        ),
        notifPrefs: NotificationPreferencesService(),
        newsService: NewsService(),
        commentaryService: CommentaryService(apiService: apiService),
      ),
    );
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _EmptyFootballApiService extends FootballApiService {
  @override
  Future<List<FootballMatch>> getLiveMatches() async => [];

  @override
  Future<List<FootballMatch>> getTodayMatches() async => [];

  @override
  Future<List<FootballMatch>> getYesterdayMatches() async => [];

  @override
  Future<List<FootballMatch>> getTomorrowMatches() async => [];

  @override
  Future<List<StandingGroup>> getStandings() async => [];

  @override
  Future<List<TeamItem>> getTeams() async => [];

  @override
  Future<List<LeagueItem>> getLeagues() async => [];
}
