import 'package:expenses_charts/components/date_range_picker.dart';
import 'package:expenses_charts/components/entry_type_dropdown.dart';
import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/utils/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  List<BarChartGroupData> getBarGroups(List<ExpenseGroup> expenseGroups, {String keyFilter = '', required bool isShare}) {
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

      // Sort by category
      groupAggregateValues?.sort((a, b) => a.category.compareTo(b.category));

      List<BarChartRodData> barRods = [];
      double totalValue = 0.0;

      for (var values in groupAggregateValues!) {
        double aggregatedValue = double.parse(values.aggregatedValue.toDoubleStringAsFixed());
        barRods.add(
          BarChartRodData(
            fromY: totalValue,
            toY: double.parse((totalValue + aggregatedValue).toDoubleStringAsFixed()),
            color: isShare 
              ? ExpenseUtils.getColorForLabel(values.category)
              : ExpenseUtils.getColorForCategory(values.category),
            width: 8,
          ),
        );
        totalValue += aggregatedValue;
        totalValue = double.parse(totalValue.toDoubleStringAsFixed());
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

  List<Indicator> getLegend(List<String> categories, SettingsProvider settingsState, {required bool isShare}) {
    categories.sort();
    return List.generate(categories.length, (index) {
      return Indicator(
        color: isShare 
          ? ExpenseUtils.getColorForLabel(categories[index])
          : ExpenseUtils.getColorForCategory(categories[index]),  
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
    final bool isShare = settingsState.entryType == "share";
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
          Map<String, List<double>> totalPerGroup = isShare 
            ? ExpenseUtils.getTotalPerLabel(expenseGroups!)
            : ExpenseUtils.getTotalPerCategory(expenseGroups!, entryType: settingsState.entryType);
          List<Indicator> indicators = getLegend(totalPerGroup.keys.toList(), settingsState, isShare: isShare);
          // Make the selected indicator bold
          for (var i = 0; i < indicators.length; i++) {
            indicators[i].isBold = i == settingsState.boldIndex;
          }
          return Scaffold(
            appBar: AppBar(
              leading: Icon(
                Icons.auto_graph_rounded, 
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Evolution"),
              actions: const [
                SettingsMenu(),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EntryTypeDropdown(
                              value: settingsState.entryType,
                              onChanged: (String? value) {
                                setState(() {
                                  settingsState.entryType = value!;
                                  settingsState.keyFilter = '';
                                  settingsState.boldIndex = -1;
                                });
                              },
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
                        DateRangePicker(
                          startDate: settingsState.startDate,
                          endDate: settingsState.endDate,
                          onStartDateChanged: (DateTime newDate) {
                            setState(() {
                              settingsState.startDate = newDate;
                            });
                          },
                          onEndDateChanged: (DateTime newDate) {
                            setState(() {
                              settingsState.endDate = newDate;
                            });
                          },
                        ),
                      ],
                    ),
                    Flexible(
                      child: BarChart(
                        BarChartData(
                          barGroups: getBarGroups(expenseGroups, keyFilter: settingsState.keyFilter, isShare: settingsState.entryType == "share"),
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
                    const SizedBox(height: 8,),
                    indicators.isEmpty 
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            if (indicators.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: indicators.length > 4
                                    ? indicators.sublist(0, 4)
                                    : indicators,
                              ),
                            if (indicators.length > 4)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: indicators.sublist(4),
                              ),
                          ]
                        ),
                    const SizedBox(height: 10),
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