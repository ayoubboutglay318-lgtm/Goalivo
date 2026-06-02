import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../services/team_plan_service.dart';

typedef _P = ({String name, int number, String photoUrl, bool captain, String? pos, int? id});

class LineupPitchWidget extends StatefulWidget {
  const LineupPitchWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    this.events = const [],
    this.homeLineup,
    this.awayLineup,
  });

  final String homeTeamName;
  final String awayTeamName;
  final List<MatchEvent> events;
  final MatchLineup? homeLineup;
  final MatchLineup? awayLineup;

  @override
  State<LineupPitchWidget> createState() => _LineupPitchWidgetState();
}

class _LineupPitchWidgetState extends State<LineupPitchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  String? _cardFor(String playerName) {
    final last = playerName.trim().split(' ').last.toLowerCase();
    String? result;
    for (final e in widget.events) {
      final type = e.type?.toLowerCase() ?? '';
      final detail = e.detail?.toLowerCase() ?? '';
      final eName = (e.player?.name ?? '').toLowerCase();
      if (type == 'card' && (eName.contains(last) || last.contains(eName.split(' ').last))) {
        if (detail.contains('red')) return 'red';
        if (detail.contains('yellow')) result = 'yellow';
      }
    }
    return result;
  }

  bool _goalFor(String playerName) {
    final last = playerName.trim().split(' ').last.toLowerCase();
    for (final e in widget.events) {
      final type = e.type?.toLowerCase() ?? '';
      final eName = (e.player?.name ?? '').toLowerCase();
      if (type == 'goal' && (eName.contains(last) || last.contains(eName.split(' ').last))) {
        return true;
      }
    }
    return false;
  }

  List<Offset> _positions(String formation, bool isHome) {
    final parts = formation
        .split('-')
        .map((s) => int.tryParse(s) ?? 0)
        .where((n) => n > 0)
        .toList();
    final rows = [1, ...parts];
    final totalRows = rows.length;
    final positions = <Offset>[];

    for (int rowIdx = 0; rowIdx < totalRows; rowIdx++) {
      final count = rows[rowIdx];
      final double y;
      if (isHome) {
        y = 0.92 - (rowIdx / (totalRows - 1)) * 0.34;
      } else {
        y = 0.08 + (rowIdx / (totalRows - 1)) * 0.34;
      }
      for (int j = 0; j < count; j++) {
        final x = (j + 1) / (count + 1);
        positions.add(Offset(x, y));
      }
    }
    return positions;
  }

  List<_P> _apiPlayers(MatchLineup lineup) {
    final sorted = [...lineup.startXI]
      ..sort((a, b) {
        final aRow = int.tryParse(a.grid?.split(':').first ?? '99') ?? 99;
        final bRow = int.tryParse(b.grid?.split(':').first ?? '99') ?? 99;
        if (aRow != bRow) return aRow.compareTo(bRow);
        final aCol = int.tryParse(a.grid?.split(':').last ?? '99') ?? 99;
        final bCol = int.tryParse(b.grid?.split(':').last ?? '99') ?? 99;
        return aCol.compareTo(bCol);
      });
    return sorted
        .map((p) => (
              name: p.name ?? 'Player',
              number: p.number ?? 0,
              photoUrl: p.photoUrl,
              captain: p.captain,
              pos: p.pos,
              id: p.id,
            ))
        .toList();
  }

  List<_P> _apiSubs(MatchLineup lineup) => lineup.substitutes
      .map((p) => (
            name: p.name ?? 'Player',
            number: p.number ?? 0,
            photoUrl: p.photoUrl,
            captain: false,
            pos: p.pos,
            id: p.id,
          ))
      .toList();

  void _showPlayerModal(BuildContext context, _P player, bool isHome) {
    final circleColor = isHome ? const Color(0xFF1565C0) : const Color(0xFFC62828);
    final teamName = isHome ? widget.homeTeamName : widget.awayTeamName;
    final hasGoal = _goalFor(player.name);
    final card = _cardFor(player.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlayerModal(
        player: player,
        circleColor: circleColor,
        teamName: teamName,
        hasGoal: hasGoal,
        card: card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String homeFormation;
    final List<_P> homePlayers;
    final List<_P> homeSubs;
    if (widget.homeLineup != null && widget.homeLineup!.startXI.isNotEmpty) {
      homeFormation = widget.homeLineup!.formation ?? '4-3-3';
      homePlayers = _apiPlayers(widget.homeLineup!);
      homeSubs = _apiSubs(widget.homeLineup!);
    } else {
      final plan = TeamPlanService.getPlanForTeam(widget.homeTeamName);
      homeFormation = plan.formation;
      homePlayers = plan.lineup
          .asMap()
          .entries
          .map((e) => (
                name: e.value.name,
                number: e.value.number ?? (e.key + 1),
                photoUrl: e.value.photoUrl ?? '',
                captain: e.key == 0,
                pos: e.value.position,
                id: null,
              ))
          .toList();
      homeSubs = [];
    }

    final String awayFormation;
    final List<_P> awayPlayers;
    final List<_P> awaySubs;
    if (widget.awayLineup != null && widget.awayLineup!.startXI.isNotEmpty) {
      awayFormation = widget.awayLineup!.formation ?? '4-3-3';
      awayPlayers = _apiPlayers(widget.awayLineup!);
      awaySubs = _apiSubs(widget.awayLineup!);
    } else {
      final plan = TeamPlanService.getPlanForTeam(widget.awayTeamName);
      awayFormation = plan.formation;
      awayPlayers = plan.lineup
          .asMap()
          .entries
          .map((e) => (
                name: e.value.name,
                number: e.value.number ?? (e.key + 1),
                photoUrl: e.value.photoUrl ?? '',
                captain: e.key == 0,
                pos: e.value.position,
                id: null,
              ))
          .toList();
      awaySubs = [];
    }

    // All teams now always have at least a generic numbered formation

    final homePositions = _positions(homeFormation, true);
    final awayPositions = _positions(awayFormation, false);

    final hasSubs = homeSubs.isNotEmpty || awaySubs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Formation header row
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.homeTeamName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(homeFormation,
                    style: const TextStyle(color: Color(0xFF9575CD), fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('LINEUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.2)),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(widget.awayTeamName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
                Text(awayFormation,
                    style: const TextStyle(color: Color(0xFFFF6584), fontWeight: FontWeight.w700, fontSize: 12),
                    textAlign: TextAlign.end),
              ]),
            ),
          ]),
        ),

        // Pitch
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: CustomPaint(
              painter: _PitchPainter(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return AnimatedBuilder(
                    animation: _entryAnim,
                    builder: (context, _) => Stack(
                      children: [
                        for (int i = 0; i < homePlayers.length && i < homePositions.length; i++)
                          _PlayerDot(
                            player: homePlayers[i],
                            x: homePositions[i].dx * w,
                            y: homePositions[i].dy * h,
                            isHome: true,
                            card: _cardFor(homePlayers[i].name),
                            hasGoal: _goalFor(homePlayers[i].name),
                            entryProgress: (_entryAnim.value * (homePlayers.length) - i).clamp(0.0, 1.0),
                            onTap: () => _showPlayerModal(context, homePlayers[i], true),
                          ),
                        for (int i = 0; i < awayPlayers.length && i < awayPositions.length; i++)
                          _PlayerDot(
                            player: awayPlayers[i],
                            x: awayPositions[i].dx * w,
                            y: awayPositions[i].dy * h,
                            isHome: false,
                            card: _cardFor(awayPlayers[i].name),
                            hasGoal: _goalFor(awayPlayers[i].name),
                            entryProgress: (_entryAnim.value * (awayPlayers.length) - i).clamp(0.0, 1.0),
                            onTap: () => _showPlayerModal(context, awayPlayers[i], false),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LegendDot(color: const Color(0xFF1565C0), label: widget.homeTeamName),
            const SizedBox(width: 20),
            _LegendDot(color: const Color(0xFFB71C1C), label: widget.awayTeamName),
          ]),
        ),

        // Bench section
        if (hasSubs) ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              Icon(Icons.airline_seat_recline_normal_outlined, size: 14, color: Colors.white38),
              SizedBox(width: 6),
              Text('BENCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1.2)),
            ]),
          ),
          const SizedBox(height: 10),
          _BenchSection(
            homeSubs: homeSubs,
            awaySubs: awaySubs,
            homeTeamName: widget.homeTeamName,
            awayTeamName: widget.awayTeamName,
            onTapPlayer: (p, isHome) => _showPlayerModal(context, p, isHome),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

// â”€â”€ Player dot â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PlayerDot extends StatelessWidget {
  const _PlayerDot({
    required this.player,
    required this.x,
    required this.y,
    required this.isHome,
    required this.entryProgress,
    required this.onTap,
    this.card,
    this.hasGoal = false,
  });

  final _P player;
  final double x;
  final double y;
  final bool isHome;
  final double entryProgress;
  final VoidCallback onTap;
  final String? card;
  final bool hasGoal;

  static const _dotSize = 48.0;
  static const _totalWidth = 62.0;

  bool get _isGeneric => player.name.trim().isEmpty;

  String get _displayName {
    if (_isGeneric) {
      final pos = player.pos?.toUpperCase() ?? '';
      return pos.isNotEmpty ? '${player.number} $pos' : '${player.number}';
    }
    final parts = player.name.trim().split(' ');
    final initial = parts.first[0].toUpperCase();
    final last = parts.last;
    final lastName = last.length > 8 ? '${last.substring(0, 7)}.' : last;
    final name = parts.length == 1 ? last : '$initial. $lastName';
    return '${player.number} $name';
  }

  String get _initials {
    if (_isGeneric) return player.pos?.toUpperCase().substring(0, player.pos!.length.clamp(0, 2)) ?? '${player.number}';
    final parts = player.name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  double _computeRating(bool hasGoal, String? card) {
    if (_isGeneric) return 0;
    final hash = player.name.codeUnits.fold(0, (a, b) => a + b);
    double base = 6.2 + (hash % 19) * 0.1;
    if (hasGoal) base += 0.7;
    if (card == 'yellow') base -= 0.5;
    if (card == 'red') base -= 1.5;
    return base.clamp(4.0, 9.9);
  }

  Color _ratingColor(double rating) {
    if (rating >= 8.5) return const Color(0xFF1565C0);
    if (rating >= 7.5) return const Color(0xFF2E7D32);
    if (rating >= 6.5) return const Color(0xFF4E5B69);
    return const Color(0xFFBF360C);
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = isHome ? const Color(0xFF1A56C4) : const Color(0xFFBF1C1C);
    final glowColor = isHome ? const Color(0xFF3D7BFF) : const Color(0xFFFF4444);
    final gradientColors = isHome
        ? [const Color(0xFF2563EB), const Color(0xFF1E3A8A)]
        : [const Color(0xFFDC2626), const Color(0xFF7F1D1D)];

    // Fallback widget: jersey number + initials when no photo
    Widget fallbackChild = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '${player.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            height: 1,
          ),
        ),
        Text(
          _initials,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
            fontSize: 8,
            height: 1.1,
          ),
        ),
      ]),
    );

    final Widget circleChild;
    if (player.photoUrl.isEmpty) {
      circleChild = fallbackChild;
    } else {
      circleChild = Image.network(
        player.photoUrl,
        width: _dotSize,
        height: _dotSize,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallbackChild,
        errorBuilder: (_, _, _) => fallbackChild,
      );
    }

    return Positioned(
      left: x - _totalWidth / 2,
      top: y - (_dotSize + 6) / 2,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: entryProgress.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.4 + 0.6 * entryProgress,
            child: SizedBox(
              width: _totalWidth,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Glow ring behind circle
                    Container(
                      width: _dotSize + 6,
                      height: _dotSize + 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor.withValues(alpha: 0.25),
                      ),
                    ),
                    // Player circle
                    Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(child: circleChild),
                    ),
                    // Captain badge (top-left)
                    if (player.captain)
                      Positioned(
                        top: -4,
                        left: -4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 3)],
                          ),
                          alignment: Alignment.center,
                          child: const Text('C', style: TextStyle(
                            fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ),
                    // Card badge (top-right)
                    if (card != null)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 10, height: 14,
                          decoration: BoxDecoration(
                            color: card == 'red' ? const Color(0xFFD32F2F) : const Color(0xFFFDD835),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white, width: 0.8),
                          ),
                        ),
                      ),
                    // Goal badge (bottom-right)
                    if (hasGoal)
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF166534),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: const Text('âš½', style: TextStyle(fontSize: 9)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Name pill
                Container(
                  width: _totalWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                  ),
                  child: Text(
                    _displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Rating chip â€” only for named players, not generic numbered slots
                if (!_isGeneric) ...[
                  const SizedBox(height: 1),
                  Builder(builder: (_) {
                    final rating = _computeRating(hasGoal, card);
                    final chipColor = _ratingColor(rating);
                    final isBest = rating >= 8.5;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isBest ? 'â˜…' : ''}${rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Player modal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PlayerModal extends StatelessWidget {
  const _PlayerModal({
    required this.player,
    required this.circleColor,
    required this.teamName,
    required this.hasGoal,
    this.card,
  });

  final _P player;
  final Color circleColor;
  final String teamName;
  final bool hasGoal;
  final String? card;

  String get _posLabel {
    switch (player.pos) {
      case 'G': return 'Goalkeeper';
      case 'D': return 'Defender';
      case 'M': return 'Midfielder';
      case 'F': return 'Forward';
      default: return player.pos ?? 'Player';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag handle
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        // Avatar
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: circleColor.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4),
              ],
            ),
            child: ClipOval(
              child: player.photoUrl.isNotEmpty
                  ? Image.network(player.photoUrl, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white70, size: 44))
                  : Icon(Icons.person, color: Colors.white70, size: 44),
            ),
          ),
          if (player.captain)
            Positioned(
              top: 0, left: 0,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text('C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        Text(player.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(teamName,
            style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        // Stats chips row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _StatChip(label: 'Number', value: '#${player.number}'),
            _StatChip(label: 'Position', value: _posLabel),
            if (hasGoal) _StatChip(label: 'Goal', value: 'âš½', accent: true),
            if (card != null)
              _StatChip(
                label: 'Card',
                value: card == 'red' ? 'ðŸŸ¥' : 'ðŸŸ¨',
                accent: true,
              ),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.accent = false});
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent ? Colors.white10 : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ]),
    );
  }
}

