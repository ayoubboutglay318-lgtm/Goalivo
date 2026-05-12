import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const _key = 'fav_team_ids';
  Set<int> _ids = {};

  Set<int> get ids => Set.unmodifiable(_ids);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids = (prefs.getStringList(_key) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> toggle(int id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.map((e) => '$e').toList());
  }
}
