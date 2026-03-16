import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'user_model.dart';

/// Repository handling all authentication API calls and token persistence.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.signup,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<AuthResponse> oauthLogin({
    required String provider,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.oauthCallback,
      data: {'provider': provider, 'code': code},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'password': password},
    );
  }

  Future<UserModel> updateProfile({
    String? username,
    String? email,
    bool? publicProfile,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (publicProfile != null) 'public_profile': publicProfile,
      },
    );
    return UserModel.fromJson(response.data);
  }

  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.upload(
      ApiEndpoints.uploadAvatar,
      formData: formData,
    );
    return response.data['avatar_url'] as String;
  }

  /// Persist tokens after successful auth.
  Future<void> saveTokens(AuthResponse auth) async {
    await _apiClient.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
  }

  /// Check if user has valid stored tokens.
  Future<bool> hasValidSession() async {
    final token = await _apiClient.getAccessToken();
    return token != null;
  }
}

/// Auth API response model.
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
