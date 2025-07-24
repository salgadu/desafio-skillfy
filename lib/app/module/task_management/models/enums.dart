enum TaskPriority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.low:
        return 'Baixa';
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.inProgress:
        return 'Em Progresso';
      case TaskStatus.completed:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }
}

enum CategoryChipSize { small, medium, large }
