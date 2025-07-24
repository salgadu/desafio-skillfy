import 'package:flutter/material.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;
  final CategoryChipSize size;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    this.onTap,
    this.size = CategoryChipSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryData = _getCategoryData(category);

    // Tamanhos baseados no enum
    double padding, iconSize, fontSize;
    TextStyle? textStyle;

    switch (size) {
      case CategoryChipSize.small:
        padding = 6.0;
        iconSize = 14.0;
        fontSize = 12.0;
        textStyle = Theme.of(context).textTheme.labelSmall;
        break;
      case CategoryChipSize.medium:
        padding = 8.0;
        iconSize = 16.0;
        fontSize = 14.0;
        textStyle = Theme.of(context).textTheme.labelMedium;
        break;
      case CategoryChipSize.large:
        padding = 12.0;
        iconSize = 20.0;
        fontSize = 16.0;
        textStyle = Theme.of(context).textTheme.labelLarge;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: padding + 4,
          vertical: padding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryData.color.withValues(alpha: 0.2)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? categoryData.color : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryData.icon,
              size: iconSize,
              color: isSelected
                  ? categoryData.color
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: padding / 2),
            Text(
              categoryData.displayName,
              style: textStyle?.copyWith(
                color: isSelected
                    ? categoryData.color
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CategoryData _getCategoryData(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return CategoryData(
          displayName: 'Trabalho',
          icon: Icons.work,
          color: Colors.blue,
        );
      case 'personal':
        return CategoryData(
          displayName: 'Pessoal',
          icon: Icons.person,
          color: Colors.green,
        );
      case 'health':
        return CategoryData(
          displayName: 'Saúde',
          icon: Icons.favorite,
          color: Colors.red,
        );
      case 'education':
        return CategoryData(
          displayName: 'Educação',
          icon: Icons.school,
          color: Colors.purple,
        );
      case 'finance':
        return CategoryData(
          displayName: 'Finanças',
          icon: Icons.attach_money,
          color: Colors.orange,
        );
      case 'home':
        return CategoryData(
          displayName: 'Casa',
          icon: Icons.home,
          color: Colors.brown,
        );
      case 'shopping':
        return CategoryData(
          displayName: 'Compras',
          icon: Icons.shopping_cart,
          color: Colors.pink,
        );
      case 'entertainment':
        return CategoryData(
          displayName: 'Entretenimento',
          icon: Icons.movie,
          color: Colors.indigo,
        );
      default:
        return CategoryData(
          displayName:
              category.substring(0, 1).toUpperCase() + category.substring(1),
          icon: Icons.category,
          color: Colors.grey,
        );
    }
  }
}

class CategoryData {
  final String displayName;
  final IconData icon;
  final Color color;

  CategoryData({
    required this.displayName,
    required this.icon,
    required this.color,
  });
}
