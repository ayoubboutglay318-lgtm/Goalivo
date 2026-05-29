import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/goal_alerts_service.dart';
import '../services/xp_service.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.xpService,
    required this.goalAlertsService,
  });
  final XpService xpService;
  final GoalAlertsService goalAlertsService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  static Color _levelColor(int lvl) => switch (lvl) {
    1 => Colors.blue.shade400,
    2 => Colors.teal.shade400,
    3 => Colors.orange.shade400,
    4 => const Color(0xFF9C27B0),
    5 => Colors.red.shade400,
    _ => Colors.amber.shade400,
  };

  int _progressFor(Achievement a) {
    final xp = widget.xpService;
    switch (a.id) {
      case 'first_match': return xp.matchViews.clamp(0, 1);
      case 'match_5': return xp.matchViews.clamp(0, 5);
      case 'match_25': return xp.matchViews.clamp(0, 25);
      case 'streak_3': return xp.streak.clamp(0, 3);
      case 'streak_7': return xp.streak.clamp(0, 7);
      case 'streak_30': return xp.streak.clamp(0, 30);
      case 'level_3': return xp.currentLevel.level.clamp(0, 3);
      case 'level_5': return xp.currentLevel.level.clamp(0, 5);
      case 'favorite_team': return xp.hasAchievement('favorite_team') ? 1 : 0;
      default: return 0;
    }
  }

  static const _categoryOrder = ['Engagement', 'Loyalty', 'Progression', 'Explorer'];
  static const _categoryIcons = {
    'Engagement': 'ðŸ“º',
    'Loyalty': 'ðŸ”¥',
    'Progression': 'ðŸ†',
    'Explorer': 'ðŸ—ºï¸',
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

        // Group achievements by category
        final grouped = <String, List<Achievement>>{};
        for (final cat in _categoryOrder) {
          grouped[cat] = Achievement.all.where((a) => a.category == cat).toList();
        }

        final slivers = <Widget>[
          // â”€â”€ Hero â”€â”€
          _ProfileHeroSliver(
            level: level,
            xp: widget.xpService.xp,
            levelColor: levelColor,
            glowCtrl: _glowCtrl,
            streak: widget.xpService.streak,
            matchViews: widget.xpService.matchViews,
            badgesEarned: widget.xpService.earnedAchievements.length,
          ),
          // â”€â”€ XP card + stats + settings â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                    shimmerCtrl: _shimmerCtrl,
                  ),
                  const SizedBox(height: 12),
                  // Goal alerts
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: Colors.red, size: 18),
                      ),
                      title: const Text('Goal alerts',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Notify me when favourites score',
                          style: TextStyle(fontSize: 11)),
                      trailing: ListenableBuilder(
                        listenable: widget.goalAlertsService,
                        builder: (context, _) => Switch(
                          value: widget.goalAlertsService.enabled,
                          onChanged: (_) async {
                            HapticFeedback.selectionClick();
                            await widget.goalAlertsService.toggleEnabled();
                          },
                          activeThumbColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Daily Missions
                  _DailyMissionsCard(xpService: widget.xpService),
                  const SizedBox(height: 22),
                  // Achievements header
                  _SectionHeader(
                    title: 'Achievements',
                    earned: widget.xpService.earnedAchievements.length,
                    total: Achievement.all.length,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ];

        // â”€â”€ Achievement categories â”€â”€
        for (final cat in _categoryOrder) {
          final items = grouped[cat] ?? [];
          if (items.isEmpty) continue;
          slivers.add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(children: [
                Text(_categoryIcons[cat] ?? '', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(cat.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: Colors.white38, letterSpacing: 1.4)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: Colors.white10)),
              ]),
            ),
          ));
          slivers.add(SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final a = items[i];
                final earned = widget.xpService.hasAchievement(a.id);
                final current = _progressFor(a);
                return _AchievementTile(
                  achievement: a,
                  earned: earned,
                  currentProgress: current,
                );
              },
            ),
          ));
        }

        // â”€â”€ Legal + bottom â”€â”€
        slivers.addAll([
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, size: 20),
                    title: const Text('Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined, size: 20),
                    title: const Text('Terms of Use',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TermsScreen())),
                  ),
                ]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ]);

        return CustomScrollView(slivers: slivers);
      },
    );
  }
}

