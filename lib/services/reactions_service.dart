import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kReactionEmojis = ['🔥', '😮', '😂', '💪', '🎉'];

class ReactionsService extends ChangeNotifier {
  // fixtureId → chosen emoji (null = no reaction yet)
  final Map<int, String> _reactions = {};
  bool _loaded = false;

  String? reactionFor(int fixtureId) => _reactions[fixtureId];

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('reaction_')) {
        final id = int.tryParse(key.substring('reaction_'.length));
        final val = prefs.getString(key);
        if (id != null && val != null) { _reactions[id] = val; }
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> react(int fixtureId, String emoji) async {
    if (_reactions[fixtureId] == emoji) {
      _reactions.remove(fixtureId); // toggle off
    } else {
      _reactions[fixtureId] = emoji;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_reactions.containsKey(fixtureId)) {
      await prefs.setString('reaction_$fixtureId', _reactions[fixtureId]!);
    } else {
      await prefs.remove('reaction_$fixtureId');
    }
    notifyListeners();
  }
}
