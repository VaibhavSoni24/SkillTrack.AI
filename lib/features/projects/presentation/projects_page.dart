import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/config/app_constants.dart';
import '../../../routes/router.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/project_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/project_model.dart';

// ── Provider ──

final projectsProvider =
    FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get(ApiEndpoints.projects);
    final list = res.data as List<dynamic>? ?? [];
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final isWide = MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(projectsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 0,
                ),
                child: SectionHeader(
                  title: 'Projects',
                  actionLabel: '+ New Project',
                  onAction: () => context.go(AppRoutes.addProject),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            projects.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.code, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No projects yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Showcase your work by adding projects',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'Add Project',
                            icon: Icons.add,
                            onPressed: () => context.go(AppRoutes.addProject),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (isWide) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = list[index];
                          return ProjectCard(
                            title: p.title,
                            description: p.description,
                            techStack: p.techStack,
                            coverImageUrl: p.coverImage,
                            githubUrl: p.githubUrl,
                            animationIndex: index,
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProjectCard(
                            title: p.title,
                            description: p.description,
                            techStack: p.techStack,
                            coverImageUrl: p.coverImage,
                            githubUrl: p.githubUrl,
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
                      padding: EdgeInsets.only(bottom: 16),
                      child: SkeletonLoader.card(),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (_, __) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load projects',
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
