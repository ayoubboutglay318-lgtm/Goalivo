import 'dart:math';
import 'package:flutter/material.dart';
import '../models/match_models.dart';

class MatchStatsWidget extends StatelessWidget {
  const MatchStatsWidget({
    super.key,
    required this.match,
    this.homeTeamStats,
    this.awayTeamStats,
  });

  final FootballMatch match;
  final MatchTeamStats? homeTeamStats;
  final MatchTeamStats? awayTeamStats;

  static int _int(String? v) {
    if (v == null || v == 'null') return 0;
    return int.tryParse(v.replaceAll('%', '').trim()) ?? 0;
  }

  static double _pct(String? v) {
    if (v == null) return 0.5;
    final n = double.tryParse(v.replaceAll('%', '').trim());
    return n != null ? (n / 100).clamp(0.0, 1.0) : 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final homeName = match.teams.home.name ?? 'Home';
    final awayName = match.teams.away.name ?? 'Away';
    final h = homeTeamStats;
    final a = awayTeamStats;
    final hasStats = h != null && h.stats.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Momentum graph — always built from events
        _MomentumGraph(
          events: match.events,
          homeTeamId: match.teams.home.id,
          awayTeamId: match.teams.away.id,
          homeName: homeName,
          awayName: awayName,
        ),
        const SizedBox(height: 20),

        if (hasStats) ...[
          // Possession
          _PossessionBar(
            homePct: _pct(h.get('Ball Possession')),
            homeName: homeName,
            awayName: awayName,
            homeLabel: h.get('Ball Possession') ?? '50%',
            awayLabel: a?.get('Ball Possession') ?? '50%',
          ),
          const SizedBox(height: 16),
          _divider('Shots'),
          _StatRow(label: 'Total Shots',       home: _int(h.get('Total Shots')),       away: _int(a?.get('Total Shots'))),
          _StatRow(label: 'On Target',         home: _int(h.get('Shots on Goal')),      away: _int(a?.get('Shots on Goal'))),
          _StatRow(label: 'Off Target',        home: _int(h.get('Shots off Goal')),     away: _int(a?.get('Shots off Goal'))),
          _StatRow(label: 'Blocked',           home: _int(h.get('Blocked Shots')),      away: _int(a?.get('Blocked Shots'))),
          const SizedBox(height: 8),
          _divider('Attack'),
          _StatRow(label: 'Expected Goals (xG)', home: 0, away: 0,
            homeLabel: h.get('expected_goals') ?? h.get('Expected Goals') ?? '—',
            awayLabel: a?.get('expected_goals') ?? a?.get('Expected Goals') ?? '—',
          ),
          _StatRow(label: 'Corner Kicks',      home: _int(h.get('Corner Kicks')),       away: _int(a?.get('Corner Kicks'))),
          _StatRow(label: 'Offsides',          home: _int(h.get('Offsides')),           away: _int(a?.get('Offsides'))),
          const SizedBox(height: 8),
          _divider('Defence'),
          _StatRow(label: 'Fouls',             home: _int(h.get('Fouls')),              away: _int(a?.get('Fouls'))),
          _StatRow(label: 'Yellow Cards',      home: _int(h.get('Yellow Cards')),       away: _int(a?.get('Yellow Cards'))),
          _StatRow(label: 'Red Cards',         home: _int(h.get('Red Cards')),          away: _int(a?.get('Red Cards'))),
          _StatRow(label: 'Goalkeeper Saves',  home: _int(h.get('Goalkeeper Saves')),   away: _int(a?.get('Goalkeeper Saves'))),
          const SizedBox(height: 8),
          _divider('Passing'),
          _StatRow(label: 'Total Passes',      home: _int(h.get('Total passes')),       away: _int(a?.get('Total passes'))),
          _StatRow(label: 'Pass Accuracy',     home: 0, away: 0,
            homeLabel: h.get('Passes %') ?? '—',
            awayLabel: a?.get('Passes %') ?? '—',
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.white24, size: 18),
                const SizedBox(width: 10),
                Text('Detailed stats not available for this match',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Widget _divider(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      );
}

// ── Possession bar ────────────────────────────────────────────────────────────

class _PossessionBar extends StatelessWidget {
  const _PossessionBar({
    required this.homePct,
    required this.homeName,
    required this.awayName,
    required this.homeLabel,
    required this.awayLabel,
  });

  final double homePct;
  final String homeName;
  final String awayName;
  final String homeLabel;
  final String awayLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(homeLabel,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                    color: Color(0xFF42A5F5))),
            const Text('Possession',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(awayLabel,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                    color: Color(0xFFEF5350))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: (homePct * 100).round(),
                child: Container(height: 8, color: const Color(0xFF1565C0)),
              ),
              Expanded(
                flex: ((1 - homePct) * 100).round(),
                child: Container(height: 8, color: const Color(0xFFC62828)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stat comparison row ───────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.home,
    required this.away,
    this.homeLabel,
    this.awayLabel,
  });

  final String label;
  final int home;
  final int away;
  final String? homeLabel;
  final String? awayLabel;

  @override
  Widget build(BuildContext context) {
    final total = home + away;
    final homeFlex = total == 0 ? 1 : home;
    final awayFlex = total == 0 ? 1 : away;
    final hl = homeLabel ?? '$home';
    final al = awayLabel ?? '$away';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hl,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14,
                      color: Color(0xFF42A5F5))),
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(al,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14,
                      color: Color(0xFFEF5350))),
            ],
          ),
          const SizedBox(height: 4),
          if (homeLabel == null && awayLabel == null)
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Row(
                children: [
                  Expanded(
                    flex: homeFlex,
                    child: Container(height: 5,
                        color: const Color(0xFF1565C0).withValues(alpha: 0.7)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: awayFlex,
                    child: Container(height: 5,
                        color: const Color(0xFFC62828).withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Momentum graph ────────────────────────────────────────────────────────────

class _MomentumGraph extends StatelessWidget {
  const _MomentumGraph({
    required this.events,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeName,
    required this.awayName,
  });

  final List<MatchEvent> events;
  final int? homeTeamId;
  final int? awayTeamId;
  final String homeName;
  final String awayName;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(homeName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF42A5F5)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const Text('Attack Momentum',
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(awayName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFFEF5350)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: _MomentumPainter(
              events: events,
              homeTeamId: homeTeamId,
              awayTeamId: awayTeamId,
            ),
            size: Size.infinite,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0\'', style: TextStyle(color: Colors.white24, fontSize: 9)),
            const Text('45\'', style: TextStyle(color: Colors.white24, fontSize: 9)),
            const Text('90\'', style: TextStyle(color: Colors.white24, fontSize: 9)),
          ],
        ),
      ],
    );
  }
}

