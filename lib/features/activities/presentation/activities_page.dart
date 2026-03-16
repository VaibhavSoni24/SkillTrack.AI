import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../routes/router.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/activity_model.dart';

// ── Provider ──
final activitiesProvider =
    FutureProvider.autoDispose<List<ActivityModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get(ApiEndpoints.activities);
    final list = res.data as List<dynamic>? ?? [];
    return list
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activitiesProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 0,
                ),
                child: SectionHeader(
                  title: 'Activities',
                  actionLabel: '+ Log New',
                  onAction: () => context.go(AppRoutes.logActivity),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            activities.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No activities logged yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start logging your learning to track progress',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'Log Activity',
                            icon: Icons.add,
                            onPressed: () =>
                                context.go(AppRoutes.logActivity),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActivityCard(
                            title: a.title,
                            type: a.type,
                            durationMinutes: a.duration,
                            difficulty: a.difficulty,
                            skillTags: a.skillTags,
                            createdAt: a.createdAt,
                            animationIndex: index,
                          ),
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonLoader.card(),
                    ),
                    childCount: 5,
                  ),
                ),
              ),
              error: (_, __) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load activities',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
