import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _prefix = 'api_cache_';
  static const _tsSuffix = '_ts';

  Future<void> save(String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', json);
    await prefs.setInt('$_prefix$key$_tsSuffix', DateTime.now().millisecondsSinceEpoch);
  }

  Future<({String json, DateTime savedAt})?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_prefix$key');
    final ts = prefs.getInt('$_prefix$key$_tsSuffix');
    if (json == null || ts == null) return null;
    return (json: json, savedAt: DateTime.fromMillisecondsSinceEpoch(ts));
  }
}
