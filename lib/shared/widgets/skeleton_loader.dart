import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Shimmer skeleton loader for loading states.
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius = 8,
    this.margin,
  });

  /// Card-shaped skeleton.
  const SkeletonLoader.card({
    super.key,
    this.width,
    this.height = 160,
    this.borderRadius = 20,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  /// Circle-shaped skeleton for avatars.
  factory SkeletonLoader.circle({
    double size = 48,
    EdgeInsetsGeometry? margin,
  }) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : Colors.grey.shade300,
      highlightColor:
          isDark ? AppColors.darkElevated : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Multi-line skeleton for text loading.
class SkeletonParagraph extends StatelessWidget {
  final int lines;
  final double spacing;

  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: SkeletonLoader(
            width: isLast ? 150 : double.infinity,
            height: 14,
          ),
        );
      }),
    );
  }
}
