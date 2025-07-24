import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String category;
  final int estimatedDuration;
  final DateTime deadline;
  final TaskStatus status;
  final DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.priority,
    required this.category,
    required this.estimatedDuration,
    required this.deadline,
    this.status = TaskStatus.pending,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'category': category,
      'estimated_duration': estimatedDuration,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? '').toLowerCase(),
        orElse: () => TaskPriority.medium,
      ),
      category: json['category'] ?? '',
      estimatedDuration: json['estimated_duration'] ?? 0,
      deadline: DateTime.parse(
        json['deadline'] ?? DateTime.now().toIso8601String(),
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? '').toLowerCase(),
        orElse: () => TaskStatus.pending,
      ),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    String? category,
    int? estimatedDuration,
    DateTime? deadline,
    TaskStatus? status,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
