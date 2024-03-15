import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePiePage extends StatefulWidget {
  const ExpensePiePage({super.key});

  @override
  State<ExpensePiePage> createState() => _ExpensePiePageState();
}

class _ExpensePiePageState extends State<ExpensePiePage> {
  String entryType = 'expense';
  String aggregateType = 'month';
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ExpenseUtils.getExpenseGroups(entryType, aggregateType, startDate, endDate), 
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
          List<Indicator> indicators = ExpenseUtils.getLegend(totalPerCategory.keys.toList());
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