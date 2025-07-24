import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';

class WorkingHours {
  final String start;
  final String end;

  WorkingHours({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      start: json['start'] ?? '09:00',
      end: json['end'] ?? '18:00',
    );
  }
}

class UserPreferences {
  final WorkingHours workingHours;
  final List<String> preferredCategories;

  UserPreferences({
    required this.workingHours,
    this.preferredCategories = const ['work', 'personal'],
  });

  Map<String, dynamic> toJson() {
    return {
      'working_hours': workingHours.toJson(),
      'preferred_categories': preferredCategories,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      workingHours: WorkingHours.fromJson(
        json['working_hours'] as Map<String, dynamic>? ?? {},
      ),
      preferredCategories:
          (json['preferred_categories'] as List<dynamic>?)?.cast<String>() ??
          ['work', 'personal'],
    );
  }
}

class SuggestTimeRequest {
  final Task task;
  final UserPreferences userPreferences;

  SuggestTimeRequest({required this.task, required this.userPreferences});

  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'user_preferences': userPreferences.toJson(),
    };
  }

  factory SuggestTimeRequest.fromJson(Map<String, dynamic> json) {
    return SuggestTimeRequest(
      task: Task.fromJson(json['task'] as Map<String, dynamic>? ?? {}),
      userPreferences: UserPreferences.fromJson(
        json['user_preferences'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
