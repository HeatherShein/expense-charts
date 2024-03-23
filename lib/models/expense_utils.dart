import 'package:collection/collection.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ExpenseUtils {
  static Color getColorForCategory(String category) {
    /**
     * Picks a color corresponding to an expense category.
     * TODO: provide a color picker in settings.
     */
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
      case 'leisure':
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

  static List<Map<String, dynamic>> getExpenseDistributed(DateTime startDate, DateTime endDate, List<Map<String, dynamic>> expenses) {
    /**
     * Distributes expenses over their own period for each day.
     * 
     * Out : {
     *  'date': DateTime,
     *  'category': String,
     *  'value': double
     * }
     */
    List<Map<String, dynamic>> distributedExpenses = [];
    for (var expense in expenses) {
      final DateTime expenseStartDate = DateTime.parse(expense['startDate']);
      final DateTime expenseEndDate = DateTime.parse(expense['endDate']);
      // Compute difference of days
      final int duration = expenseEndDate.difference(expenseStartDate).inDays;
      if(duration > 0) {
        // More than one day, need to distribute over the period
        for (var j = 0; j < duration; j++) {
          // Check that we don't exceed the macro end date
          DateTime expenseDayDate = expenseStartDate.add(Duration(days: j));
          if (endDate.difference(expenseDayDate).inDays < 0) {
            break;
          } 
          distributedExpenses.add({
            'date': expenseDayDate,
            'category': expense['category'] as String,
            'value': expense['value']/(duration) as double,
          });
        }
      } else {
        distributedExpenses.add({
          'date': expenseStartDate,
          'category': expense['category'],
          'value': expense['value']
        });
      }
    }
    return distributedExpenses;
  }

  static Future<List<ExpenseGroup>> getExpenseGroups(String entryType, String aggregateType, DateTime startDate, DateTime endDate) async {
    /**
     * Compute expense groups based on an aggregateType.
     */
    final DatabaseHelper dbhelper = DatabaseHelper();
    // Query the relevant data
    List<Map<String, dynamic>> expensesOverPeriod = await dbhelper.getExpenseOverPeriod(entryType, startDate, endDate);
    // Distribute each expense
    List<Map<String, dynamic>> distributedExpenses = getExpenseDistributed(startDate, endDate, expensesOverPeriod);
    // Define correct formattedDate based on the aggregateType
    switch (aggregateType) {
      case 'year':
        // Format date
        for (var i = 0; i < distributedExpenses.length; i++) {
          distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}";
        }
        break;
      case 'month':
        // Compute month
        for (var i = 0; i < distributedExpenses.length; i++) {
          // Format date
          distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}-${distributedExpenses[i]['date'].month.toString().padLeft(2, '0')}";
        }
        break;
      case 'week':
        // Compute week number
        for (var i = 0; i < distributedExpenses.length; i++) {
          DateTime expenseDate = distributedExpenses[i]['date'];
          DateTime startOfYear = DateTime(expenseDate.year, 1, 1);
          distributedExpenses[i]['weekNumber'] = (expenseDate.difference(startOfYear).inDays / 7).ceil() + 1;
          // Format date
          distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}-${distributedExpenses[i]['weekNumber'].toString().padLeft(2, '0')}";
        }
        break;
      case 'day':
        // Format date
        for (var i = 0; i < distributedExpenses.length; i++) {
          distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}-${distributedExpenses[i]['date'].month.toString().padLeft(2, '0')}-${distributedExpenses[i]['date'].day.toString().padLeft(2, '0')}";
        }
        break;
      default:
        // Format date
        for (var i = 0; i < distributedExpenses.length; i++) {
          distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}-${distributedExpenses[i]['date'].month.toString().padLeft(2, '0')}-${distributedExpenses[i]['date'].day.toString().padLeft(2, '0')}";
        }
        break;
    }
    // Group expenses
    var expensesGrouped = groupBy(distributedExpenses, (Map map) => "${map['formattedDate']}-${map['category']}");
    // Aggregate values per group (sum of values)
    List<Map<String, dynamic>> expensesAggregated = [];
    expensesGrouped.forEach((key, grouped) { 
      double totalValue = 0.0;
      for (var map in grouped) {
        totalValue += map['value'];
      }
      expensesAggregated.add({
        'formattedDate': grouped[0]['formattedDate'],
        'category': grouped[0]['category'],
        'totalValue': totalValue
      });
    });
    return List.generate(expensesAggregated.length, (i) {
      return ExpenseGroup(
        groupAggregate: expensesAggregated[i]['formattedDate'] as String,
        category: expensesAggregated[i]['category'] as String,
        aggregatedValue: expensesAggregated[i]['totalValue'] as double
      );
    });
  }

  static Map<String, List<double>> getTotalPerCategory(List<ExpenseGroup> expenseGroups) {
    /**
     * Regroups every expense per category of an ExpenseGroup list.
     */
    Map<String, List<double>> totalPerCategory = {};
    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!totalPerCategory.containsKey(expenseGroup.category)) {
        totalPerCategory[expenseGroup.category] = [];
      }
      totalPerCategory[expenseGroup.category]!.add(expenseGroup.aggregatedValue);
    }
    // Add empty categories
    for (String category in ["alcohol", "exceptional", "grocery", "health", "leisure", "regular", "restaurant", "trip"]) {
      if (!totalPerCategory.containsKey(category)) {
        totalPerCategory[category] = [0];
      }
    }
    return totalPerCategory;
  }

}