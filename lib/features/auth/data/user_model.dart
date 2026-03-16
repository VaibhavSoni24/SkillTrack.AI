/// User model matching the database schema.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? primaryProvider;
  final bool publicProfile;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.primaryProvider,
    this.publicProfile = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      primaryProvider: json['primary_provider'] as String?,
      publicProfile: json['public_profile'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'primary_provider': primaryProvider,
      'public_profile': publicProfile,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    String? primaryProvider,
    bool? publicProfile,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      publicProfile: publicProfile ?? this.publicProfile,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
