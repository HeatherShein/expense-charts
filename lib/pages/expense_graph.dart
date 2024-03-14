import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  final DatabaseHelper dbhelper = DatabaseHelper();
  String entryType = 'expense';
  String aggregateType = 'month';
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime.now();


  Future<List<ExpenseGroup>> getExpenseGroups(String entryType, String aggregateType, DateTime startDate, DateTime endDate) async {
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


  List<BarChartGroupData> getBarGroups(List<ExpenseGroup> expenseGroups) {
    Map<String, List<ExpenseGroup>> groupedByAggregate = {};

    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!groupedByAggregate.containsKey(expenseGroup.groupAggregate)) {
        groupedByAggregate[expenseGroup.groupAggregate] = [];
      }
      groupedByAggregate[expenseGroup.groupAggregate]!.add(expenseGroup);
    }

    List<String> sortedKeys = groupedByAggregate.keys.toList()..sort();

    return List.generate(sortedKeys.length, (i) {
      var groupAggregate = sortedKeys[i];
      var groupAggregateValues = groupedByAggregate[groupAggregate];

      List<BarChartRodData> barRods = [];
      double totalValue = 0.0;

      for (var values in groupAggregateValues!) {
        double aggregatedValue = double.parse(values.aggregatedValue.toStringAsFixed(2));
        barRods.add(
          BarChartRodData(
            fromY: totalValue,
            toY: totalValue + aggregatedValue,
            color: ExpenseUtils.getColorForCategory(values.category),
            width: 8,
          ),
        );
        totalValue += aggregatedValue;
      }

      return BarChartGroupData(
        x: i,
        barRods: barRods,
        groupVertically: true
      );
    });
  }

  FlTitlesData getTitles(List<ExpenseGroup> expenseGroups) {
    Map<String, List<ExpenseGroup>> groupedByAggregate = {};

    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!groupedByAggregate.containsKey(expenseGroup.groupAggregate)) {
        groupedByAggregate[expenseGroup.groupAggregate] = [];
      }
    }

    List<String> sortedKeys = groupedByAggregate.keys.toList()..sort();
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
        axisNameWidget: Text("Amount (€)"),
        sideTitles: SideTitles(showTitles: false)
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Text(aggregateType),
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < sortedKeys.length) {
              return Text(sortedKeys[index]);
            } else {
              return const Text('');
            }
          },
        )
      ),
    );
  }

  List<PieChartSectionData> getSections(Map<String, List<double>> totalPerCategory) {
    return totalPerCategory.keys.map((category) {
      double total = totalPerCategory[category]!.reduce((value, element) => value + element);
      total = double.parse(total.toStringAsFixed(2));
      return PieChartSectionData(
        value: total,
        color: ExpenseUtils.getColorForCategory(category),
      );
    }).toList();
  }

  List<Indicator> getLegend(List<String> categories) {
    return List.generate(categories.length, (index) {
      return Indicator(
        color: ExpenseUtils.getColorForCategory(categories[index]), 
        text: categories[index], 
        isSquare: true
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getExpenseGroups(entryType, aggregateType, startDate, endDate), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          List<ExpenseGroup>? expenseGroups = snapshot.data;
          Map<String, List<double>> totalPerCategory = {};

          for (ExpenseGroup expenseGroup in expenseGroups!) {
            if (!totalPerCategory.containsKey(expenseGroup.category)) {
              totalPerCategory[expenseGroup.category] = [];
            }
            totalPerCategory[expenseGroup.category]!.add(expenseGroup.aggregatedValue);
          }
          List<Indicator> indicators = getLegend(totalPerCategory.keys.toList());
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expenses'),
              actions: [
                DropdownButton<String>(
                  value: entryType,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'expense',
                      child: Text('Expense')
                    ),
                    DropdownMenuItem<String>(
                      value: 'income',
                      child: Text('Income')
                    ),
                  ], 
                  onChanged: (String? value) {
                    setState(() {
                      entryType = value!;
                    });
                  }
                ),
                DropdownButton<String>(
                  value: aggregateType,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'year',
                      child: Text('Yearly')
                    ),
                    DropdownMenuItem<String>(
                      value: 'month',
                      child: Text('Monthly')
                    ),
                    DropdownMenuItem<String>(
                      value: 'week',
                      child: Text('Weekly')
                    ),
                    DropdownMenuItem<String>(
                      value: 'day',
                      child: Text('Daily')
                    ),
                  ], 
                  onChanged: (String? value) {
                    setState(() {
                      aggregateType = value!;
                    });
                  }
                ),
                Text(DateFormat('yyyy-MM-dd').format(startDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? newStartDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(DateTime.now().year, 12, 31),
                        helpText: 'Select a start date'
                    );
                    if (newStartDate != null) {
                      setState(() {  
                        startDate = newStartDate;
                      });
                    }
                  },
                ),
                Text(DateFormat('yyyy-MM-dd').format(endDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? newEndDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(DateTime.now().year, 12, 31),
                        helpText: 'Select an end date'
                      );
                    if (newEndDate != null) {
                      setState(() {  
                        endDate = newEndDate;
                      });
                    }
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 16,),
                          const Text(
                            "Expenses per period",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          const SizedBox(height: 16,),
                          Flexible(
                            child: BarChart(
                              BarChartData(
                                barGroups: getBarGroups(expenseGroups),
                                borderData: FlBorderData(
                                  show: true
                                ),
                                gridData: const FlGridData(
                                  show: true,
                                ),
                                titlesData: getTitles(expenseGroups),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          const Text(
                            "Total expenses",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          const SizedBox(height: 16,),
                          Flexible(
                            child: PieChart(
                              PieChartData(
                                sections: getSections(totalPerCategory),
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                borderData: FlBorderData()
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: indicators
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
    );
  }
}