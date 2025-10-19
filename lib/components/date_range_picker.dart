import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable widget for selecting date ranges
class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(DateFormat('yyyy-MM-dd').format(startDate)),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final newStartDate = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year, 12, 31),
              helpText: 'Select a start date',
            );
            if (newStartDate != null) {
              final adjustedStartDate = DateTime(
                newStartDate.year,
                newStartDate.month,
                newStartDate.day,
              );
              onStartDateChanged(adjustedStartDate);
              
              // If the new start date is after the end date, adjust the end date
              if (endDate.isBefore(adjustedStartDate)) {
                onEndDateChanged(DateTime(
                  newStartDate.year,
                  newStartDate.month,
                  newStartDate.day,
                  23,
                  59,
                  59,
                ));
              }
            }
          },
        ),
        Text(DateFormat('yyyy-MM-dd').format(endDate)),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final newEndDate = await showDatePicker(
              context: context,
              initialDate: endDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year, 12, 31),
              helpText: 'Select an end date',
            );
            if (newEndDate != null) {
              onEndDateChanged(DateTime(
                newEndDate.year,
                newEndDate.month,
                newEndDate.day,
                23,
                59,
                59,
              ));
            }
          },
        ),
      ],
    );
  }
}
