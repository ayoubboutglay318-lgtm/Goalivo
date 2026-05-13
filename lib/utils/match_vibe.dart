import 'package:flutter/material.dart';

import '../models/match_models.dart';

enum VibeLevel { cold, average, hot, electric, chaos }

class MatchVibe {
  const MatchVibe({
    required this.score,
    required this.level,
    required this.label,
    required this.emoji,
    required this.color,
    required this.homeMomentum,
    required this.dramaLabel,
    required this.goalsCount,
    required this.redCards,
  });

  final double score; // 0–100
  final VibeLevel level;
  final String label;
  final String emoji;
  final Color color;
  final double homeMomentum; // 0.0 = all away, 1.0 = all home, 0.5 = neutral
  final String dramaLabel;
  final int goalsCount;
  final int redCards;

  static MatchVibe from(FootballMatch match) {
    final status = match.fixture.status?.short ?? 'NS';
    final isLive = {'1H', '2H', 'HT', 'ET', 'P'}.contains(status);
    final isFinished = {'FT', 'AET', 'PEN'}.contains(status);
    final elapsed = match.fixture.status?.elapsed ?? 0;
    final homeGoals = match.goals.home ?? 0;
    final awayGoals = match.goals.away ?? 0;
    final totalGoals = homeGoals + awayGoals;
    final diff = (homeGoals - awayGoals).abs();
    final events = match.events;

    int red = events
        .where(
          (e) =>
              e.type?.toLowerCase() == 'card' &&
              (e.detail?.toLowerCase().contains('red') ?? false),
        )
        .length;

    // ── Score ─────────────────────────────────────────────────────────────────
    double s = 5;

    // Goals
    s += (totalGoals * 8).clamp(0, 36).toDouble();

    // Close score bonus
    if (diff == 0 && totalGoals > 0) s += 20;
    if (diff <= 1 && totalGoals > 0) s += 12;

    // Late drama (live)
    if (isLive && elapsed >= 85) {
      s += 20;
    } else if (isLive && elapsed >= 75) {
      s += 12;
    }

    // Red cards chaos
    s += (red * 8).clamp(0, 20).toDouble();

    // Comeback scenario
    if (_isComeback(match.score, homeGoals, awayGoals)) s += 15;

    // Recent goals (last 15 min of events)
    final recentGoals = _recentGoals(events, elapsed, window: 15);
    s += (recentGoals * 10).clamp(0, 20).toDouble();

    // Not-started or not relevant penalty
    if (!isLive && !isFinished) s = s.clamp(0, 15);

    s = s.clamp(0, 100);

    // ── Level ─────────────────────────────────────────────────────────────────
    final VibeLevel level;
    final String label;
    final String emoji;
    final Color color;

    if (s < 15) {
      level = VibeLevel.cold;
      label = 'Ice cold';
      emoji = '🧊';
      color = Colors.blueGrey;
    } else if (s < 35) {
      level = VibeLevel.average;
      label = 'Warming up';
      emoji = '😐';
      color = Colors.blueGrey.shade300;
    } else if (s < 55) {
      level = VibeLevel.hot;
      label = 'Heating up';
      emoji = '🔥';
      color = Colors.orange;
    } else if (s < 75) {
      level = VibeLevel.electric;
      label = 'Electric!';
      emoji = '⚡';
      color = Colors.yellow.shade700;
    } else {
      level = VibeLevel.chaos;
      label = 'Absolute chaos!';
      emoji = '💥';
      color = Colors.red;
    }

    // ── Drama label ───────────────────────────────────────────────────────────
    final dramaLabel = _dramaLabel(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      diff: diff,
      totalGoals: totalGoals,
      elapsed: elapsed,
      isLive: isLive,
      isFinished: isFinished,
      red: red,
      recentGoals: recentGoals,
    );

    // ── Momentum ──────────────────────────────────────────────────────────────
    final homeMom = _momentum(events, elapsed, match.teams.home.id);

    return MatchVibe(
      score: s,
      level: level,
      label: label,
      emoji: emoji,
      color: color,
      homeMomentum: homeMom,
      dramaLabel: dramaLabel,
      goalsCount: totalGoals,
      redCards: red,
    );
  }

  static bool _isComeback(
    MatchScore? score,
    int currentHome,
    int currentAway,
  ) {
    final ht = score?.halftime;
    if (ht == null) return false;
    final htHome = ht.home ?? 0;
    final htAway = ht.away ?? 0;
    // Was losing at HT but now winning or level
    if (htHome < htAway && currentHome >= currentAway) { return true; }
    if (htAway < htHome && currentAway >= currentHome) { return true; }
    return false;
  }

  static int _recentGoals(
    List<MatchEvent> events,
    int elapsed,
    {required int window}
  ) {
    return events
        .where(
          (e) =>
              e.type?.toLowerCase() == 'goal' &&
              (e.time?.elapsed ?? 0) >= (elapsed - window) &&
              (e.time?.elapsed ?? 0) <= elapsed,
        )
        .length;
  }

  static double _momentum(
    List<MatchEvent> events,
    int elapsed,
    int? homeTeamId,
  ) {
    if (homeTeamId == null || events.isEmpty) return 0.5;
    final recent = events.where(
      (e) =>
          (e.time?.elapsed ?? 0) >= (elapsed - 20).clamp(0, elapsed) &&
          (e.type?.toLowerCase() == 'goal' ||
              e.type?.toLowerCase() == 'card'),
    );
    double home = 0;
    double away = 0;
    for (final e in recent) {
      final isHome = e.team?.id == homeTeamId;
      final isGoal = e.type?.toLowerCase() == 'goal';
      final isRed =
          e.type?.toLowerCase() == 'card' &&
          (e.detail?.toLowerCase().contains('red') ?? false);
      if (isGoal) {
        if (isHome) { home += 2; } else { away += 2; }
      } else if (isRed) {
        if (isHome) { away += 1.5; } else { home += 1.5; }
      }
    }
    if (home + away == 0) return 0.5;
    return (home / (home + away)).clamp(0.0, 1.0);
  }

  static String _dramaLabel({
    required int homeGoals,
    required int awayGoals,
    required int diff,
    required int totalGoals,
    required int elapsed,
    required bool isLive,
    required bool isFinished,
    required int red,
    required int recentGoals,
  }) {
    if (!isLive && !isFinished) return 'Match not started';

    if (isFinished) {
      if (totalGoals == 0) return 'Goalless stalemate';
      if (diff == 0) return 'Hard-fought draw';
      if (diff >= 4) return 'Dominant display';
      if (diff >= 2) return 'Comfortable win';
      return 'Close contest';
    }

    // Live
    if (recentGoals >= 2) return 'Goal frenzy right now!';
    if (elapsed >= 85 && diff == 0) return 'Last-minute drama!';
    if (elapsed >= 85 && diff == 1) return 'One goal in it — late drama!';
    if (elapsed >= 75 && diff == 0) return 'Anyone can win this!';
    if (red >= 2) return 'Cards flying everywhere!';
    if (red >= 1) return 'Down to 10 men!';
    if (totalGoals >= 5) return 'Goal fest!';
    if (diff == 0 && totalGoals > 0) return 'All square — tense!';
    if (diff >= 3) return 'One team dominating';
    return 'Match in progress';
  }
}
