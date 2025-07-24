class SuggestedTime {
  final DateTime start;
  final DateTime end;
  final double score;

  SuggestedTime({required this.start, required this.end, required this.score});

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'score': score,
    };
  }

  factory SuggestedTime.fromJson(Map<String, dynamic> json) {
    return SuggestedTime(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      score: (json['score'] as num).toDouble(),
    );
  }
}

class TaskSuggestion {
  final String id;
  final String taskId;
  final List<SuggestedTime> suggestedTimes;

  TaskSuggestion({
    required this.id,
    required this.taskId,
    required this.suggestedTimes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'suggested_times': suggestedTimes.map((e) => e.toJson()).toList(),
    };
  }

  factory TaskSuggestion.fromJson(Map<String, dynamic> json) {
    return TaskSuggestion(
      id: json['id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      suggestedTimes:
          (json['suggested_times'] as List<dynamic>?)
              ?.map((e) => SuggestedTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
