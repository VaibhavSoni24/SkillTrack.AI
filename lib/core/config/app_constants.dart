/// Application-wide constants for SkillTrack.AI.
class AppConstants {
  const AppConstants._();

  // App Info
  static const String appName = 'SkillTrack.AI';
  static const String appTagline = 'AI-Powered Skill Tracking & Portfolio';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';

  // Animation Durations (ms)
  static const int animFast = 200;
  static const int animNormal = 350;
  static const int animSlow = 600;
  static const int animPageTransition = 400;

  // Layout
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double maxContentWidth = 1400;
  static const double sideNavWidth = 260;

  // Glass Effect
  static const double glassBlur = 20.0;
  static const double glassOpacity = 0.15;
  static const double glassBorderRadius = 20.0;

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxFileSizeBytes = 10485760; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Skill Score
  static const int maxSkillScore = 100;
  static const List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
    'Master',
  ];
}
