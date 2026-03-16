import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';

class LogActivityPage extends ConsumerStatefulWidget {
  const LogActivityPage({super.key});

  @override
  ConsumerState<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends ConsumerState<LogActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  String _type = 'tutorial';
  int _duration = 30;
  String _difficulty = 'medium';
  final List<String> _skillTags = [];
  bool _isSubmitting = false;

  static const _types = [
    'tutorial',
    'course',
    'project',
    'practice',
    'reading',
    'video',
    'other',
  ];

  static const _difficulties = ['easy', 'medium', 'hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiClientProvider);
      await api.post(ApiEndpoints.activities, data: {
        'title': _titleController.text.trim(),
        'type': _type,
        'duration': _duration,
        'difficulty': _difficulty,
        'skill_tags': _skillTags,
      });

      ref.read(analyticsProvider).trackActivityLogged(
            type: _type,
            duration: _duration,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_skillTags.contains(tag)) {
      setState(() {
        _skillTags.add(tag);
        _tagController.clear();
      });
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
                24, MediaQuery.of(context).padding.top + 16, 24, 0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log Activity',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'What did you learn?',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Type dropdown
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _types
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t[0].toUpperCase() +
                                      t.substring(1)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      const SizedBox(height: 20),

                      // Duration slider
                      Text(
                        'Duration: $_duration minutes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: _duration.toDouble(),
                        min: 5,
                        max: 480,
                        divisions: 95,
                        activeColor: AppColors.primary,
                        label: '$_duration min',
                        onChanged: (v) =>
                            setState(() => _duration = v.round()),
                      ),
                      const SizedBox(height: 16),

                      // Difficulty
                      Text(
                        'Difficulty',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _difficulties.map((d) {
                          final isSelected = d == _difficulty;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(d[0].toUpperCase() + d.substring(1)),
                                selected: isSelected,
                                onSelected: (_) =>
                                    setState(() => _difficulty = d),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Skill tags
                      TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'Skill Tags',
                          prefixIcon: const Icon(Icons.tag),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTag,
                          ),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                      if (_skillTags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skillTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(
                                  () => _skillTags.remove(tag)),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Submit
                      GradientButton(
                        text: 'Log Activity',
                        icon: Icons.check,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}
