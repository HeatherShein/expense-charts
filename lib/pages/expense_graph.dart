import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

final _formKey = GlobalKey<FormBuilderState>();

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  String graphTitle = 'Expenses per period';

  List<BarChartGroupData> getBarGroups(List<ExpenseGroup> expenseGroups, {String keyFilter = ''}) {
    Map<String, List<ExpenseGroup>> groupedByAggregate = {};

    // Regroup expenses by group aggregate
    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!groupedByAggregate.containsKey(expenseGroup.groupAggregate)) {
        groupedByAggregate[expenseGroup.groupAggregate] = [];
      }
      // Filter by category
      if (keyFilter == '' || keyFilter == expenseGroup.category) {
        groupedByAggregate[expenseGroup.groupAggregate]!.add(expenseGroup);
      }
    }

    // Sort by aggregate
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

  FlTitlesData getTitles(List<ExpenseGroup> expenseGroups, SettingsProvider settingsState) {
    // Regroup expenses by group aggregate
    Map<String, List<ExpenseGroup>> groupedByAggregate = {};
    for (ExpenseGroup expenseGroup in expenseGroups) {
      if (!groupedByAggregate.containsKey(expenseGroup.groupAggregate)) {
        groupedByAggregate[expenseGroup.groupAggregate] = [];
      }
    }

    // Sort by aggregate
    List<String> sortedKeys = groupedByAggregate.keys.toList()..sort();

    // Define number of maximum dates displayed
    int xtick = (sortedKeys.length / 4).floor() == 0 ? 1 : (sortedKeys.length / 4).floor();
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
        axisNameWidget: Text("Amount (€)"),
        sideTitles: SideTitles(showTitles: false, reservedSize: 44)
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if(value == meta.max && value % 10 != 0) {
              return const Text('');
            }
            return Text(" ${value.toInt()}");
          },
          reservedSize: 44,
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Text(settingsState.aggregateType),
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < sortedKeys.length && index % xtick == 0) {
              if (sortedKeys[index].length < 5) {
                return Text(sortedKeys[index]);
              }
              return Text(sortedKeys[index].substring(5));
            } else {
              return const Text('');
            }
          },
          reservedSize: 30
        )
      ),
    );
  }

  List<Indicator> getLegend(List<String> categories, SettingsProvider settingsState) {
    categories.sort();
    return List.generate(categories.length, (index) {
      return Indicator(
        color: ExpenseUtils.getColorForCategory(categories[index]), 
        text: categories[index], 
        isSquare: true,
        onTap: () {
          setState(() {
            if(settingsState.keyFilter == categories[index]) {
              settingsState.keyFilter = '';
              settingsState.boldIndex = -1;
            } else {
              settingsState.keyFilter = categories[index];
              settingsState.boldIndex = index;
            }
          });
        },
        isBold: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    return FutureBuilder(
      // Load expense groups
      future: ExpenseUtils.getExpenseGroups(
        settingsState.entryType, 
        settingsState.aggregateType, 
        settingsState.startDate, 
        settingsState.endDate
      ), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          List<ExpenseGroup>? expenseGroups = snapshot.data;
          Map<String, List<double>> totalPerCategory = ExpenseUtils.getTotalPerCategory(expenseGroups!);
          List<Indicator> indicators = getLegend(totalPerCategory.keys.toList(), settingsState);
          // Make the selected indicator bold
          for (var i = 0; i < indicators.length; i++) {
            indicators[i].isBold = i == settingsState.boldIndex;
          }
          return Scaffold(
            appBar: AppBar(
              leading: const Icon(
                Icons.auto_graph_rounded, 
                color: Vx.orange400,
              ),
              title: const Text("Graph"),
              actions: const [
                SettingsMenu(),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      graphTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    const SizedBox(height: 16,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<String>(
                              value: settingsState.entryType,
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
                                  settingsState.entryType = value!;
                                  if(settingsState.entryType == 'expense') {
                                    graphTitle = "Expenses per period";
                                  } else {
                                    graphTitle = "Incomes per period";
                                  }
                                });
                              }
                            ),
                            DropdownButton<String>(
                              value: settingsState.aggregateType,
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
                                  settingsState.aggregateType = value!;
                                });
                              }
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(settingsState.startDate)),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? newStartDate = await showDatePicker(
                                    context: context,
                                    initialDate: settingsState.startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(DateTime.now().year, 12, 31),
                                    helpText: 'Select a start date'
                                );
                                if (newStartDate != null) {
                                  setState(() {  
                                    // Define to 23:59 to catch every expense this day
                                    settingsState.startDate = DateTime(
                                      newStartDate.year, 
                                      newStartDate.month, 
                                      newStartDate.day,
                                      23,
                                      59,
                                      59
                                    );
                                    if (settingsState.endDate.difference(settingsState.startDate).inMilliseconds < 0) {
                                      settingsState.endDate = newStartDate;
                                    }
                                  });
                                }
                              },
                            ),
                            Text(DateFormat('yyyy-MM-dd').format(settingsState.endDate)),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? newEndDate = await showDatePicker(
                                    context: context,
                                    initialDate: settingsState.endDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(DateTime.now().year, 12, 31),
                                    helpText: 'Select an end date'
                                  );
                                if (newEndDate != null) {
                                  setState(() {  
                                    // Define to 23:59 to catch every expense this day
                                    settingsState.endDate = DateTime(
                                      newEndDate.year, 
                                      newEndDate.month, 
                                      newEndDate.day,
                                      23,
                                      59,
                                      59
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Flexible(
                      child: BarChart(
                        BarChartData(
                          barGroups: getBarGroups(expenseGroups, keyFilter: settingsState.keyFilter),
                          borderData: FlBorderData(
                            show: true
                          ),
                          gridData: const FlGridData(
                            show: true,
                          ),
                          titlesData: getTitles(expenseGroups, settingsState),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [indicators[0], indicators[1], indicators[2], indicators[3]],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [indicators[4], indicators[5], indicators[6], indicators[7]],
                        )
                      ]
                    ),
                    const SizedBox(height: 25,),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          ExpenseUtils.showExpenseDialog(
                            true,
                            context, 
                            settingsState, 
                            DateTime.now().millisecondsSinceEpoch, 
                            DateTime.now().millisecondsSinceEpoch, 
                            "expense", 
                            "grocery", 
                            "", 
                            "", 
                            "EUR", 
                            false, 
                            _formKey, 
                            () { setState(() {}); }
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
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