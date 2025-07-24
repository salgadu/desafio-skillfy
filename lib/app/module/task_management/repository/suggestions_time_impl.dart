import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/core/constants/routes_api.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_suggestions_time.dart';

class SuggestionsTimeImpl implements ISuggestionsTime {
  final IHttpClient _httpClient;

  SuggestionsTimeImpl(this._httpClient);

  @override
  Future<List<TaskSuggestion>> getSuggestions() async {
    try {
      final response = await _httpClient.get(RoutesApi.suggestions);

      if (response.isSuccess) {
        final List<dynamic> suggestionsJson = response.data as List<dynamic>;
        return suggestionsJson
            .map(
              (json) => TaskSuggestion.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(response.message ?? 'Erro ao buscar sugestões');
      }
    } catch (e) {
      throw Exception('Falha ao carregar sugestões: ${e.toString()}');
    }
  }

  @override
  Future<TaskSuggestion?> getSuggestionByTaskId(String taskId) async {
    try {
      final suggestions = await getSuggestions();
      return suggestions.firstWhere(
        (suggestion) => suggestion.taskId == taskId,
        orElse: () => throw Exception('Sugestão não encontrada'),
      );
    } on Exception {
      return null;
    } catch (e) {
      throw Exception('Falha ao buscar sugestão por tarefa: ${e.toString()}');
    }
  }

  @override
  Future<TaskSuggestion> requestTimeSuggestion(
    SuggestTimeRequest request,
  ) async {
    try {
      final response = await _httpClient.post(
        RoutesApi.suggestTime,
        data: request.toJson(),
      );

      if (response.isSuccess) {
        return TaskSuggestion.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Erro ao solicitar sugestão');
      }
    } catch (e) {
      throw Exception(
        'Falha ao solicitar sugestão de horário: ${e.toString()}',
      );
    }
  }
}
