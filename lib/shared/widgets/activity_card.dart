import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

/// Activity entry card for displaying logged activities.
class ActivityCard extends StatelessWidget {
  final String title;
  final String type;
  final int durationMinutes;
  final String difficulty;
  final List<String> skillTags;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final int animationIndex;

  const ActivityCard({
    super.key,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.difficulty,
    required this.skillTags,
    required this.createdAt,
    this.onTap,
    this.animationIndex = 0,
  });

  IconData get _typeIcon {
    switch (type.toLowerCase()) {
      case 'tutorial':
        return Icons.play_circle_outline;
      case 'course':
        return Icons.school_outlined;
      case 'project':
        return Icons.code;
      case 'practice':
        return Icons.fitness_center;
      case 'reading':
        return Icons.menu_book;
      case 'video':
        return Icons.videocam_outlined;
      default:
        return Icons.bolt;
    }
  }

  Color get _difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_typeIcon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      '${durationMinutes}min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: _difficultyColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (skillTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skillTags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Time ago
          Text(
            _timeAgo,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: animationIndex * 60),
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: animationIndex * 60),
          curve: Curves.easeOut,
        );
  }
}
