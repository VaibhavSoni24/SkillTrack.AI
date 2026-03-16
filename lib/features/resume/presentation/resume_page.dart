import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/section_header.dart';

class ResumePage extends ConsumerStatefulWidget {
  const ResumePage({super.key});

  @override
  ConsumerState<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends ConsumerState<ResumePage> {
  bool _isGenerating = false;
  String? _downloadUrl;

  Future<void> _generateResume() async {
    setState(() => _isGenerating = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.post(ApiEndpoints.generateResume);
      final url = res.data['download_url'] as String?;
      setState(() => _downloadUrl = url);

      ref.read(analyticsProvider).trackResumeGenerated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate resume: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 24, 0,
              ),
              child: const SectionHeader(title: 'Resume Generator')
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI-Powered Resume',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Generate a professional resume from your skills, projects, and activities. Powered by AI and rendered as a beautiful PDF.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Features list
                    _FeatureItem(
                      icon: Icons.insights,
                      title: 'Skill Scores',
                      description: 'Your verified skill levels included',
                    ),
                    _FeatureItem(
                      icon: Icons.code,
                      title: 'Projects',
                      description: 'Highlighted project portfolio',
                    ),
                    _FeatureItem(
                      icon: Icons.bolt,
                      title: 'Activity Summary',
                      description: 'Learning history and consistency',
                    ),
                    _FeatureItem(
                      icon: Icons.auto_awesome,
                      title: 'AI Enhanced',
                      description: 'Smart formatting and descriptions',
                    ),

                    const SizedBox(height: 28),

                    // Generate button
                    GradientButton(
                      text: _isGenerating ? 'Generating...' : 'Generate Resume',
                      icon: Icons.auto_awesome,
                      isLoading: _isGenerating,
                      onPressed: _isGenerating ? null : _generateResume,
                      width: double.infinity,
                    ),

                    if (_downloadUrl != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(_downloadUrl!)),
                        icon: const Icon(Icons.download),
                        label: const Text('Download PDF'),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(
                    begin: 0.04,
                    end: 0,
                    duration: 500.ms,
                  ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
