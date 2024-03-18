import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ExpenseUtils {
  static Color getColorForCategory(String category) {
    Color outColor = Vx.black;
    switch (category) {
      case 'grocery':
        outColor = Vx.yellow400;
        break;
      case 'regular':
        outColor = Vx.blue400;
        break;
      case 'restaurant':
        outColor = Vx.orange400;
        break;
      case 'pleasure':
        outColor = Vx.purple400;
        break;
      case 'trip':
        outColor = Vx.pink400;
        break;
      case 'exceptional':
        outColor = Vx.amber400;
        break;
      case 'health':
        outColor = Vx.teal400;
        break;
      case 'alcohol':
        outColor = Vx.red400;
        break;
      default:
        outColor = Vx.black;
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
    categories.sort();
    return List.generate(categories.length, (index) {
      return Indicator(
        color: ExpenseUtils.getColorForCategory(categories[index]), 
        text: categories[index], 
        isSquare: true
      );
    });
  }

  static Map<String, List<double>> getTotalPerCategory(List<ExpenseGroup> expenseGroups) {
    Map<String, List<double>> totalPerCategory = {};

    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!totalPerCategory.containsKey(expenseGroup.category)) {
        totalPerCategory[expenseGroup.category] = [];
      }
      totalPerCategory[expenseGroup.category]!.add(expenseGroup.aggregatedValue);
    }
    // Add empty categories
    for (String category in ["alcohol", "exceptional", "grocery", "health", "pleasure", "regular", "restaurant", "trip"]) {
      if (!totalPerCategory.containsKey(category)) {
        totalPerCategory[category] = [0];
      }
    }
    return totalPerCategory;
  }
}