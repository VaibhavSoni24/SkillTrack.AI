/// Project model matching the database schema.
class ProjectModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String> techStack;
  final String? githubUrl;
  final String? coverImage;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.techStack,
    this.githubUrl,
    this.coverImage,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      techStack: List<String>.from(json['tech_stack'] ?? []),
      githubUrl: json['github_url'] as String?,
      coverImage: json['cover_image'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tech_stack': techStack,
        'github_url': githubUrl,
      };
}
