import 'package:flutter/material.dart';

import '../services/xp_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.xpService});
  final XpService xpService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Color _levelColor(int lvl) => switch (lvl) {
    1 => Colors.green.shade500,
    2 => Colors.teal.shade500,
    3 => Colors.orange.shade500,
    4 => Colors.purple.shade400,
    5 => Colors.red.shade500,
    _ => Colors.amber.shade500,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.xpService,
      builder: (context, _) {
        if (!widget.xpService.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final level = widget.xpService.currentLevel;
        final progress = widget.xpService.levelProgress;
        final xpToNext = widget.xpService.xpToNextLevel;
        final isMaxLevel = level.maxXp == -1;
        final levelColor = _levelColor(level.level);

        return CustomScrollView(
          slivers: [
            _ProfileHeroSliver(
              level: level,
              xp: widget.xpService.xp,
              levelColor: levelColor,
              glowCtrl: _glowCtrl,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _XpProgressCard(
                      xp: widget.xpService.xp,
                      level: level,
                      progress: progress,
                      xpToNext: xpToNext,
                      isMaxLevel: isMaxLevel,
                      levelColor: levelColor,
                    ),
                    const SizedBox(height: 14),
                    _StatsRow(
                      streak: widget.xpService.streak,
                      matchViews: widget.xpService.matchViews,
                    ),
                    const SizedBox(height: 26),
                    _SectionTitle(
                      title: 'Achievements',
                      count: widget.xpService.earnedAchievements.length,
                      total: Achievement.all.length,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _AchievementsGrid(xpService: widget.xpService),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }
}

// ── Hero sliver ────────────────────────────────────────────────────────────────

class _ProfileHeroSliver extends StatelessWidget {
  const _ProfileHeroSliver({
    required this.level,
    required this.xp,
    required this.levelColor,
    required this.glowCtrl,
  });
  final XpLevel level;
  final int xp;
  final Color levelColor;
  final AnimationController glowCtrl;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 256,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _HeroBg(
          level: level,
          xp: xp,
          levelColor: levelColor,
          glowCtrl: glowCtrl,
        ),
        title: Text(
          level.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}

class _HeroBg extends StatelessWidget {
  const _HeroBg({
    required this.level,
    required this.xp,
    required this.levelColor,
    required this.glowCtrl,
  });
  final XpLevel level;
  final int xp;
  final Color levelColor;
  final AnimationController glowCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withValues(alpha: 0.30),
            levelColor.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Animated glow ring + badge
            AnimatedBuilder(
              animation: glowCtrl,
              builder: (context, child) {
                final glow = 0.25 + 0.75 * glowCtrl.value;
                return Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withValues(alpha: glow * 0.65),
                        blurRadius: 36,
                        spreadRadius: glow * 6,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      levelColor.withValues(alpha: 0.75),
                      levelColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.5),
                    width: 2.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(level.emoji, style: const TextStyle(fontSize: 36)),
                    Text(
                      'LVL ${level.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$xp XP total',
              style: TextStyle(
                color: levelColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level.title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── XP progress card ──────────────────────────────────────────────────────────

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard({
    required this.xp,
    required this.level,
    required this.progress,
    required this.xpToNext,
    required this.isMaxLevel,
    required this.levelColor,
  });
  final int xp;
  final XpLevel level;
  final double progress;
  final int xpToNext;
  final bool isMaxLevel;
  final Color levelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$xp',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: levelColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'XP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: levelColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (isMaxLevel)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      '👑 MAX',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Text(
                    '$xpToNext XP to go',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _AnimatedXpBar(progress: progress, color: levelColor),
            if (!isMaxLevel) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LevelPip(level: level.level, color: levelColor),
                  _LevelPip(level: level.level + 1, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LevelPip extends StatelessWidget {
  const _LevelPip({required this.level, required this.color});
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    'Level $level',
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
  );
}

class _AnimatedXpBar extends StatelessWidget {
  const _AnimatedXpBar({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 12,
              width: w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              height: 12,
              width: w * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.6), color],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.streak,
    required this.matchViews,
  });
  final int streak;
  final int matchViews;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(emoji: '🔥', value: '$streak', label: 'Day streak', color: Colors.orange.shade400)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(emoji: '📺', value: '$matchViews', label: 'Matches', color: Colors.blue.shade400)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Achievements ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count, required this.total});
  final String title;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count / $total',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.xpService});
  final XpService xpService;

  @override
  Widget build(BuildContext context) {
    final achievements = Achievement.all;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.0,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          final earned = xpService.hasAchievement(a.id);
          return _AchievementTile(achievement: a, earned: earned);
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.earned});
  final Achievement achievement;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: earned
              ? Colors.amber.withValues(alpha: 0.45)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
          width: earned ? 1.5 : 1,
        ),
        gradient: earned
            ? LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.10),
                  Colors.amber.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: earned ? null : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _BadgeCircle(achievement: achievement, earned: earned),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: earned
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: earned ? 0.85 : 0.35,
                    ),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (earned && achievement.xpReward > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCircle extends StatelessWidget {
  const _BadgeCircle({required this.achievement, required this.earned});
  final Achievement achievement;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned
            ? Colors.amber.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: earned
              ? Colors.amber.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        earned ? achievement.emoji : '🔒',
        style: TextStyle(
          fontSize: 20,
          color: earned ? null : Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

// ── XP Toast ──────────────────────────────────────────────────────────────────

class XpToast extends StatefulWidget {
  const XpToast({
    super.key,
    required this.xpGained,
    required this.newBadges,
    required this.onDismiss,
  });
  final int xpGained;
  final List<Achievement> newBadges;
  final VoidCallback onDismiss;

  static void show(
    BuildContext context, {
    required int xpGained,
    required List<Achievement> newBadges,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XpToastOverlay(
        xpGained: xpGained,
        newBadges: newBadges,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<XpToast> createState() => _XpToastState();
}

class _XpToastState extends State<XpToast> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _XpToastOverlay extends StatefulWidget {
  const _XpToastOverlay({
    required this.xpGained,
    required this.newBadges,
    required this.onDismiss,
  });
  final int xpGained;
  final List<Achievement> newBadges;
  final VoidCallback onDismiss;

  @override
  State<_XpToastOverlay> createState() => _XpToastOverlayState();
}

class _XpToastOverlayState extends State<_XpToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                _XpGainedBanner(xpGained: widget.xpGained),
                ...widget.newBadges.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _BadgeBanner(badge: b),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _XpGainedBanner extends StatelessWidget {
  const _XpGainedBanner({required this.xpGained});
  final int xpGained;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.45), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '+$xpGained XP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeBanner extends StatelessWidget {
  const _BadgeBanner({required this.badge});
  final Achievement badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.amber.shade800,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.amber.withValues(alpha: 0.45), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achievement unlocked!',
                style: TextStyle(
                  color: Colors.amber.shade100,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                badge.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
