import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/time_display.dart';
import 'package:flutter/material.dart';

class TimeSuggestions extends StatelessWidget {
  final List<SuggestedTime> suggestions;
  final Function(SuggestedTime)? onSuggestionSelected;

  const TimeSuggestions({
    super.key,
    required this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma sugestão de horário disponível.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        //   child: Text(
        //     'Sugestões de Horário:',
        //     style: Theme.of(
        //       context,
        //     ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        //   ),
        // ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
              child: ListTile(
                onTap: () => onSuggestionSelected?.call(suggestion),
                leading: const Icon(Icons.lightbulb_outline),
                title: TimeDisplay(
                  dateTime: suggestion.start,
                  showDate: true,
                  showDuration:
                      false, // Assuming duration isn't part of SuggestedTime directly
                ),
                subtitle: Text(
                  'Score de recomendação: ${suggestion.score.toStringAsFixed(2)}', //
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        ),
      ],
    );
  }
}
