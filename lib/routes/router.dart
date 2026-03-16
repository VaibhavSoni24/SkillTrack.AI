import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/activities/presentation/activities_page.dart';
import '../features/activities/presentation/log_activity_page.dart';
import '../features/skills/presentation/skills_page.dart';
import '../features/projects/presentation/projects_page.dart';
import '../features/projects/presentation/add_project_page.dart';
import '../features/portfolio/presentation/portfolio_page.dart';
import '../features/resume/presentation/resume_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/profile/presentation/public_profile_page.dart';
import '../shared/widgets/responsive_scaffold.dart';

/// Application route paths.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/';
  static const String activities = '/activities';
  static const String logActivity = '/activities/new';
  static const String skills = '/skills';
  static const String projects = '/projects';
  static const String addProject = '/projects/new';
  static const String portfolio = '/portfolio';
  static const String resume = '/resume';
  static const String settings = '/settings';
  static const String publicProfile = '/u/:username';
}

/// Shell route key for the main scaffold.
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      final isPublicProfile =
          state.matchedLocation.startsWith('/u/');

      // Allow public profile without auth
      if (isPublicProfile) return null;

      // Not authenticated → go to login
      if (!isAuth && !isAuthRoute) return AppRoutes.login;

      // Authenticated but on auth page → go to dashboard
      if (isAuth && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      // ── Auth Routes (no shell) ──
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.publicProfile,
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return PublicProfilePage(username: username);
        },
      ),

      // ── Main App Shell ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ResponsiveScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.activities,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ActivitiesPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.logActivity,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LogActivityPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.skills,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SkillsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProjectsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.addProject,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AddProjectPage(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.portfolio,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PortfolioPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.resume,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ResumePage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

// ── Page Transitions ──

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(position: animation.drive(tween), child: child);
}
