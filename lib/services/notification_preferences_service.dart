import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotifType {
  goal,
  redCard,
  finalResult,
  halftime,
  kickoff,
  lineups,
  matchReminder,
}

class NotificationPreferencesService extends ChangeNotifier {
  static const _prefix = 'notif_pref_';
  static const _masterKey = 'notif_master_enabled';

  bool _masterEnabled = true;
  final Map<NotifType, bool> _prefs = {
    NotifType.goal:          true,
    NotifType.redCard:       true,
    NotifType.finalResult:   true,
    NotifType.halftime:      false,
    NotifType.kickoff:       false,
    NotifType.lineups:       false,
    NotifType.matchReminder: false,
  };

  bool get masterEnabled => _masterEnabled;
  bool isEnabled(NotifType type) => _masterEnabled && (_prefs[type] ?? false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _masterEnabled = prefs.getBool(_masterKey) ?? true;
    for (final t in NotifType.values) {
      final saved = prefs.getBool('$_prefix${t.name}');
      if (saved != null) _prefs[t] = saved;
    }
    notifyListeners();
  }

  Future<void> toggleMaster() async {
    _masterEnabled = !_masterEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_masterKey, _masterEnabled);
    notifyListeners();
  }

  Future<void> toggle(NotifType type) async {
    _prefs[type] = !(_prefs[type] ?? false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${type.name}', _prefs[type]!);
    notifyListeners();
  }

  bool rawEnabled(NotifType type) => _prefs[type] ?? false;
}