// â”€â”€ Bench section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BenchSection extends StatelessWidget {
  const _BenchSection({
    required this.homeSubs,
    required this.awaySubs,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.onTapPlayer,
  });

  final List<_P> homeSubs;
  final List<_P> awaySubs;
  final String homeTeamName;
  final String awayTeamName;
  final void Function(_P player, bool isHome) onTapPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (homeSubs.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(homeTeamName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9575CD))),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: homeSubs.map((p) => _BenchCard(
              player: p,
              color: const Color(0xFF1565C0),
              onTap: () => onTapPlayer(p, true),
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (awaySubs.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(awayTeamName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6584))),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: awaySubs.map((p) => _BenchCard(
              player: p,
              color: const Color(0xFFC62828),
              onTap: () => onTapPlayer(p, false),
            )).toList(),
          ),
        ),
      ],
    ]);
  }
}

class _BenchCard extends StatelessWidget {
  const _BenchCard({required this.player, required this.color, required this.onTap});
  final _P player;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25),
              border: Border.all(color: color, width: 1),
            ),
            child: ClipOval(
              child: player.photoUrl.isNotEmpty
                  ? Image.network(player.photoUrl, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white54, size: 18))
                  : const Icon(Icons.person, color: Colors.white54, size: 18),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              player.number > 0 ? '#${player.number}' : '-',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              player.name.split(' ').last,
              style: const TextStyle(fontSize: 9, color: Colors.white70),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}

