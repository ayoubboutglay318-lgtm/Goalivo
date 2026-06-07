import 'dart:math' as math;

import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minRadius = 0.0,
    this.maxRadius = 50.0,
  });

  final Widget child;
  final Duration duration;
  final double minRadius;
  final double maxRadius;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: widget.minRadius,
      end: widget.maxRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => Container(
            width: _animation.value * 2,
            height: _animation.value * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyan.withValues(
                  alpha: 1.0 - (_animation.value / widget.maxRadius),
                ),
                width: 2,
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, 1),
          tileMode: TileMode.clamp,
          stops: [
            _controller.value - 0.3,
            _controller.value,
            _controller.value + 0.3,
          ],
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
          ],
        ).createShader(bounds),
        child: widget.child,
      ),
    );
  }
}

class ConfettiParticle extends StatefulWidget {
  const ConfettiParticle({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.count = 30,
  });

  final Duration duration;
  final int count;

  @override
  State<ConfettiParticle> createState() => _ConfettiParticleState();
}

class _ConfettiParticleState extends State<ConfettiParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();

    particles = List.generate(
      widget.count,
      (index) => _Particle(index, widget.count),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => particles = []);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        children: particles
            .map((p) => Transform.translate(
              offset: p.getOffset(_controller.value),
              child: Opacity(
                opacity: 1.0 - _controller.value,
                child: Icon(
                  Icons.star,
                  size: 12,
                  color: p.color,
                ),
              ),
            ))
            .toList(),
      ),
    );
  }
}

class _Particle {
  _Particle(this.index, this.total) {
    final angle = (index / total) * 2 * 3.141592653589793;
    final speed = 70.0 + (index % 5) * 12;
    velocityX = math.cos(angle) * speed;
    velocityY = math.sin(angle) * speed - 80;
    color = [
      Colors.cyan.shade300,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.red.shade400,
    ][index % 5];
  }

  final int index;
  final int total;
  late double velocityX;
  late double velocityY;
  late Color color;

  Offset getOffset(double progress) {
    const gravity = 100.0;

    double x = velocityX * progress;
    double y = velocityY * progress + 0.5 * gravity * progress * progress;

    return Offset(x, y);
  }
}
