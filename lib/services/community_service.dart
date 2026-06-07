import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'community_api_service.dart';
import 'prediction_service.dart';
import 'xp_service.dart';

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.summary,
    required this.publishedAt,
  });

  final String title;
  final String summary;
  final DateTime publishedAt;
}

class SocialPost {
  const SocialPost({
    required this.id,
    required this.user,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final String user;
  final String message;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };

  static SocialPost? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final user = json['user']?.toString();
    final message = json['message']?.toString();
    final timestamp = DateTime.tryParse(json['timestamp']?.toString() ?? '');
    if (id == null || user == null || message == null || timestamp == null) {
      return null;
    }
    return SocialPost(
      id: id,
      user: user,
      message: message,
      timestamp: timestamp,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.place,
    this.subtitle,
    this.isYou = false,
  });

  final String name;
  final int score;
  final int place;
  final String? subtitle;
  final bool isYou;
}

class CommunityService extends ChangeNotifier {
  static const _postKey = 'community_posts';
  final XpService xpService;
  final PredictionService predictionService;
  final CommunityApiService? apiService;

  CommunityService({
    required this.xpService,
    required this.predictionService,
    this.apiService,
  });

  final List<SocialPost> _posts = [];
  bool _loaded = false;

  List<SocialPost> get posts => List.unmodifiable(_posts.reversed);

  Future<void> load() async {
    if (_loaded) return;

    if (apiService != null) {
      try {
        await _loadRemotePosts();
      } catch (_) {
        await _loadLocalPosts();
      }
    } else {
      await _loadLocalPosts();
    }

    if (_posts.isEmpty) {
      _pushDefaultPosts();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _loadLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_postKey);
    if (raw == null) {
      _posts.clear();
      return;
    }

    try {
      final data = jsonDecode(raw);
      if (data is List) {
        _posts.clear();
        for (final item in data) {
          if (item is Map) {
            final post = SocialPost.fromJson(Map<String, dynamic>.from(item));
            if (post != null) _posts.add(post);
          }
        }
      }
    } catch (_) {
      _posts.clear();
    }
  }

  Future<void> _loadRemotePosts() async {
    final remoteData = await apiService!.fetchPosts();
    _posts.clear();
    for (final item in remoteData) {
      final post = SocialPost.fromJson(Map<String, dynamic>.from(item));
      if (post != null) _posts.add(post);
    }
  }

  Future<void> refresh() async {
    _loaded = false;
    await load();
  }

  Future<void> addPost(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final post = SocialPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: 'You',
      message: trimmed,
      timestamp: DateTime.now(),
    );

    if (apiService != null) {
      try {
        final json = await apiService!.createPost(
          user: post.user,
          message: post.message,
          timestamp: post.timestamp,
        );
        final remotePost = SocialPost.fromJson(Map<String, dynamic>.from(json));
        if (remotePost != null) {
          _posts.add(remotePost);
          await _savePosts();
          notifyListeners();
          return;
        }
      } catch (_) {
        // Remote post failed; fall back to local storage.
      }
    }

    _posts.add(post);
    await _savePosts();
    notifyListeners();
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_posts.map((post) => post.toJson()).toList());
    await prefs.setString(_postKey, raw);
  }

  void _pushDefaultPosts() {
    _posts.addAll([
      SocialPost(
        id: 'welcome',
        user: 'goallive',
        message:
            'Welcome to the community â€” share your thoughts, predict outcomes, and celebrate goals together!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SocialPost(
        id: 'pulse',
        user: 'Mia',
        message:
            'My favorite team is on fire this week. Who else is ready for the derby?',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 16),
        ),
      ),
      SocialPost(
        id: 'stats',
        user: 'Alex',
        message:
            'Prediction leaderboard looks tight â€” I need one more exact score for the top 3!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      ),
    ]);
  }

  static List<NewsArticle> getNewsForTeam(String teamName) {
    final now = DateTime.now();
    final safeName = teamName.trim().isEmpty ? 'Your team' : teamName;
    return [
      NewsArticle(
        title: '$safeName coach previews the next big match',
        summary:
            'Pre-match training is complete and $safeName is ready to challenge the rivals with fresh tactics.',
        publishedAt: now.subtract(const Duration(hours: 3)),
      ),
      NewsArticle(
        title: 'Injury update for $safeName',
        summary:
            'Key players are being monitored, but the squad remains mostly fit ahead of a crucial fixture.',
        publishedAt: now.subtract(const Duration(hours: 8)),
      ),
      NewsArticle(
        title: 'Fan mood rises as $safeName eyes a winning streak',
        summary:
            'Supporters are buzzing after a strong set of results and a confident team performance.',
        publishedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }

  List<LeaderboardEntry> getLeaderboard() {
    final userXp = xpService.xp;
    final predictionBonus =
        predictionService.allPredictions
                .where((p) => p.wasCorrectScore)
                .length *
            50 +
        predictionService.allPredictions
                .where((p) => p.wasCorrectResult && !p.wasCorrectScore)
                .length *
            20;
    final userScore = userXp + predictionBonus;
    final competitors = [
      const LeaderboardEntry(
        name: 'Luca',
        score: 3260,
        place: 1,
        subtitle: 'Streak master',
      ),
      const LeaderboardEntry(
        name: 'Zara',
        score: 2785,
        place: 2,
        subtitle: 'Prediction ace',
      ),
      const LeaderboardEntry(
        name: 'Nina',
        score: 2420,
        place: 3,
        subtitle: 'Live watcher',
      ),
      const LeaderboardEntry(
        name: 'Sam',
        score: 1980,
        place: 4,
        subtitle: 'Quiz champion',
      ),
    ];
    final entries = List<LeaderboardEntry>.from(competitors)
      ..add(
        LeaderboardEntry(
          name: 'You',
          score: userScore,
          place: competitors.length + 1,
          subtitle: 'Your total influence',
          isYou: true,
        ),
      );
    entries.sort((a, b) => b.score.compareTo(a.score));
    return List<LeaderboardEntry>.generate(entries.length, (index) {
      final e = entries[index];
      return LeaderboardEntry(
        name: e.name,
        score: e.score,
        place: index + 1,
        subtitle: e.subtitle,
        isYou: e.isYou,
      );
    });
  }
}
