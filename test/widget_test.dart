import 'package:flutter_test/flutter_test.dart';
import 'package:football_live/main.dart';
import 'package:football_live/services/favorites_service.dart';
import 'package:football_live/services/prediction_service.dart';
import 'package:football_live/services/reactions_service.dart';
import 'package:football_live/services/xp_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      FootbalLiveApp(
        favoritesService: FavoritesService(),
        xpService: XpService(),
        reactionsService: ReactionsService(),
        predictionService: PredictionService(),
      ),
    );
    expect(find.text('FootbalLive'), findsOneWidget);
  });
}
