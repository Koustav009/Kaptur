import 'package:flutter/material.dart';

/// Centers [child] and caps its width at [maxWidth] so screens stay
/// readable on wide surfaces (web/desktop) instead of stretching
/// edge-to-edge. Use it as the direct wrapper of a screen's scroll body.
///
/// Rule: every new screen must stay dynamic for all screen sizes —
/// wrap content in this widget and use adaptive layouts
/// (e.g. max-cross-axis-extent grids) instead of fixed mobile-only
/// dimensions.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
