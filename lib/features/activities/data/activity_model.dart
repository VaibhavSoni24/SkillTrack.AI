/// Activity model matching the database schema.
class ActivityModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final int duration;
  final String difficulty;
  final List<String> skillTags;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.skillTags,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'other',
      title: json['title'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'medium',
      skillTags: List<String>.from(json['skill_tags'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'duration': duration,
        'difficulty': difficulty,
        'skill_tags': skillTags,
      };
}
