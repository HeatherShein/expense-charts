import 'package:flutter/material.dart';
import 'package:expenses_charts/constants/categories.dart';

/// Reusable widget for selecting expense categories
class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.includeAll = true,
  });

  final String value;
  final ValueChanged<String?> onChanged;
  final bool includeAll;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];
    
    if (includeAll) {
      items.add(
        const DropdownMenuItem<String>(
          value: 'all',
          child: Text('All'),
        ),
      );
    }
    
    for (final category in ExpenseCategories.all) {
      items.add(
        DropdownMenuItem<String>(
          value: category,
          child: Text(ExpenseCategories.getDisplayName(category)),
        ),
      );
    }

    return DropdownButton<String>(
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
