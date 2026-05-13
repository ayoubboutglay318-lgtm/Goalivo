import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prediction {
  const Prediction({
    required this.fixtureId,
    required this.homeGoals,
    required this.awayGoals,
    this.checkedResult = false,
    this.wasCorrectScore = false,
    this.wasCorrectResult = false,
  });

  final int fixtureId;
  final int homeGoals;
  final int awayGoals;
  final bool checkedResult;
  final bool wasCorrectScore;
  final bool wasCorrectResult;

  String get display => '$homeGoals - $awayGoals';

  String _encode() =>
      '$homeGoals:$awayGoals:${checkedResult ? 1 : 0}:${wasCorrectScore ? 1 : 0}:${wasCorrectResult ? 1 : 0}';

  static Prediction? _decode(int fixtureId, String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (h == null || a == null) return null;
    return Prediction(
      fixtureId: fixtureId,
      homeGoals: h,
      awayGoals: a,
      checkedResult: parts.length > 2 && parts[2] == '1',
      wasCorrectScore: parts.length > 3 && parts[3] == '1',
      wasCorrectResult: parts.length > 4 && parts[4] == '1',
    );
  }
}

class PredictionService extends ChangeNotifier {
  final Map<int, Prediction> _predictions = {};
  bool _loaded = false;

  Prediction? predictionFor(int fixtureId) => _predictions[fixtureId];

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('pred_')) {
        final id = int.tryParse(key.substring('pred_'.length));
        final val = prefs.getString(key);
        if (id != null && val != null) {
          final p = Prediction._decode(id, val);
          if (p != null) { _predictions[id] = p; }
        }
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> savePrediction(int fixtureId, int home, int away) async {
    final p = Prediction(fixtureId: fixtureId, homeGoals: home, awayGoals: away);
    _predictions[fixtureId] = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pred_$fixtureId', p._encode());
    notifyListeners();
  }

  // Call after match finishes — returns XP earned (0 if already checked)
  Future<int> checkResult({
    required int fixtureId,
    required int actualHome,
    required int actualAway,
  }) async {
    final p = _predictions[fixtureId];
    if (p == null || p.checkedResult) return 0;

    final correctScore =
        p.homeGoals == actualHome && p.awayGoals == actualAway;
    final predictedResult = p.homeGoals.compareTo(p.awayGoals);
    final actualResult = actualHome.compareTo(actualAway);
    final correctResult = predictedResult == actualResult;

    final updated = Prediction(
      fixtureId: fixtureId,
      homeGoals: p.homeGoals,
      awayGoals: p.awayGoals,
      checkedResult: true,
      wasCorrectScore: correctScore,
      wasCorrectResult: correctResult,
    );
    _predictions[fixtureId] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pred_$fixtureId', updated._encode());
    notifyListeners();

    if (correctScore) return 50;
    if (correctResult) return 20;
    return 0;
  }
}
