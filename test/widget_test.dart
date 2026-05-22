import 'package:flutter_test/flutter_test.dart';
import 'package:football_live/main.dart';
import 'package:football_live/services/commentary_service.dart';
import 'package:football_live/services/community_service.dart';
import 'package:football_live/services/football_api_service.dart';
import 'package:football_live/services/favorites_service.dart';
import 'package:football_live/services/goal_alerts_service.dart';
import 'package:football_live/services/news_service.dart';
import 'package:football_live/services/prediction_service.dart';
import 'package:football_live/services/reactions_service.dart';
import 'package:football_live/services/xp_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final apiService = FootballApiService();
    final favs = FavoritesService();
    final xp = XpService();
    final predictions = PredictionService();
    await tester.pumpWidget(
      FootbalLiveApp(
        apiService: apiService,
        favoritesService: favs,
        xpService: xp,
        reactionsService: ReactionsService(),
        predictionService: predictions,
        goalAlertsService: GoalAlertsService(
          favoritesService: favs,
          apiService: apiService,
        ),
        communityService: CommunityService(xpService: xp, predictionService: predictions),
        newsService: NewsService(),
        commentaryService: CommentaryService(apiService: apiService),
      ),
    );

    expect(find.text('KickOra'), findsOneWidget);
  });
}
