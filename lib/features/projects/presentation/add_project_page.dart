import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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

class AddProjectPage extends ConsumerStatefulWidget {
  const AddProjectPage({super.key});

  @override
  ConsumerState<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends ConsumerState<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _githubController = TextEditingController();
  final _techController = TextEditingController();
  final List<String> _techStack = [];
  String? _selectedImagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _githubController.dispose();
    _techController.dispose();
    super.dispose();
  }

  void _addTech() {
    final tech = _techController.text.trim();
    if (tech.isNotEmpty && !_techStack.contains(tech)) {
      setState(() {
        _techStack.add(tech);
        _techController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImagePath = result.files.single.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiClientProvider);

      // Upload cover image if selected
      String? coverUrl;
      if (_selectedImagePath != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_selectedImagePath!),
          'folder': 'projects',
        });
        final uploadRes = await api.upload(
          ApiEndpoints.uploadProjectImage,
          formData: formData,
        );
        coverUrl = uploadRes.data['url'];
      }

      await api.post(ApiEndpoints.projects, data: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'tech_stack': _techStack,
        'github_url': _githubController.text.trim().isEmpty
            ? null
            : _githubController.text.trim(),
        'cover_image': coverUrl,
      });

      ref.read(analyticsProvider).trackProjectCreated(
            title: _titleController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created!')),
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
                    'Add Project',
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
                      // Cover image picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1,
                            ),
                          ),
                          child: _selectedImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    _selectedImagePath!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(),
                                  ),
                                )
                              : _imagePlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Project Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // GitHub URL
                      TextFormField(
                        controller: _githubController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub URL',
                          prefixIcon: Icon(Icons.link),
                          hintText: 'https://github.com/...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tech stack
                      TextFormField(
                        controller: _techController,
                        decoration: InputDecoration(
                          labelText: 'Tech Stack',
                          prefixIcon: const Icon(Icons.build_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTech,
                          ),
                        ),
                        onFieldSubmitted: (_) => _addTech(),
                      ),
                      if (_techStack.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _techStack.map((t) {
                            return Chip(
                              label: Text(t),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () =>
                                  setState(() => _techStack.remove(t)),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Submit
                      GradientButton(
                        text: 'Create Project',
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

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Add Cover Image',
          style: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