// â”€â”€ Pitch painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Striped grass
    const stripeCount = 10;
    for (int i = 0; i < stripeCount; i++) {
      final stripeH = h / stripeCount;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, w, stripeH),
        Paint()
          ..color = i.isEven ? const Color(0xFF2E7D32) : const Color(0xFF388E3C),
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.75);

    canvas.drawRect(Rect.fromLTRB(w * .04, h * .01, w * .96, h * .99), line);
    canvas.drawLine(Offset(w * .04, h * .5), Offset(w * .96, h * .5), line);
    canvas.drawCircle(Offset(w * .5, h * .5), w * .14, line);
    canvas.drawCircle(Offset(w * .5, h * .5), 3.5, fill);
    canvas.drawRect(Rect.fromLTRB(w * .20, h * .01, w * .80, h * .20), line);
    canvas.drawRect(Rect.fromLTRB(w * .20, h * .80, w * .80, h * .99), line);
    canvas.drawRect(Rect.fromLTRB(w * .35, h * .01, w * .65, h * .09), line);
    canvas.drawRect(Rect.fromLTRB(w * .35, h * .91, w * .65, h * .99), line);
    canvas.drawRect(
      Rect.fromLTRB(w * .42, h * .00, w * .58, h * .01),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTRB(w * .42, h * .99, w * .58, h * 1.0),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.drawCircle(Offset(w * .5, h * .14), 3, fill);
    canvas.drawCircle(Offset(w * .5, h * .86), 3, fill);
    _drawCornerArc(canvas, Offset(w * .04, h * .01), line);
    _drawCornerArc(canvas, Offset(w * .96, h * .01), line);
    _drawCornerArc(canvas, Offset(w * .04, h * .99), line);
    _drawCornerArc(canvas, Offset(w * .96, h * .99), line);
  }

  void _drawCornerArc(Canvas canvas, Offset corner, Paint paint) {
    canvas.drawArc(
      Rect.fromCenter(center: corner, width: 20, height: 20),
      0, 6.28, false, paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// â”€â”€ Legend â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1),
    ]);
  }
}
