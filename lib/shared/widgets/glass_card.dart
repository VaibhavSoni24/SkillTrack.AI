import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Frosted glass card with blur backdrop and gradient border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = AppConstants.glassBorderRadius,
    this.blur = AppConstants.glassBlur,
    this.opacity = AppConstants.glassOpacity,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppConstants.animNormal),
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: opacity),
                            Colors.white.withValues(alpha: opacity * 0.5),
                          ]
                        : [
                            AppColors.lightCard.withValues(alpha: 0.8),
                            AppColors.lightCard.withValues(alpha: 0.5),
                          ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorder
                    : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
