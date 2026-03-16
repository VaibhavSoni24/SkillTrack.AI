import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/skill_chart.dart';

// ── Provider ──

final skillsProvider =
    FutureProvider.autoDispose<SkillsPageData>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get(ApiEndpoints.userSkills);
    final list = res.data as List<dynamic>? ?? [];
    return SkillsPageData(
      skills: list.map((e) {
        final m = e as Map<String, dynamic>;
        return SkillData(
          name: m['name'] ?? '',
          score: m['score'] ?? 0,
          category: m['category'],
        );
      }).toList(),
    );
  } catch (_) {
    return SkillsPageData(skills: []);
  }
});

class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(skillsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(skillsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 0,
                ),
                child: const SectionHeader(title: 'Skill Analytics')
                    .animate()
                    .fadeIn(duration: 300.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Radar Chart ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skill Radar',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      data.when(
                        data: (d) => SkillChart(skills: d.skills),
                        loading: () => const SizedBox(
                          height: 280,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const SkillChart(skills: []),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Bar Chart ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score Breakdown',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      data.when(
                        data: (d) => SkillBarChart(skills: d.skills),
                        loading: () => const SizedBox(
                          height: 250,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const SkillBarChart(skills: []),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Category Breakdown ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const SectionHeader(title: 'By Category'),
              ),
            ),

            data.when(
              data: (d) {
                final categories = <String, List<SkillData>>{};
                for (final s in d.skills) {
                  final cat = s.category ?? 'Other';
                  categories.putIfAbsent(cat, () => []).add(s);
                }

                if (categories.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SkeletonParagraph(lines: 2),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = categories.entries.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                                const SizedBox(height: 12),
                                ...entry.value.map((s) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${s.score}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ).animate().fadeIn(
                                delay: Duration(
                                    milliseconds: 100 + index * 60),
                                duration: 400.ms,
                              ),
                        );
                      },
                      childCount: categories.length,
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
                    childCount: 3,
                  ),
                ),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Data Model ──

class SkillsPageData {
  final List<SkillData> skills;
  const SkillsPageData({required this.skills});
}
