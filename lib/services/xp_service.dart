import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Level definitions ─────────────────────────────────────────────────────────

class XpLevel {
  const XpLevel({
    required this.level,
    required this.title,
    required this.emoji,
    required this.minXp,
    required this.maxXp,
  });
  final int level;
  final String title;
  final String emoji;
  final int minXp;
  final int maxXp; // -1 = no cap (top level)

  static const List<XpLevel> all = [
    XpLevel(level: 1, title: 'Football Fan',  emoji: '⚽', minXp: 0,    maxXp: 149),
    XpLevel(level: 2, title: 'Supporter',     emoji: '🎽', minXp: 150,  maxXp: 399),
    XpLevel(level: 3, title: 'Ultra',         emoji: '🔥', minXp: 400,  maxXp: 799),
    XpLevel(level: 4, title: 'Football Head', emoji: '📊', minXp: 800,  maxXp: 1499),
    XpLevel(level: 5, title: 'Legend',        emoji: '🏆', minXp: 1500, maxXp: 2999),
    XpLevel(level: 6, title: 'Football God',  emoji: '👑', minXp: 3000, maxXp: -1),
  ];

  static XpLevel forXp(int xp) {
    for (int i = all.length - 1; i >= 0; i--) {
      if (xp >= all[i].minXp) return all[i];
    }
    return all.first;
  }
}

// ── Achievement definitions ───────────────────────────────────────────────────

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.xpReward,
    this.category = 'Other',
    this.maxProgress = 0,
  });
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int xpReward;
  final String category;
  final int maxProgress; // 0 = no progress bar shown

  static const List<Achievement> all = [
    Achievement(id: 'first_match',   title: 'First Kick',    description: 'Open your first match',      emoji: '🎯', xpReward: 20,  category: 'Engagement', maxProgress: 1),
    Achievement(id: 'match_5',       title: 'Match Day',     description: 'View 5 match details',       emoji: '📺', xpReward: 30,  category: 'Engagement', maxProgress: 5),
    Achievement(id: 'match_25',      title: 'Regular Fan',   description: 'View 25 match details',      emoji: '🎫', xpReward: 75,  category: 'Engagement', maxProgress: 25),
    Achievement(id: 'streak_3',      title: 'On Fire',       description: '3-day login streak',         emoji: '🔥', xpReward: 50,  category: 'Loyalty',    maxProgress: 3),
    Achievement(id: 'streak_7',      title: 'Dedicated',     description: '7-day login streak',         emoji: '⚡', xpReward: 100, category: 'Loyalty',    maxProgress: 7),
    Achievement(id: 'streak_30',     title: 'Die-Hard Fan',  description: '30-day login streak',        emoji: '💎', xpReward: 300, category: 'Loyalty',    maxProgress: 30),
    Achievement(id: 'level_3',       title: 'Ultra Fan',     description: 'Reach level 3: Ultra',       emoji: '🚀', xpReward: 0,   category: 'Progression', maxProgress: 3),
    Achievement(id: 'level_5',       title: 'Legend Status', description: 'Reach level 5: Legend',      emoji: '🏆', xpReward: 0,   category: 'Progression', maxProgress: 5),
    Achievement(id: 'favorite_team', title: 'Team Loyalist', description: 'Add a favourite team',       emoji: '⭐', xpReward: 15,  category: 'Explorer',   maxProgress: 1),
    Achievement(id: 'ai_first',      title: 'Explorer',      description: 'Discover all app sections',  emoji: '🗺️', xpReward: 25,  category: 'Explorer',   maxProgress: 0),
    Achievement(id: 'ai_10',         title: 'Data Nerd',     description: 'Track 10 different matches', emoji: '🧠', xpReward: 60,  category: 'Explorer',   maxProgress: 0),
  ];

  static Achievement? byId(String id) {
    try { return all.firstWhere((a) => a.id == id); } catch (_) { return null; }
  }
}

// ── XP event types ────────────────────────────────────────────────────────────

enum XpEvent {
  dailyLogin(20),
  viewMatchDetail(3),
  addFavorite(5);

  const XpEvent(this.amount);
  final int amount;
}

// ── Service ───────────────────────────────────────────────────────────────────

class XpService extends ChangeNotifier {
  XpService();

  static const _keyXp            = 'xp_total';
  static const _keyLastLogin     = 'xp_last_login';
  static const _keyStreak        = 'xp_streak';
  static const _keyMatchViews    = 'xp_match_views';
  static const _keyAchievements  = 'xp_achievements';

