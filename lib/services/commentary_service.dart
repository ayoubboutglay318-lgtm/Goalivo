import 'package:flutter/material.dart';

import '../models/match_models.dart';
import 'football_api_service.dart';

class MatchCommentary {
  const MatchCommentary({
    required this.match,
    required this.badge,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final FootballMatch match;
  final IconData badge;
  final String title;
  final String description;
  final DateTime timestamp;
}

class CommentaryService {
  CommentaryService({required this.apiService});

  final FootballApiService apiService;

  Future<List<MatchCommentary>> getLiveCommentary() async {
    final liveMatches = await apiService.getLiveMatches();
    final commentary = <MatchCommentary>[];

    for (final match in liveMatches) {
      final home = match.teams.home.name ?? 'Home';
      final away = match.teams.away.name ?? 'Away';
      final fixtureTitle = '$home vs $away';

      if (match.events.isEmpty) {
        commentary.add(
          MatchCommentary(
            match: match,
            badge: Icons.sports_soccer,
            title: fixtureTitle,
            description:
                'No live events yet. Stay tuned for play-by-play updates.',
            timestamp: DateTime.now(),
          ),
        );
        continue;
      }

      for (final event in match.events) {
        final elapsed = event.time?.elapsed;
        final details = _formatCommentary(event);
        final timestamp = DateTime.now().subtract(
          Duration(
            minutes: elapsed != null
                ? (match.fixture.status?.elapsed ?? 0) - elapsed
                : 0,
          ),
        );
        commentary.add(
          MatchCommentary(
            match: match,
            badge: _iconForEvent(event.type),
            title: elapsed != null ? '$elapsed’ $fixtureTitle' : fixtureTitle,
            description: details,
            timestamp: timestamp,
          ),
        );
      }
    }

    commentary.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return commentary;
  }

  String _formatCommentary(MatchEvent event) {
    final team = event.team?.name;
    final player = event.player?.name;
    final assist = event.assist?.name;
    final detail = event.detail ?? event.comments;
    final eventType = event.type?.toLowerCase() ?? 'event';

    switch (eventType) {
      case 'goal':
        final assistText = assist != null ? ' assisted by $assist' : '';
        return '${player ?? 'A player'} scored for ${team ?? 'the team'}$assistText.';
      case 'yellow card':
      case 'red card':
        return '${team ?? 'A team'} received a ${eventType.replaceAll('card', 'card')} for ${player ?? 'a player'}.${detail != null ? ' $detail' : ''}';
      case 'substitution':
        return '${team ?? 'A team'} made a substitution: ${detail ?? 'player change'}.';
      case 'penalty':
        return '${team ?? 'A team'} is awarded a penalty.${detail != null ? ' $detail' : ''}';
      default:
        return detail != null
            ? '${team != null ? '$team — ' : ''}$detail'
            : '${team ?? 'The match'} saw a live update.';
    }
  }

  IconData _iconForEvent(String? type) {
    switch (type?.toLowerCase()) {
      case 'goal':
        return Icons.sports_score;
      case 'yellow card':
        return Icons.square_foot;
      case 'red card':
        return Icons.highlight_off;
      case 'substitution':
        return Icons.swap_horiz;
      case 'penalty':
        return Icons.sports_soccer;
      default:
        return Icons.flash_on;
    }
  }
}
