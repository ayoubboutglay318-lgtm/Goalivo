import 'package:flutter/material.dart';

import '../models/match_models.dart';

class _PlayerRating {
  _PlayerRating({required this.name, required this.teamName, required this.teamId});
  final String name;
  final String teamName;
  final int? teamId;
  double rating = 6.5;
  int goals = 0;
  int assists = 0;
  int yellowCards = 0;
  bool redCard = false;

  String get ratingStr => rating.toStringAsFixed(1);

  Color ratingColor() {
    if (rating >= 8.5) return Colors.green.shade400;
    if (rating >= 7.5) return Colors.lightGreen;
    if (rating >= 6.5) return Colors.amber;
    if (rating >= 5.5) return Colors.orange;
    return Colors.red.shade400;
  }
}

class PlayerRatingsWidget extends StatelessWidget {
  const PlayerRatingsWidget({super.key, required this.match});
  final FootballMatch match;

  static const _isFinishedStatuses = {'FT', 'AET', 'PEN', '1H', '2H', 'HT', 'ET', 'P'};

  Map<String, _PlayerRating> _buildRatings() {
    final ratings = <String, _PlayerRating>{};

    for (final event in match.events) {
      final playerName = event.player?.name;
      final assistName = event.assist?.name;
      final teamName = event.team?.name ?? '';
      final teamId = event.team?.id;
      final type = event.type?.toLowerCase() ?? '';
      final detail = event.detail?.toLowerCase() ?? '';

      if (playerName != null && playerName.isNotEmpty) {
        final r = ratings.putIfAbsent(
          playerName,
          () => _PlayerRating(name: playerName, teamName: teamName, teamId: teamId),
        );
        if (type == 'goal') {
          if (detail.contains('own')) {
            r.rating -= 1.5; // Own goal
          } else {
            r.goals++;
            r.rating += 2.0;
          }
        } else if (type == 'card') {
          if (detail.contains('yellow')) {
            r.yellowCards++;
            r.rating -= 0.5;
          } else if (detail.contains('red')) {
            r.redCard = true;
            r.rating -= 2.5;
          }
        }
      }

      if (assistName != null && assistName.isNotEmpty) {
        final r = ratings.putIfAbsent(
          assistName,
          () => _PlayerRating(name: assistName, teamName: teamName, teamId: teamId),
        );
        r.assists++;
        r.rating += 1.0;
      }
    }

    // Clamp all ratings
    for (final r in ratings.values) {
      r.rating = r.rating.clamp(3.0, 10.0);
    }

    return ratings;
  }

  @override
  Widget build(BuildContext context) {
    final status = match.fixture.status?.short ?? 'NS';
    if (!_isFinishedStatuses.contains(status)) return const SizedBox.shrink();

    final ratings = _buildRatings();
    if (ratings.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final homeId = match.teams.home.id;
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';

    final homeRatings = ratings.values
        .where((r) => r.teamId == homeId)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final awayRatings = ratings.values
        .where((r) => r.teamId != homeId)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (homeRatings.isEmpty && awayRatings.isEmpty) return const SizedBox.shrink();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Player Ratings',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (homeRatings.isNotEmpty) ...[
              _TeamHeader(name: homeName, theme: theme),
              const SizedBox(height: 8),
              ...homeRatings.map((r) => _RatingRow(rating: r)),
            ],
            if (homeRatings.isNotEmpty && awayRatings.isNotEmpty)
              const SizedBox(height: 16),
            if (awayRatings.isNotEmpty) ...[
              _TeamHeader(name: awayName, theme: theme),
              const SizedBox(height: 8),
              ...awayRatings.map((r) => _RatingRow(rating: r)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.name, required this.theme});
  final String name;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      name.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating});
  final _PlayerRating rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rating.name,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Event icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rating.goals > 0) ...[
                Text('⚽×${rating.goals}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
              ],
              if (rating.assists > 0) ...[
                Text('🎯×${rating.assists}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
              ],
              if (rating.yellowCards > 0) ...[
                const Text('🟨', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
              ],
              if (rating.redCard) ...[
                const Text('🟥', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(width: 8),
          // Rating badge
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: rating.ratingColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: rating.ratingColor().withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              rating.ratingStr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: rating.ratingColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
