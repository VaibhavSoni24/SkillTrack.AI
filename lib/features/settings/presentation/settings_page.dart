import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';

import '../../../features/auth/data/auth_repository.dart';
import '../../../features/auth/providers/auth_provider.dart';

import '../../../shared/widgets/avatar_uploader.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/section_header.dart';

/// Theme mode provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _usernameController;
  bool _publicProfile = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _usernameController = TextEditingController(text: user?.username ?? '');
    _publicProfile = user?.publicProfile ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final updated = await repo.updateProfile(
        username: _usernameController.text.trim(),
        publicProfile: _publicProfile,
      );
      ref.read(authProvider.notifier).updateUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadAvatar(String path) async {
    setState(() => _isUploadingAvatar = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final newUrl = await repo.uploadAvatar(path);
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(authProvider.notifier).updateUser(
              user.copyWith(avatarUrl: newUrl),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload avatar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 24, 0,
              ),
              child: const SectionHeader(title: 'Settings')
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
          ),

          // ── Avatar Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  children: [
                    AvatarUploader(
                      imageUrl: user?.avatarUrl,
                      isLoading: _isUploadingAvatar,
                      onImagePicked: _uploadAvatar,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.username ?? 'Username',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ),

          // ── Profile Settings ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Public Profile'),
                      subtitle: const Text(
                          'Make your portfolio visible at skilltrack.ai/username'),
                      value: _publicProfile,
                      onChanged: (v) => setState(() => _publicProfile = v),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),

                    GradientButton(
                      text: 'Save Changes',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _saveProfile,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Theme Toggle ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ThemeOption(
                          label: 'Dark',
                          icon: Icons.dark_mode,
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.dark,
                        ),
                        const SizedBox(width: 12),
                        _ThemeOption(
                          label: 'Light',
                          icon: Icons.light_mode,
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.light,
                        ),
                        const SizedBox(width: 12),
                        _ThemeOption(
                          label: 'System',
                          icon: Icons.settings_brightness,
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.system,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── OAuth Connections ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Accounts',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _ConnectionTile(
                      icon: Icons.code,
                      name: 'GitHub',
                      connected: user?.primaryProvider == 'github',
                    ),
                    const Divider(),
                    _ConnectionTile(
                      icon: Icons.g_mobiledata,
                      name: 'Google',
                      connected: false,
                    ),
                    const Divider(),
                    _ConnectionTile(
                      icon: Icons.business,
                      name: 'LinkedIn',
                      connected: false,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Logout ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                onTap: () => ref.read(authProvider.notifier).logout(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.primary : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppColors.primary : null,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool connected;

  const _ConnectionTile({
    required this.icon,
    required this.name,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 28),
      title: Text(name),
      trailing: connected
          ? const Chip(
              label: Text('Connected'),
              backgroundColor: AppColors.success,
              labelStyle: TextStyle(color: Colors.white, fontSize: 11),
            )
          : OutlinedButton(
              onPressed: () {},
              child: const Text('Connect'),
            ),
    );
  }
}
