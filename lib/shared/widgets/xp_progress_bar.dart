import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Animated XP progress bar with gradient fill and level label.
class XPProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentXP;
  final int maxXP;
  final String? label;
  final double height;
  final Gradient? gradient;

  const XPProgressBar({
    super.key,
    required this.progress,
    required this.currentXP,
    required this.maxXP,
    this.label,
    this.height = 12,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '$currentXP / $maxXP XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            // Background track
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Filled portion
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: gradient ?? AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated fractionally sized box.
class AnimatedFractionallySizedBox extends StatelessWidget {
  final Duration duration;
  final Curve curve;
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.duration,
    required this.curve,
    required this.widthFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0, end: widthFactor),
      builder: (context, value, _) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: child,
        );
      },
    );
  }
}