  int _xp = 0;
  int _streak = 0;
  int _matchViews = 0;
  Set<String> _earnedAchievements = {};
  bool _loaded = false;

  int get xp => _xp;
  int get streak => _streak;
  int get matchViews => _matchViews;
  bool get loaded => _loaded;
  Set<String> get earnedAchievements => _earnedAchievements;

  XpLevel get currentLevel => XpLevel.forXp(_xp);

  double get levelProgress {
    final lvl = currentLevel;
    if (lvl.maxXp == -1) return 1.0;
    final range = (lvl.maxXp - lvl.minXp).toDouble();
    if (range <= 0) return 1.0;
    return ((_xp - lvl.minXp) / range).clamp(0.0, 1.0);
  }

  int get xpToNextLevel {
    final lvl = currentLevel;
    if (lvl.maxXp == -1) return 0;
    return (lvl.maxXp + 1) - _xp;
  }

  List<Achievement> get allAchievements => Achievement.all;

  bool hasAchievement(String id) => _earnedAchievements.contains(id);

  // Returns list of newly-earned achievements + xp gained (for UI notifications)
  Future<({int xpGained, List<Achievement> newBadges})> trackEvent(
    XpEvent event,
  ) async {
    await _ensureLoaded();
    int gained = event.amount;
    final newBadges = <Achievement>[];

    if (event == XpEvent.viewMatchDetail) { _matchViews++; }

    // Check achievements
    newBadges.addAll(await _checkAchievements());

    await _addXp(gained);
    await _save();
    notifyListeners();
    return (xpGained: gained, newBadges: newBadges);
  }

  // Call on app startup — handles daily login + streak
  Future<({int xpGained, int streak, List<Achievement> newBadges})> onAppOpen() async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_keyLastLogin);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isNewDay = false;
    if (lastLoginStr == null) {
      isNewDay = true;
    } else {
      final last = DateTime.tryParse(lastLoginStr);
      if (last != null) {
        final lastDay = DateTime(last.year, last.month, last.day);
        final diff = today.difference(lastDay).inDays;
        if (diff >= 1) {
          isNewDay = true;
          // Streak: +1 if consecutive day, reset otherwise
          if (diff == 1) {
            _streak++;
          } else {
            _streak = 1;
          }
        }
      }
    }

    int gained = 0;
    final newBadges = <Achievement>[];

    if (isNewDay) {
      gained = XpEvent.dailyLogin.amount;
      await prefs.setString(_keyLastLogin, now.toIso8601String());
      newBadges.addAll(await _checkAchievements());
      await _addXp(gained);
      await _save();
      notifyListeners();
    }

    return (xpGained: gained, streak: _streak, newBadges: newBadges);
  }

  Future<List<Achievement>> _checkAchievements() async {
    final newBadges = <Achievement>[];
    Future<void> tryUnlock(String id) async {
      if (!_earnedAchievements.contains(id)) {
        _earnedAchievements.add(id);
        final a = Achievement.byId(id);
        if (a != null) {
          newBadges.add(a);
          if (a.xpReward > 0) { await _addXp(a.xpReward); }
        }
      }
    }

    if (_matchViews >= 1) { await tryUnlock('first_match'); }
    if (_matchViews >= 5) { await tryUnlock('match_5'); }
    if (_matchViews >= 25) { await tryUnlock('match_25'); }
    if (_streak >= 3) { await tryUnlock('streak_3'); }
    if (_streak >= 7) { await tryUnlock('streak_7'); }
    if (_streak >= 30) { await tryUnlock('streak_30'); }
    if (currentLevel.level >= 3) { await tryUnlock('level_3'); }
    if (currentLevel.level >= 5) { await tryUnlock('level_5'); }

    return newBadges;
  }

  Future<void> unlockFavoriteAchievement() async {
    await _ensureLoaded();
    if (!_earnedAchievements.contains('favorite_team')) {
      _earnedAchievements.add('favorite_team');
      await _addXp(Achievement.byId('favorite_team')?.xpReward ?? 0);
      await _save();
      notifyListeners();
    }
  }

  Future<void> _addXp(int amount) async {
    _xp += amount;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt(_keyXp) ?? 0;
    _streak = prefs.getInt(_keyStreak) ?? 0;
    _matchViews = prefs.getInt(_keyMatchViews) ?? 0;
    _earnedAchievements = (prefs.getStringList(_keyAchievements) ?? []).toSet();
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXp, _xp);
    await prefs.setInt(_keyStreak, _streak);
    await prefs.setInt(_keyMatchViews, _matchViews);
    await prefs.setStringList(_keyAchievements, _earnedAchievements.toList());
  }
}
