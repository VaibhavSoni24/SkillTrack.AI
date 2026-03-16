import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable animation presets for SkillTrack.AI.
class AppAnimations {
  const AppAnimations._();

  /// Fade-in-up entrance for list items.
  static List<Effect> fadeInUp({int delayMs = 0}) => [
    FadeEffect(
      duration: 500.ms,
      delay: Duration(milliseconds: delayMs),
      curve: Curves.easeOut,
    ),
    SlideEffect(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
      duration: 500.ms,
      delay: Duration(milliseconds: delayMs),
      curve: Curves.easeOut,
    ),
  ];

  /// Scale-in entrance for cards.
  static List<Effect> scaleIn({int delayMs = 0}) => [
    FadeEffect(
      duration: 400.ms,
      delay: Duration(milliseconds: delayMs),
    ),
    ScaleEffect(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 400.ms,
      delay: Duration(milliseconds: delayMs),
      curve: Curves.easeOut,
    ),
  ];

  /// Shimmer effect for loading states.
  static List<Effect> shimmer() => [
    ShimmerEffect(
      duration: 1500.ms,
      color: Colors.white.withValues(alpha: 0.15),
    ),
  ];

  /// Subtle pulse for attention.
  static List<Effect> pulse() => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 800.ms,
      curve: Curves.easeInOut,
    ),
  ];

  /// Staggered list item delay calculator.
  static int staggerDelay(int index, {int baseMs = 60}) {
    return index * baseMs;
  }
}
