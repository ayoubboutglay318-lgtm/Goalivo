import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_models.dart';

class ManOfMatchWidget extends StatefulWidget {
  const ManOfMatchWidget({super.key, required this.match});
  final FootballMatch match;

  @override
  State<ManOfMatchWidget> createState() => _ManOfMatchWidgetState();
}

class _ManOfMatchWidgetState extends State<ManOfMatchWidget> {
  String? _voted;
  bool _loaded = false;

  String get _key => 'motm_${widget.match.fixture.id}';

  List<String> get _candidates {
    final seen = <String>{};
    final result = <String>[];
    for (final e in widget.match.events) {
      if (e.type?.toLowerCase() == 'goal' || e.type?.toLowerCase() == 'card') {
        final name = e.player?.name;
        if (name != null && name.isNotEmpty && seen.add(name)) {
          result.add(name);
        }
      }
    }
    return result.take(8).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voted = prefs.getString(_key);
      _loaded = true;
    });
  }

  Future<void> _vote(String name) async {
    if (_voted != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name);
    setState(() => _voted = name);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.match.fixture.status?.short ?? 'NS';
    final isFinished = {'FT', 'AET', 'PEN'}.contains(status);
    final candidates = _candidates;

    if (!isFinished || candidates.isEmpty || !_loaded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Man of the Match',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (_voted != null) ...[
                  const Spacer(),
                  const Icon(Icons.how_to_vote_outlined, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('Voted', style: theme.textTheme.labelSmall?.copyWith(color: Colors.amber)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _voted == null ? 'Who stood out the most?' : 'Your vote: $_voted',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: _voted != null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidates.map((name) {
                final isVoted = _voted == name;
                return GestureDetector(
                  onTap: _voted == null ? () => _vote(name) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isVoted
                          ? Colors.amber.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVoted
                            ? Colors.amber
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isVoted ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isVoted) ...[
                          const Text('🏅', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isVoted ? FontWeight.w800 : FontWeight.w500,
                            color: isVoted ? Colors.amber : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
