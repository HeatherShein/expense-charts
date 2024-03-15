import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:flutter/material.dart';

class ExpenseUtils {
  static Color getColorForCategory(String category) {
    Color outColor = Colors.black;
    switch (category) {
      case 'grocery':
        outColor = Colors.yellow;
        break;
      case 'regular':
        outColor = Colors.blue;
        break;
      case 'restaurant':
        outColor = Colors.orange;
        break;
      case 'pleasure':
        outColor = Colors.purple;
        break;
      case 'trip':
        outColor = Colors.pink;
        break;
      case 'exceptional':
        outColor = Colors.amber;
        break;
      case 'health':
        outColor = Colors.teal;
        break;
      case 'alcohol':
        outColor = Colors.red;
        break;
      default:
        outColor = Colors.black;
    }
    return outColor;
  }

  static Future<List<ExpenseGroup>> getExpenseGroups(String entryType, String aggregateType, DateTime startDate, DateTime endDate) async {
    final DatabaseHelper dbhelper = DatabaseHelper();
    switch (aggregateType) {
      case 'year':
        return await dbhelper.getExpensesPerYear(entryType, startDate, endDate);
      case 'month':
        return await dbhelper.getExpensesPerMonth(entryType, startDate, endDate);
      case 'week':
        return await dbhelper.getExpensesPerWeek(entryType, startDate, endDate);
      case 'day':
        return await dbhelper.getExpensesPerDay(entryType, startDate, endDate);
      default:
        return await dbhelper.getExpensesPerYear(entryType, startDate, endDate);
    }
  }

  static List<Indicator> getLegend(List<String> categories) {
    return List.generate(categories.length, (index) {
      return Indicator(
        color: ExpenseUtils.getColorForCategory(categories[index]), 
        text: categories[index], 
        isSquare: true
      );
    });
  }
}