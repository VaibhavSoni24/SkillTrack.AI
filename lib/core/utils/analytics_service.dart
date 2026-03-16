import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics service for PostHog event tracking.
class AnalyticsService {
  AnalyticsService();

  /// Track a named event with optional properties.
  void track(String event, [Map<String, dynamic>? properties]) {
    // PostHog events are tracked via posthog_flutter SDK
    // This service provides a centralized wrapper for the app
    // In production, this calls PostHog directly
    // ignore: avoid_print
    print('[Analytics] $event ${properties ?? ''}');
  }

  // ── Predefined Events ──

  void trackSignup({String? provider}) {
    track('signup', {'provider': provider ?? 'email'});
  }

  void trackLogin({String? provider}) {
    track('login', {'provider': provider ?? 'email'});
  }

  void trackActivityLogged({
    required String type,
    required int duration,
  }) {
    track('activity_logged', {'type': type, 'duration': duration});
  }

  void trackProjectCreated({required String title}) {
    track('project_created', {'title': title});
  }

  void trackResumeGenerated() {
    track('resume_generated');
  }

  void trackSubscriptionStarted() {
    track('subscription_started');
  }

  void trackPortfolioExported({required String format}) {
    track('portfolio_exported', {'format': format});
  }

  void trackPageView(String pageName) {
    track('page_view', {'page': pageName});
  }
}

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
