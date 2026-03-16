import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Dynamic blur container for background sections.
class BlurContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const BlurContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.color,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color ??
                  (isDark
                      ? AppColors.glassOverlayDark
                      : AppColors.glassOverlayLight),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorder
                    : Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
