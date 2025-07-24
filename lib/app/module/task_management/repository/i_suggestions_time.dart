import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';

abstract class ISuggestionsTime {
  Future<List<TaskSuggestion>> getSuggestions();
  Future<TaskSuggestion?> getSuggestionByTaskId(String taskId);
  Future<TaskSuggestion> requestTimeSuggestion(SuggestTimeRequest request);
}
