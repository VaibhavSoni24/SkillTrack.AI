/// Environment configuration for SkillTrack.AI.
/// Values are injected at compile time via --dart-define.
class EnvConfig {
  const EnvConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.skilltrack.ai',
  );

  static const String appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: 'https://app.skilltrack.ai',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const String posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );

  static const String posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://app.posthog.com',
  );

  static const String githubClientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    defaultValue: '',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String linkedinClientId = String.fromEnvironment(
    'LINKEDIN_CLIENT_ID',
    defaultValue: '',
  );

  static const int maxFileSize = int.fromEnvironment(
    'MAX_FILE_SIZE',
    defaultValue: 10485760, // 10MB
  );

  static bool get isSentryEnabled => sentryDsn.isNotEmpty;
  static bool get isAnalyticsEnabled => posthogApiKey.isNotEmpty;
}
