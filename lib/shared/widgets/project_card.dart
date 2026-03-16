import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

/// Project showcase card with cover image and tech stack chips.
class ProjectCard extends StatefulWidget {
  final String title;
  final String? description;
  final List<String> techStack;
  final String? coverImageUrl;
  final String? githubUrl;
  final VoidCallback? onTap;
  final int animationIndex;

  const ProjectCard({
    super.key,
    required this.title,
    this.description,
    required this.techStack,
    this.coverImageUrl,
    this.githubUrl,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: GlassCard(
          onTap: widget.onTap,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: widget.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.darkElevated,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: AppColors.textTertiaryDark,
                                size: 40,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.githubUrl != null)
                          Icon(
                            Icons.link,
                            size: 18,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                      ],
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.techStack.take(5).map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15),
                                AppColors.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            tech,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: widget.animationIndex * 80),
        )
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: Duration(milliseconds: widget.animationIndex * 80),
          curve: Curves.easeOut,
        );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.code,
          color: AppColors.primary,
          size: 48,
        ),
      ),
    );
  }
}
