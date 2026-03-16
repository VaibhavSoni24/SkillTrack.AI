/// Centralized API endpoint paths.
class ApiEndpoints {
  const ApiEndpoints._();

  // ── Auth ──
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String oauthGithub = '/auth/github';
  static const String oauthGoogle = '/auth/google';
  static const String oauthLinkedin = '/auth/linkedin';
  static const String oauthCallback = '/auth/callback';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ── User ──
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static String publicProfile(String username) => '/users/$username';

  // ── Skills ──
  static const String skills = '/skills';
  static const String userSkills = '/users/me/skills';
  static String skillDetail(String id) => '/skills/$id';

  // ── Activities ──
  static const String activities = '/activities';
  static String activityDetail(String id) => '/activities/$id';

  // ── Projects ──
  static const String projects = '/projects';
  static String projectDetail(String id) => '/projects/$id';
  static const String uploadProjectImage = '/projects/upload';

  // ── Portfolio ──
  static const String portfolio = '/portfolio';
  static const String portfolioExport = '/portfolio/export';

  // ── Resume ──
  static const String generateResume = '/resume/generate';
  static const String resumeDownload = '/resume/download';

  // ── Dashboard ──
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardStreak = '/dashboard/streak';
  static const String dashboardRecentActivity = '/dashboard/recent';

  // ── GitHub ──
  static const String githubSync = '/github/sync';
  static const String githubStats = '/github/stats';

  // ── Subscription ──
  static const String subscriptionCheckout = '/subscription/checkout';
  static const String subscriptionStatus = '/subscription/status';
  static const String subscriptionCancel = '/subscription/cancel';

  // ── File Upload ──
  static const String upload = '/upload';
}
