import 'package:flutter/material.dart';

class ProductivityChart extends StatelessWidget {
  final Map<String, int> weeklyData;

  const ProductivityChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxValue = weeklyData.values.isEmpty
        ? 1
        : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarefas Concluídas por Dia',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weeklyData.entries.map((entry) {
              final dayName = entry.key;
              final value = entry.value;
              final height = maxValue > 0 ? (value / maxValue) * 150 : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (value > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            value.toString(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        height: height.clamp(4.0, 150.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayName,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(context, colorScheme),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme colorScheme) {
    final totalCompleted = weeklyData.values.fold(
      0,
      (sum, value) => sum + value,
    );
    final averagePerDay = weeklyData.isNotEmpty
        ? (totalCompleted / weeklyData.length).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            context,
            'Total da Semana',
            totalCompleted.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildLegendItem(
            context,
            'Média por Dia',
            averagePerDay,
            Icons.timeline,
            colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
