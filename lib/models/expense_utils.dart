import 'package:collection/collection.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
        for (var j = 0; j < duration + 1; j++) {
          // Check that we don't exceed the macro end date
          DateTime expenseDayDate = expenseStartDate.add(Duration(days: j));
          if (expenseDayDate.isAfter(startDate) && expenseDayDate.isBefore((endDate))) {
            distributedExpenses.add({
              'date': expenseDayDate,
              'category': expense['category'] as String,
              'value': expense['value']/(duration+1) as double,
            });
          }
          // Check if this expense exceeds endDate
          if (endDate.difference(expenseDayDate).inDays == 0) {
            break;
          }
        }
      } else {
        if (expenseStartDate.isAfter(startDate) && expenseStartDate.isBefore(endDate)) {
          distributedExpenses.add({
            'date': expenseStartDate,
            'category': expense['category'],
            'value': expense['value']
          });
        }
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

  static Future<Map<String, dynamic>> getExpenseStats(String entryType, String expenseCategory, DateTime startDate, DateTime endDate) async {
    /**
     * Compute expense statistics based on entryType and expenseCategory.
     */
    final DatabaseHelper dbhelper = DatabaseHelper(); 
    // Query the relevant data
    List<Map<String, dynamic>> expensesOverPeriod = await dbhelper.getExpenseOverPeriod(entryType, startDate, endDate);
    // Distribute each expense
    List<Map<String, dynamic>> distributedExpenses = getExpenseDistributed(startDate, endDate, expensesOverPeriod);
    // Filter expenses
    List<Map<String, dynamic>> filteredExpenses;
    if (expenseCategory != "all") {
      filteredExpenses = distributedExpenses.filter((element) => element['category'] == expenseCategory).toList();
    } else {
      filteredExpenses = distributedExpenses;
    }
    // Format date
    for (var i = 0; i < distributedExpenses.length; i++) {
      distributedExpenses[i]['formattedDate'] = "${distributedExpenses[i]['date'].year}-${distributedExpenses[i]['date'].month.toString().padLeft(2, '0')}-${distributedExpenses[i]['date'].day.toString().padLeft(2, '0')}";
    }
    Map<String, dynamic> expenseStats = {
      "genNRows": filteredExpenses.length,
      "genAverage": 0,
      "genMin": double.infinity,
      "genMax": -double.infinity,
      "dailyNRows": 0,
      "dailyAverage": 0,
      "dailyMin": double.infinity,
      "dailyMax": -double.infinity
    };
    // Fill in general stats
    for (var i = 0; i < filteredExpenses.length; i++) {
      expenseStats["genAverage"] += filteredExpenses[i]["value"];
      if (filteredExpenses[i]["value"] < expenseStats["genMin"]) {
        expenseStats["genMin"] = filteredExpenses[i]["value"];
      }
      if (filteredExpenses[i]["value"] > expenseStats["genMax"]) {
        expenseStats["genMax"] = filteredExpenses[i]["value"];
      }
      // Also format date
      filteredExpenses[i]['formattedDate'] = "${filteredExpenses[i]['date'].year}-${filteredExpenses[i]['date'].month.toString().padLeft(2, '0')}-${filteredExpenses[i]['date'].day.toString().padLeft(2, '0')}";
    }
    // Group expenses
    var expensesGrouped = groupBy(filteredExpenses, (Map map) => "${map['formattedDate']}");
    // Aggregate values per group (sum of values)
    List<Map<String, dynamic>> expensesAggregated = [];
    expensesGrouped.forEach((key, grouped) { 
      double totalValue = 0.0;
      for (var map in grouped) {
        totalValue += map['value'];
      }
      expensesAggregated.add({
        'formattedDate': grouped[0]['formattedDate'],
        'totalValue': totalValue
      });
    });
    // Fill in daily stats
    expenseStats["dailyNRows"] = expensesAggregated.length;
    for (var expense in expensesAggregated) {
      expenseStats["dailyAverage"] += expense["totalValue"];
      if (expense["totalValue"] < expenseStats["dailyMin"]) {
        expenseStats["dailyMin"] = expense["totalValue"];
      }
      if (expense["totalValue"] > expenseStats["dailyMax"]) {
        expenseStats["dailyMax"] = expense["totalValue"];
      }
    }
    // Clean stats
    expenseStats["genAverage"] /= expenseStats["genNRows"];
    expenseStats["genMin"] = expenseStats["genMin"] == double.infinity ? -1 : expenseStats["genMin"];
    expenseStats["genMax"] = expenseStats["genMax"] == -double.infinity ? -1 : expenseStats["genMax"];
    expenseStats["dailyAverage"] /= expenseStats["dailyNRows"];
    expenseStats["dailyMin"] = expenseStats["dailyMin"] == double.infinity ? -1 : expenseStats["dailyMin"];
    expenseStats["dailyMax"] = expenseStats["dailyMax"] == -double.infinity ? -1 : expenseStats["dailyMax"];
    return expenseStats;
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

  static Future<void> showExpenseDialog(
    bool isNewExpense,
    BuildContext context,
    SettingsProvider settingsState,
    int millisSinceEpochStart,
    int millisSinceEpochEnd,
    String type,
    String category,
    String label,
    String value,
    String currency,
    bool isLongExpense,
    GlobalKey<FormBuilderState> formKey,
    VoidCallback refreshCallback
  ) async {
    /**
     * Displays a Dialog window to insert/update an expense
     * 
     */
    DatabaseHelper dbhelper = DatabaseHelper();
    int expenseId;
    if (isNewExpense) {
      expenseId = -1;
    } else {
      expenseId = await dbhelper.getIdFromValues(
        millisSinceEpochStart,
        millisSinceEpochEnd, 
        type, 
        category, 
        label, 
        double.parse(value)
      );
    }
    
    showDialog(
      // ignore: use_build_context_synchronously
      context: context, 
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateFunction) {
            return AlertDialog(
              title: Row(
                children: [
                  Text(isNewExpense ? "Create Expense" : "Edit Expense"),
                  const Spacer(),
                  Checkbox(
                    value: isLongExpense, 
                    onChanged: (bool? value) {
                      setStateFunction(() {
                        isLongExpense = value!;
                      });
                    }
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderDateTimePicker(
                        name: "start_date",
                        decoration: const InputDecoration(
                          labelText: "Start date",
                          hintText: "Pick a start date",
                        ),
                        initialValue: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochStart),
                        initialDate: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochStart),
                      ),
                      isLongExpense ? FormBuilderDateTimePicker(
                        name: "end_date",
                        decoration: const InputDecoration(
                          labelText: "End date",
                          hintText: "Pick an end date",
                        ),
                        initialValue: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochEnd),
                        initialDate: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochEnd)
                        ,
                      ) : const SizedBox.shrink(),
                      FormBuilderDropdown(
                        name: "type", 
                        decoration: const InputDecoration(
                          labelText: "Type",
                          hintText: "Select a type",
                        ),
                        initialValue: type,
                        items: const [
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "expense",
                            child: Text("Expense")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "income",
                            child: Text("Income")
                          ),
                        ]
                      ),
                      FormBuilderDropdown(
                        name: "category", 
                        decoration: const InputDecoration(
                          labelText: "Category",
                          hintText: "Select a category",
                        ),
                        initialValue: category,
                        items: const [
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "grocery",
                            child: Text("Grocery")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "regular",
                            child: Text("Regular")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "restaurant",
                            child: Text("Restaurant")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "leisure",
                            child: Text("Leisure")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "trip",
                            child: Text("Trip")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "exceptional",
                            child: Text("Exceptional")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "health",
                            child: Text("Health")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "alcohol",
                            child: Text("Alcohol")
                          ),
                        ]
                      ),
                      FormBuilderTextField(
                        name: "label",
                        decoration: const InputDecoration(
                          labelText: "Label",
                          hintText: 'Write an expense\'s label',
                        ),
                        initialValue: label,
                      ),
                      FormBuilderTextField(
                        name: "value", 
                        decoration: const InputDecoration(
                          labelText: "Value",
                          hintText: 'Write a value',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: value,
                      ),
                      FormBuilderDropdown(
                        name: "currency", 
                        decoration: const InputDecoration(
                          labelText: "Currency",
                          hintText: "Select a currency",
                        ),
                        initialValue: currency,
                        items: const [
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "EUR",
                            child: Text("EUR")
                          ),
                          DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: "JPY",
                            child: Text("JPY")
                          ),
                        ]
                      ),
                      const SizedBox(height: 10.0,),
                      MaterialButton(
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () async {
                          formKey.currentState?.saveAndValidate();
                          var formValues = formKey.currentState?.value;
                
                          var formMillisSinceEpochStart = formValues?['start_date'].millisecondsSinceEpoch;
                          var formEndDate = formValues?['end_date'] ?? formValues?['start_date'];
                          var formMillisSinceEpochEnd = isLongExpense ? formEndDate.millisecondsSinceEpoch : formMillisSinceEpochStart;
                          var formType = formValues?['type'];
                          var formCategory = formValues?['category'];
                          var formLabel = formValues?['label'];
                          var formValue = formValues!['value'].replaceAll(",", ".");
                          var formCurrency = formValues['currency'];
                
                          // Convert currency if needed
                          if (formCurrency != settingsState.currency){
                            // TODO : Update based on live currency rates.
                            formValue = (double.parse(formValue) / 164).toStringAsFixed(2);
                          }
                        
                          var dbhelper = DatabaseHelper();
                
                          // Update expense
                          Expense newExpense = Expense(
                            millisSinceEpochStart: formMillisSinceEpochStart,
                            millisSinceEpochEnd: formMillisSinceEpochEnd, 
                            type: formType, 
                            category: formCategory, 
                            label: formLabel, 
                            value: double.parse(formValue)
                          );
                
                          if (isNewExpense) {
                            dbhelper.insertExpense(
                              newExpense
                            );
                          } else {
                            dbhelper.updateExpense(
                              expenseId,
                              newExpense
                            );
                          }
                          final scaffold = ScaffoldMessenger.of(context);
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text(isNewExpense ? "Expense inserted successfully" : "Expense updated successfully !"),
                            )
                          );
                          refreshCallback();
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          isNewExpense ? "Insert expense" : "Update expense"
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

}