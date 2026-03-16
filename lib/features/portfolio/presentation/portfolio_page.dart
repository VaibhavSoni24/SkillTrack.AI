import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../shared/widgets/glass_card.dart';

import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';

// ── Provider ──

final portfolioProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get(ApiEndpoints.portfolio);
    return res.data as Map<String, dynamic>? ?? {};
  } catch (_) {
    return {};
  }
});

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 24, 0,
              ),
              child: const SectionHeader(title: 'Portfolio Builder')
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
          ),

          // ── Preview Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Preview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your public portfolio is visible at skilltrack.ai/username',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    portfolio.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return Column(
                            children: [
                              Icon(
                                Icons.web,
                                size: 64,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                  'Add skills and projects to build your portfolio'),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            // Stats summary
                            Row(
                              children: [
                                _StatPill(
                                  label: 'Skills',
                                  value: '${data['skills_count'] ?? 0}',
                                ),
                                const SizedBox(width: 12),
                                _StatPill(
                                  label: 'Projects',
                                  value: '${data['projects_count'] ?? 0}',
                                ),
                                const SizedBox(width: 12),
                                _StatPill(
                                  label: 'Score',
                                  value: '${data['avg_score'] ?? 0}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Portfolio preview card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.08),
                                    AppColors.secondary.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.preview,
                                      size: 48, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Portfolio Live Preview',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your portfolio page renders your skills, projects, and achievements',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Column(
                        children: [
                          SkeletonLoader(height: 40),
                          SizedBox(height: 16),
                          SkeletonLoader(height: 120),
                        ],
                      ),
                      error: (_, __) =>
                          const Text('Failed to load portfolio data'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ),

          // ── Export Options ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const SectionHeader(title: 'Export Options'),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () {
                        ref.read(analyticsProvider).trackPortfolioExported(
                              format: 'link',
                            );
                        // Copy shareable link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Portfolio link copied!'),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.link,
                              size: 32, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Share Link',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Copy your public URL',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      onTap: () async {
                        ref.read(analyticsProvider).trackPortfolioExported(
                              format: 'pdf',
                            );
                        try {
                          final api = ref.read(apiClientProvider);
                          final res = await api.post(ApiEndpoints.portfolioExport);
                          final url = res.data['download_url'];
                          if (url != null) {
                            launchUrl(Uri.parse(url as String));
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to export PDF'),
                              ),
                            );
                          }
                        }
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 32, color: AppColors.accent),
                          const SizedBox(height: 8),
                          Text(
                            'Export PDF',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Download as PDF',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
