import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/project_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skill_chart.dart';


// ── Provider ──

final publicProfileProvider =
    FutureProvider.autoDispose.family<PublicProfileData, String>(
  (ref, username) async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.get(ApiEndpoints.publicProfile(username));
      return PublicProfileData.fromJson(res.data);
    } catch (_) {
      return PublicProfileData.empty(username);
    }
  },
);

class PublicProfilePage extends ConsumerWidget {
  final String username;

  const PublicProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(publicProfileProvider(username));

    return Scaffold(
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Profile not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        data: (data) => CustomScrollView(
          slivers: [
            // ── Hero Header ──
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 40, 24, 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      backgroundImage: data.avatarUrl != null
                          ? NetworkImage(data.avatarUrl!)
                          : null,
                      child: data.avatarUrl == null
                          ? Text(
                              data.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.username,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (data.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        data.email!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],

                    const SizedBox(height: 20),
                    // Quick stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QuickStat(
                          value: '${data.skillCount}',
                          label: 'Skills',
                        ),
                        const SizedBox(width: 32),
                        _QuickStat(
                          value: '${data.projectCount}',
                          label: 'Projects',
                        ),
                        const SizedBox(width: 32),
                        _QuickStat(
                          value: '${data.streak}',
                          label: 'Day Streak',
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),

            // ── Skills ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const SectionHeader(title: 'Skills'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  child: SkillBarChart(skills: data.skills),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Projects ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const SectionHeader(title: 'Projects'),
              ),
            ),
            if (data.projects.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    child: Center(
                      child: Text(
                        'No projects yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = data.projects[index];
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
                    childCount: data.projects.length,
                  ),
                ),
              ),

            // ── GitHub Stats ──
            if (data.githubUsername != null) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const SectionHeader(title: 'GitHub'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.code, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          '@${data.githubUsername}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;

  const _QuickStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ── Data Model ──

class PublicProfileData {
  final String username;
  final String? email;
  final String? avatarUrl;
  final int skillCount;
  final int projectCount;
  final int streak;
  final String? githubUsername;
  final List<SkillData> skills;
  final List<PublicProject> projects;

  const PublicProfileData({
    required this.username,
    this.email,
    this.avatarUrl,
    required this.skillCount,
    required this.projectCount,
    required this.streak,
    this.githubUsername,
    required this.skills,
    required this.projects,
  });

  factory PublicProfileData.empty(String username) => PublicProfileData(
        username: username,
        skillCount: 0,
        projectCount: 0,
        streak: 0,
        skills: [],
        projects: [],
      );

  factory PublicProfileData.fromJson(dynamic json) {
    final data = json as Map<String, dynamic>? ?? {};
    return PublicProfileData(
      username: data['username'] ?? '',
      email: data['email'],
      avatarUrl: data['avatar_url'],
      skillCount: data['skill_count'] ?? 0,
      projectCount: data['project_count'] ?? 0,
      streak: data['streak'] ?? 0,
      githubUsername: data['github_username'],
      skills: (data['skills'] as List<dynamic>? ?? [])
          .map((s) => SkillData(
                name: s['name'] ?? '',
                score: s['score'] ?? 0,
              ))
          .toList(),
      projects: (data['projects'] as List<dynamic>? ?? [])
          .map((p) => PublicProject.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PublicProject {
  final String title;
  final String? description;
  final List<String> techStack;
  final String? coverImage;
  final String? githubUrl;

  const PublicProject({
    required this.title,
    this.description,
    required this.techStack,
    this.coverImage,
    this.githubUrl,
  });

  factory PublicProject.fromJson(Map<String, dynamic> json) {
    return PublicProject(
      title: json['title'] ?? '',
      description: json['description'],
      techStack: List<String>.from(json['tech_stack'] ?? []),
      coverImage: json['cover_image'],
      githubUrl: json['github_url'],
    );
  }
}