// â”€â”€ Hero card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProfileHeroSliver extends StatelessWidget {
  const _ProfileHeroSliver({
    required this.level,
    required this.xp,
    required this.levelColor,
    required this.glowCtrl,
    required this.streak,
    required this.matchViews,
    required this.badgesEarned,
  });
  final XpLevel level;
  final int xp;
  final Color levelColor;
  final AnimationController glowCtrl;
  final int streak;
  final int matchViews;
  final int badgesEarned;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              levelColor.withValues(alpha: 0.22),
              levelColor.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: levelColor.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glow avatar
            AnimatedBuilder(
              animation: glowCtrl,
              builder: (context, child) {
                final glow = 0.3 + 0.7 * glowCtrl.value;
                return Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withValues(alpha: glow * 0.6),
                        blurRadius: 24, spreadRadius: glow * 3,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [levelColor.withValues(alpha: 0.75), levelColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(level.emoji, style: const TextStyle(fontSize: 28)),
                  Text('LVL ${level.level}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                ]),
              ),
            ),
            const SizedBox(width: 16),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 3),
                  Text('$xp XP total',
                      style: TextStyle(
                          color: levelColor, fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _MiniStat(icon: 'ðŸ”¥', value: '$streak', label: 'streak'),
                    const SizedBox(width: 16),
                    _MiniStat(icon: 'ðŸ“º', value: '$matchViews', label: 'matches'),
                    const SizedBox(width: 16),
                    _MiniStat(icon: 'ðŸ…', value: '$badgesEarned', label: 'badges'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label});
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
      ]),
      Text(label,
          style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w500)),
    ]);
  }
}

// â”€â”€ XP progress card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard({
    required this.xp,
    required this.level,
    required this.progress,
    required this.xpToNext,
    required this.isMaxLevel,
    required this.levelColor,
    required this.shimmerCtrl,
  });
  final int xp;
  final XpLevel level;
  final double progress;
  final int xpToNext;
  final bool isMaxLevel;
  final Color levelColor;
  final AnimationController shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextLevel = isMaxLevel
        ? null
        : XpLevel.all.firstWhere((l) => l.level == level.level + 1, orElse: () => XpLevel.all.last);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$xp',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900, color: levelColor, height: 1)),
                const SizedBox(width: 4),
                Text('XP',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: levelColor.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
                const Spacer(),
                if (isMaxLevel)
                  _Pill(label: 'ðŸ‘‘ MAX', color: Colors.amber)
                else
                  Text('$xpToNext XP to go',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            _ShimmerXpBar(progress: progress, color: levelColor, shimmerCtrl: shimmerCtrl),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level ${level.level}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: levelColor)),
                if (!isMaxLevel && nextLevel != null)
                  Text('Next: ${nextLevel.emoji} ${nextLevel.title}',
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}

class _ShimmerXpBar extends StatelessWidget {
  const _ShimmerXpBar({required this.progress, required this.color, required this.shimmerCtrl});
  final double progress;
  final Color color;
  final AnimationController shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final filledW = w * progress.clamp(0.0, 1.0);
        return SizedBox(
          height: 10,
          child: Stack(children: [
            // Track
            Container(
              width: w, height: 10,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Milestone ticks at 25 / 50 / 75 %
            for (final frac in [0.25, 0.5, 0.75])
              Positioned(
                left: w * frac - 0.5,
                top: 2, bottom: 2,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.18)),
              ),
            // Filled + shimmer
            AnimatedBuilder(
              animation: shimmerCtrl,
              builder: (_, child) {
                final slide = shimmerCtrl.value * 3 - 1;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: filledW, height: 10,
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(slide - 1, 0),
                        end: Alignment(slide, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.28),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: child,
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                height: 10,
                width: filledW,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.6), color],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 8, spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// â”€â”€ Section header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.earned, required this.total});
  final String title;
  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Text(title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('$earned / $total',
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
      ),
    ]);
  }
}

