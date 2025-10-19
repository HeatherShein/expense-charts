import 'package:expenses_charts/constants/categories.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting expense data to CSV format
class CsvFormatter {
  /// Format a list of expense maps to CSV format
  /// 
  /// This replicates the logic from scripts/data_process.py
  static List<Map<String, dynamic>> formatExpensesForCsv(List<Map<String, dynamic>> expenses) {
    return expenses.map((expense) {
      return {
        'Date': _formatDate(expense['millisSinceEpochStart']),
        'Intitulé': expense['label'] ?? '',
        'Montant': expense['value']?.toString() ?? '0',
        'Type': ExpenseCategories.getCsvName(expense['category'] ?? ''),
        'Revenu/Dépense': _formatType(expense['type']),
      };
    }).toList();
  }

  /// Convert milliseconds since epoch to MM/DD/YYYY format
  static String _formatDate(dynamic millisSinceEpoch) {
    if (millisSinceEpoch == null) return '';
    
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        millisSinceEpoch is int ? millisSinceEpoch : int.parse(millisSinceEpoch.toString())
      );
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  /// Convert expense type to numeric format
  /// expense -> -1, income -> 1
  static String _formatType(String? type) {
    switch (type) {
      case 'expense':
        return '-1';
      case 'income':
        return '1';
      default:
        return '0';
    }
  }

  /// Convert CSV data to CSV string format
  static String toCsvString(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    // Get headers from first row
    final headers = data.first.keys.toList();
    
    // Create CSV content
    final buffer = StringBuffer();
    
    // Add headers
    buffer.writeln(headers.join(','));
    
    // Add data rows
    for (final row in data) {
      final values = headers.map((header) => _escapeCsvValue(row[header]?.toString() ?? '')).toList();
      buffer.writeln(values.join(','));
    }
    
    return buffer.toString();
  }

  /// Escape CSV values that contain commas or quotes
  static String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
