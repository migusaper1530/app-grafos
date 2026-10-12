import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Luz ambiental y retícula discretas, sin interceptar gestos del lienzo.
class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({
    super.key,
    required this.child,
    this.accent = AppColors.primary,
    this.showGrid = true,
  });

  final Widget child;
  final Color accent;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                gradient: RadialGradient(
                  center: const Alignment(-0.9, -0.8),
                  radius: 1.3,
                  colors: [
                    Color.alphaBlend(
                      accent.withValues(alpha: 0.12),
                      AppColors.background,
                    ),
                    AppColors.background,
                  ],
                ),
              ),
              child: showGrid
                  ? CustomPaint(painter: _GridPainter(accent))
                  : const SizedBox.expand(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class FuturisticPanel extends StatelessWidget {
  const FuturisticPanel({
    super.key,
    required this.child,
    this.accent = AppColors.primary,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accent.withValues(alpha: 0.10), AppColors.surface),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.055)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.accent != accent;
}
