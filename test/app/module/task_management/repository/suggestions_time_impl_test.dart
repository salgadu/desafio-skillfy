import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/core/constants/routes_api.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/suggestions_time_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'suggestions_time_impl_test.mocks.dart';

@GenerateMocks([IHttpClient])
void main() {
  late SuggestionsTimeImpl suggestionsTimeImpl;
  late MockIHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockIHttpClient();
    suggestionsTimeImpl = SuggestionsTimeImpl(mockHttpClient);
  });

  group('SuggestionsTimeImpl Tests', () {
    // Test getSuggestions
    group('getSuggestions', () {
      test(
        'returns list of TaskSuggestions on successful API response',
        () async {
          // Arrange
          final suggestionsJson = [
            {
              'id': 's1',
              'task_id': 't1',
              'suggested_times': [
                {
                  'startTime': '2025-07-25T10:00:00Z',
                  'endTime': '2025-07-25T11:00:00Z',
                },
              ],
            },
            {
              'id': 's2',
              'task_id': 't2',
              'suggested_times': [
                {
                  'startTime': '2025-07-25T14:00:00Z',
                  'endTime': '2025-07-25T15:00:00Z',
                },
              ],
            },
          ];
          when(mockHttpClient.get(RoutesApi.suggestions)).thenAnswer(
            (_) async => HttpResponse.success(suggestionsJson, statusCode: 200),
          );

          // Act
          final result = await suggestionsTimeImpl.getSuggestions();

          // Assert
          expect(result, isA<List<TaskSuggestion>>());
          expect(result.length, 2);
          expect(result[0].id, 's1');
          expect(result[0].taskId, 't1');
          expect(result[0].suggestedTimes.length, 1);
          expect(result[1].id, 's2');
          expect(result[1].taskId, 't2');
          expect(result[1].suggestedTimes.length, 1);
          verify(mockHttpClient.get(RoutesApi.suggestions)).called(1);
          verifyNoMoreInteractions(mockHttpClient);
        },
      );

      test('throws exception on API error', () async {
        // Arrange
        when(mockHttpClient.get(RoutesApi.suggestions)).thenAnswer(
          (_) async => HttpResponse.error(
            'Failed to fetch suggestions',
            statusCode: 500,
          ),
        );

        // Act & Assert
        expect(
          () => suggestionsTimeImpl.getSuggestions(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Falha ao carregar sugestões'),
            ),
          ),
        );
        verify(mockHttpClient.get(RoutesApi.suggestions)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });
    });

    // Test getSuggestionByTaskId
    group('getSuggestionByTaskId', () {
      test('returns TaskSuggestion when found', () async {
        // Arrange
        final suggestionsJson = [
          {
            'id': 's1',
            'task_id': 't1',
            'suggested_times': [
              {
                'startTime': '2025-07-25T10:00:00Z',
                'endTime': '2025-07-25T11:00:00Z',
              },
            ],
          },
        ];
        when(mockHttpClient.get(RoutesApi.suggestions)).thenAnswer(
          (_) async => HttpResponse.success(suggestionsJson, statusCode: 200),
        );

        // Act
        final result = await suggestionsTimeImpl.getSuggestionByTaskId('t1');

        // Assert
        expect(result, isA<TaskSuggestion>());
        expect(result!.id, 's1');
        expect(result.taskId, 't1');
        expect(result.suggestedTimes.length, 1);
        verify(mockHttpClient.get(RoutesApi.suggestions)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });

      test('returns null when suggestion not found', () async {
        // Arrange
        final suggestionsJson = [
          {
            'id': 's1',
            'task_id': 't1',
            'suggested_times': [
              {
                'startTime': '2025-07-25T10:00:00Z',
                'endTime': '2025-07-25T11:00:00Z',
              },
            ],
          },
        ];
        when(mockHttpClient.get(RoutesApi.suggestions)).thenAnswer(
          (_) async => HttpResponse.success(suggestionsJson, statusCode: 200),
        );

        // Act
        final result = await suggestionsTimeImpl.getSuggestionByTaskId('t2');

        // Assert
        expect(result, isNull);
        verify(mockHttpClient.get(RoutesApi.suggestions)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });

      test('returns null on API error', () async {
        // Arrange
        when(mockHttpClient.get(RoutesApi.suggestions)).thenAnswer(
          (_) async => HttpResponse.error(
            'Failed to fetch suggestions',
            statusCode: 500,
          ),
        );

        // Act
        final result = await suggestionsTimeImpl.getSuggestionByTaskId('t1');

        // Assert
        expect(result, isNull);
        verify(mockHttpClient.get(RoutesApi.suggestions)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });
    });

    // Test requestTimeSuggestion
    group('requestTimeSuggestion', () {
      test('returns TaskSuggestion on successful API response', () async {
        // Arrange
        final request = SuggestTimeRequest(
          task: Task(
            id: 't1',
            title: 'Test Task',
            priority: TaskPriority.medium,
            category: 'Work',
            estimatedDuration: 60,
            deadline: DateTime.now(),
          ),
          userPreferences: UserPreferences(
            workingHours: WorkingHours(start: '09:00', end: '18:00'),
          ),
        );
        final suggestionJson = {
          'id': 's1',
          'task_id': 't1',
          'suggested_times': [
            {
              'startTime': '2025-07-25T10:00:00Z',
              'endTime': '2025-07-25T11:00:00Z',
            },
          ],
        };
        when(
          mockHttpClient.post(RoutesApi.suggestTime, data: anyNamed('data')),
        ).thenAnswer((_) async => HttpResponse.success(suggestionJson));

        // Act
        final result = await suggestionsTimeImpl.requestTimeSuggestion(request);

        // Assert
        expect(result, isA<TaskSuggestion>());
        expect(result.id, 's1');
        expect(result.taskId, 't1');
        expect(result.suggestedTimes.length, 1);
        verify(
          mockHttpClient.post(RoutesApi.suggestTime, data: anyNamed('data')),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });

      test('throws exception on API error', () async {
        // Arrange
        final request = SuggestTimeRequest(
          task: Task(
            id: 't1',
            title: 'Test Task',
            priority: TaskPriority.medium,
            category: 'Work',
            estimatedDuration: 60,
            deadline: DateTime.now(),
          ),
          userPreferences: UserPreferences(
            workingHours: WorkingHours(start: '09:00', end: '18:00'),
          ),
        );
        when(
          mockHttpClient.post(RoutesApi.suggestTime, data: anyNamed('data')),
        ).thenAnswer(
          (_) async =>
              HttpResponse.error('Failed to suggest time', statusCode: 500),
        );

        // Act & Assert
        expect(
          () => suggestionsTimeImpl.requestTimeSuggestion(request),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Falha ao solicitar sugestão de horário'),
            ),
          ),
        );
        verify(
          mockHttpClient.post(RoutesApi.suggestTime, data: anyNamed('data')),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });
    });
  });
}
