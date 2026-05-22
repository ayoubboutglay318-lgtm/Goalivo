import 'package:flutter/material.dart';

class ModernTabIndicator extends Decoration {
  const ModernTabIndicator({
    this.borderSide = const BorderSide(color: Colors.blue, width: 3),
    this.insets = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(6),
      topRight: Radius.circular(6),
    ),
  });

  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final BorderRadiusGeometry borderRadius;

  @override
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ModernTabIndicatorPainter(
        borderSide: borderSide,
        insets: insets,
        borderRadius: borderRadius,
        onChanged: onChanged,
      );
}

class _ModernTabIndicatorPainter extends BoxPainter {
  _ModernTabIndicatorPainter({
    required this.borderSide,
    required this.insets,
    required this.borderRadius,
    VoidCallback? onChanged,
  }) : super(onChanged);

  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final BorderRadiusGeometry borderRadius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final deflated = insets
        .resolve(TextDirection.ltr)
        .deflateRect(
          Rect.fromLTWH(
            offset.dx,
            offset.dy,
            configuration.size!.width,
            configuration.size!.height,
          ),
        );
    final rect = Rect.fromLTRB(
      deflated.left,
      deflated.top,
      deflated.right,
      offset.dy + configuration.size!.height - borderSide.width,
    );

    final paint = borderSide.toPaint()
      ..shader = LinearGradient(
        colors: [
          borderSide.color.withValues(alpha: 0.5),
          borderSide.color,
          borderSide.color.withValues(alpha: 0.5),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      paint,
    );
  }
}

class GradientTabBar extends StatelessWidget {
  const GradientTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    this.indicatorGradient,
  });

  final TabController controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final Gradient? indicatorGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      indicator: ModernTabIndicator(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 3),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      tabs: tabs,
    );
  }
}
