import 'package:desafio_skillfy/app/module/task_management/ui/widgets/category_chip.dart';
import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String)? onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CategoryChip(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected?.call(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}