class _MomentumPainter extends CustomPainter {
  _MomentumPainter({required this.events, this.homeTeamId, this.awayTeamId});

  final List<MatchEvent> events;
  final int? homeTeamId;
  final int? awayTeamId;

  static const _intervals = 18; // 5-min blocks over 90 mins

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h / 2;
    final barW = w / _intervals;

    // Count events per 5-min interval per team
    final homeCount = List<double>.filled(_intervals, 0);
    final awayCount = List<double>.filled(_intervals, 0);

    for (final e in events) {
      final elapsed = e.time?.elapsed ?? 0;
      final idx = ((elapsed - 1) / 5).floor().clamp(0, _intervals - 1);
      final teamId = e.team?.id;
      final weight = _weight(e.type, e.detail);
      if (weight == 0) continue;
      if (teamId == homeTeamId) {
        homeCount[idx] += weight;
      } else if (teamId == awayTeamId) {
        awayCount[idx] += weight;
      }
    }

    final maxVal = [...homeCount, ...awayCount].fold(0.0, max);
    if (maxVal == 0) return;

    final homePaint = Paint()..color = const Color(0xFF1565C0).withValues(alpha: 0.85);
    final awayPaint = Paint()..color = const Color(0xFFC62828).withValues(alpha: 0.85);
    final midPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.8;

    // Midline
    canvas.drawLine(Offset(0, mid), Offset(w, mid), midPaint);

    for (int i = 0; i < _intervals; i++) {
      final x = i * barW;
      final bw = barW - 1.5;

      if (homeCount[i] > 0) {
        final barH = (homeCount[i] / maxVal) * (mid - 4);
        final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, mid - barH, bw, barH),
          const Radius.circular(2),
        );
        canvas.drawRRect(rr, homePaint);
      }
      if (awayCount[i] > 0) {
        final barH = (awayCount[i] / maxVal) * (mid - 4);
        final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, mid, bw, barH),
          const Radius.circular(2),
        );
        canvas.drawRRect(rr, awayPaint);
      }
    }
  }

  static double _weight(String? type, String? detail) {
    final t = type?.toLowerCase() ?? '';
    final d = detail?.toLowerCase() ?? '';
    if (t == 'goal' && !d.contains('own')) return 3;
    if (t == 'goal') return 2;
    if (t == 'card' && d.contains('red')) return 1.5;
    if (t == 'card') return 1;
    if (t == 'subst') return 0.5;
    return 0;
  }

  @override
  bool shouldRepaint(covariant _MomentumPainter old) =>
      old.events != events;
}
