import 'package:flutter/material.dart';

/// Reusable widget for selecting entry type (expense/income)
class EntryTypeDropdown extends StatelessWidget {
  const EntryTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
          value: 'expense',
          child: Text('Expense'),
        ),
        DropdownMenuItem<String>(
          value: 'income',
          child: Text('Income'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
