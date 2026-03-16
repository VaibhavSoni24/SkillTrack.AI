import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routes/router.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/skill_chart.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/xp_progress_bar.dart';

// ── Dashboard Data Provider ──

final dashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final statsRes = await api.get(ApiEndpoints.dashboardStats);
    final streakRes = await api.get(ApiEndpoints.dashboardStreak);
    final recentRes = await api.get(ApiEndpoints.dashboardRecentActivity);
    return DashboardData.fromJson(
      stats: statsRes.data,
      streak: streakRes.data,
      recent: recentRes.data,
    );
  } catch (_) {
    return DashboardData.empty();
  }
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dashData = ref.watch(dashboardProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    final isWide = screenW >= AppConstants.tabletBreakpoint;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            user?.username ?? 'Learner',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.username ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Stats Row ──
            SliverToBoxAdapter(
              child: dashData.when(
                loading: () => _buildStatsLoading(),
                error: (_, __) => _buildStatsEmpty(context),
                data: (data) => _buildStats(context, data, isWide),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── XP Progress ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Progress',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      dashData.when(
                        data: (data) => XPProgressBar(
                          progress: data.totalXP / (data.maxXP == 0 ? 1 : data.maxXP),
                          currentXP: data.totalXP,
                          maxXP: data.maxXP,
                          label: 'Level ${data.level}',
                        ),
                        loading: () => const SkeletonLoader(height: 12),
                        error: (_, __) => const XPProgressBar(
                          progress: 0,
                          currentXP: 0,
                          maxXP: 1000,
                          label: 'Level 1',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Skill Chart Section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Skill Overview',
                        actionLabel: 'View All',
                        onAction: () => context.go(AppRoutes.skills),
                      ),
                      dashData.when(
                        data: (data) => SkillChart(skills: data.topSkills),
                        loading: () =>
                            const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SkillChart(skills: []),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Recent Activity ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'See All',
                  onAction: () => context.go(AppRoutes.activities),
                ),
              ),
            ),

            dashData.when(
              data: (data) {
                if (data.recentActivities.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        child: Column(
                          children: [
                            const Icon(Icons.bolt,
                                size: 48, color: AppColors.textTertiaryDark),
                            const SizedBox(height: 12),
                            Text(
                              'No activities yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  context.go(AppRoutes.logActivity),
                              child: const Text('Log your first activity'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = data.recentActivities[index];
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
                      childCount: data.recentActivities.length,
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
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, DashboardData data, bool isWide) {
    final cards = [
      StatCard(
        label: 'Skill Score',
        value: '${data.skillScore}',
        icon: Icons.insights_rounded,
        gradient: AppColors.primaryGradient,
        subtitle: '+${data.scoreChange}',
      ),
      StatCard(
        label: 'Learning Streak',
        value: '${data.streak} days',
        icon: Icons.local_fire_department_rounded,
        gradient: AppColors.accentGradient,
      ),
      StatCard(
        label: 'Activities',
        value: '${data.totalActivities}',
        icon: Icons.bolt_rounded,
      ),
      StatCard(
        label: 'Projects',
        value: '${data.totalProjects}',
        icon: Icons.code_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: isWide
          ? Row(
              children: cards.map((c) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                );
              }).toList(),
            )
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: cards,
            ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildStatsLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: List.generate(4, (_) => const SkeletonLoader.card()),
      ),
    );
  }

  Widget _buildStatsEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: Center(
          child: Text(
            'Unable to load stats',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Data Model ──

class DashboardData {
  final int skillScore;
  final int scoreChange;
  final int streak;
  final int totalActivities;
  final int totalProjects;
  final int totalXP;
  final int maxXP;
  final int level;
  final List<SkillData> topSkills;
  final List<RecentActivity> recentActivities;

  const DashboardData({
    required this.skillScore,
    required this.scoreChange,
    required this.streak,
    required this.totalActivities,
    required this.totalProjects,
    required this.totalXP,
    required this.maxXP,
    required this.level,
    required this.topSkills,
    required this.recentActivities,
  });

  factory DashboardData.empty() => const DashboardData(
        skillScore: 0,
        scoreChange: 0,
        streak: 0,
        totalActivities: 0,
        totalProjects: 0,
        totalXP: 0,
        maxXP: 1000,
        level: 1,
        topSkills: [],
        recentActivities: [],
      );

  factory DashboardData.fromJson({
    required dynamic stats,
    required dynamic streak,
    required dynamic recent,
  }) {
    final s = stats as Map<String, dynamic>? ?? {};
    final st = streak as Map<String, dynamic>? ?? {};
    final r = recent as List<dynamic>? ?? [];

    return DashboardData(
      skillScore: s['skill_score'] ?? 0,
      scoreChange: s['score_change'] ?? 0,
      streak: st['current_streak'] ?? 0,
      totalActivities: s['total_activities'] ?? 0,
      totalProjects: s['total_projects'] ?? 0,
      totalXP: s['total_xp'] ?? 0,
      maxXP: s['max_xp'] ?? 1000,
      level: s['level'] ?? 1,
      topSkills: (s['top_skills'] as List<dynamic>? ?? [])
          .map((e) => SkillData(
                name: e['name'] ?? '',
                score: e['score'] ?? 0,
              ))
          .toList(),
      recentActivities: r
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentActivity {
  final String title;
  final String type;
  final int duration;
  final String difficulty;
  final List<String> skillTags;
  final DateTime createdAt;

  const RecentActivity({
    required this.title,
    required this.type,
    required this.duration,
    required this.difficulty,
    required this.skillTags,
    required this.createdAt,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json['title'] ?? '',
      type: json['type'] ?? 'other',
      duration: json['duration'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
      skillTags: List<String>.from(json['skill_tags'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
