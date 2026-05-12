import 'package:flutter_test/flutter_test.dart';
import 'package:football_live/main.dart';
import 'package:football_live/services/favorites_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FootbalLiveApp(favoritesService: FavoritesService()));
    expect(find.text('FootbalLive'), findsOneWidget);
  });
}