// â”€â”€ Achievement tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.earned,
    required this.currentProgress,
  });
  final Achievement achievement;
  final bool earned;
  final int currentProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasProgress = !earned && achievement.maxProgress > 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? Colors.amber.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
          width: earned ? 1.5 : 1,
        ),
        gradient: earned
            ? LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.14),
                  Colors.amber.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: earned ? null : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        boxShadow: earned
            ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.12), blurRadius: 12, spreadRadius: 0)]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        // Badge
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: earned
                ? Colors.amber.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: earned
                  ? Colors.amber.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.07),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            earned ? achievement.emoji : 'ðŸ”’',
            style: TextStyle(
              fontSize: 18,
              color: earned ? null : Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(achievement.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: earned
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.32),
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 1),
              Text(achievement.description,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: earned ? 0.75 : 0.3),
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              if (earned && achievement.xpReward > 0) ...[
                const SizedBox(height: 3),
                Text('+${achievement.xpReward} XP',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: Colors.amber)),
              ] else if (hasProgress) ...[
                const SizedBox(height: 4),
                _MicroProgressBar(current: currentProgress, max: achievement.maxProgress),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

class _MicroProgressBar extends StatelessWidget {
  const _MicroProgressBar({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final pct = (current / max).clamp(0.0, 1.0);
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 3,
            child: Stack(children: [
              Container(color: Colors.white10),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 5),
      Text('$current/$max',
          style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w700)),
    ]);
  }
}

// â”€â”€ Daily Missions card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DailyMissionsCard extends StatelessWidget {
  const _DailyMissionsCard({required this.xpService});
  final XpService xpService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const purple = Color(0xFF7C3AED);

    final missions = [
      (
        icon: 'â˜€ï¸',
        label: 'Open the app',
        xp: 20,
        done: true,
      ),
      (
        icon: 'ðŸ“º',
        label: 'View a match',
        xp: 3,
        done: xpService.matchViews > 0,
      ),
      (
        icon: 'ðŸ§ ',
        label: 'Complete the quiz',
        xp: 15,
        done: false,
      ),
    ];

    final doneCount = missions.where((m) => m.done).length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [purple.withValues(alpha: 0.18), purple.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: purple.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('ðŸŽ¯', style: TextStyle(fontSize: 15))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'Daily Missions',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                ),
                Text(
                  '$doneCount / ${missions.length} complete',
                  style: TextStyle(fontSize: 10, color: purple.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                ),
              ]),
            ),
            // Mini progress dots
            Row(children: missions.map((m) => Container(
              width: 8, height: 8, margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: m.done ? purple : Colors.white12,
              ),
            )).toList()),
          ]),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: doneCount / missions.length,
              minHeight: 3,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(purple),
            ),
          ),
          const SizedBox(height: 12),
          // Mission rows
          ...missions.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: m.done ? purple.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: m.done ? purple.withValues(alpha: 0.6) : Colors.white12,
                  ),
                ),
                child: Center(
                  child: m.done
                      ? const Icon(Icons.check, size: 13, color: Color(0xFF7C3AED))
                      : Text(m.icon, style: const TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: m.done
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.85),
                    decoration: m.done ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white24,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: m.done ? Colors.white.withValues(alpha: 0.04) : purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${m.xp} XP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: m.done ? Colors.white24 : const Color(0xFFA78BFA),
                  ),
                ),
              ),
            ]),
          )),
        ],
      ),
    );
  }
}

// â”€â”€ XP Toast â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _badgeCtrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _badgeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _badgeScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut));
    _ctrl.forward();
    if (widget.newBadges.isNotEmpty) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 200), () => _badgeCtrl.forward());
    }
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
    _badgeCtrl.dispose();
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
                ...widget.newBadges.map((b) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ScaleTransition(
                    scale: _badgeScale,
                    child: _BadgeBanner(badge: b),
                  ),
                )),
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
        color: const Color(0xFF4527A0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 16),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('â­', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text('+$xpGained XP',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
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
          BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(badge.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Achievement unlocked!',
              style: TextStyle(color: Colors.amber.shade100, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(badge.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
        ]),
      ]),
    );
  }
}
