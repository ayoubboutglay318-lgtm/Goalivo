import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(5, (i) => _SkeletonCard(anim: _anim, isDark: isDark)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.anim, required this.isDark});
  final Animation<double> anim;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) {
        final alpha = 0.05 + anim.value * 0.07;
        final color = isDark
            ? Colors.white.withValues(alpha: alpha)
            : Colors.black.withValues(alpha: alpha);
        final base = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              // League row skeleton
              Row(children: [
                Container(width: 15, height: 15, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 6),
                Container(width: 120, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
                const Spacer(),
                Container(width: 44, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
              ]),
              const SizedBox(height: 18),
              // Teams + score row
              Row(children: [
                Expanded(child: Column(children: [
                  Container(width: 52, height: 52, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(height: 8),
                  Container(width: 64, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
                ])),
                Container(
                  width: 70, height: 38,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                ),
                Expanded(child: Column(children: [
                  Container(width: 52, height: 52, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(height: 8),
                  Container(width: 64, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
                ])),
              ]),
            ],
          ),
        );
      },
    );
  }
}
