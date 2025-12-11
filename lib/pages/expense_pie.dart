import 'package:expenses_charts/components/date_range_picker.dart';
import 'package:expenses_charts/components/entry_type_dropdown.dart';
import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/money_amount.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:expenses_charts/utils/expense_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensePiePage extends StatefulWidget {
  const ExpensePiePage({super.key});

  @override
  State<ExpensePiePage> createState() => _ExpensePiePageState();
}

class _ExpensePiePageState extends State<ExpensePiePage> {

  List<PieChartSectionData> getSections(Map<String, List<double>> totalPerGroup, bool isShare) {
    List<PieChartSectionData> sections = totalPerGroup.keys.map((groupKey) {
      double total = totalPerGroup[groupKey]!.reduce((value, element) => value + element);
      total = double.parse(total.toStringAsFixed(2));
      return PieChartSectionData(
        value: total,
        title: groupKey,
        showTitle: false,
        color: isShare 
          ? ExpenseUtils.getColorForLabel(groupKey)
          : ExpenseUtils.getColorForCategory(groupKey),
      );
    }).toList();
    sections.sort((a, b) => a.title.compareTo(b.title));
    return sections;
  }

  static List<Indicator> getLegend(List<String> groups, bool isShare) {
    groups.sort();
    return List.generate(groups.length, (index) {
      return Indicator(
        color: isShare 
            ? ExpenseUtils.getColorForLabel(groups[index])
            : ExpenseUtils.getColorForCategory(groups[index]), 
        text: groups[index], 
        isSquare: true,
        isBold: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsProvider>();
    final bool isShare = settingsState.entryType == "share";
    return FutureBuilder(
      future: ExpenseUtils.getExpenseGroups(settingsState.entryType, "", settingsState.startDate, settingsState.endDate), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          List<ExpenseGroup>? expenseGroups = snapshot.data;
          Map<String, List<double>> totalPerGroup = isShare 
              ? ExpenseUtils.getTotalPerLabel(expenseGroups!)
              : ExpenseUtils.getTotalPerCategory(expenseGroups!);
          List<Indicator> indicators = getLegend(totalPerGroup.keys.toList(), isShare);
          List<PieChartSectionData> sections = getSections(totalPerGroup, isShare);
          double moneyAmountWidth = 90;
          double boxRadius = 20;
          double textFontSize = 12;
          // Compute total expense
          double totalExpense = 0;
          for (ExpenseGroup expenseGroup in expenseGroups) {
            totalExpense += expenseGroup.aggregatedValue;
          }
          return Scaffold(
            appBar: AppBar(
              leading: Icon(
                Icons.pie_chart_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Distribution"),
              actions: const [
                SettingsMenu(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              EntryTypeDropdown(
                                value: settingsState.entryType,
                                onChanged: (String? value) {
                                  setState(() {
                                    settingsState.entryType = value!;
                                  });
                                },
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
                          Flexible(
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 0,
                                centerSpaceRadius: 80,
                              )
                            )
                          ),
                          Text(
                            "Total : ${totalExpense.toStringAsFixed(2)} ${settingsState.currency}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w200,
                            )
                          ),
                          const SizedBox(height: 16,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              indicators.length, (i) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      indicators[i],
                                      const Spacer(),
                                      MoneyAmount(
                                        width: moneyAmountWidth, 
                                        type: settingsState.entryType, 
                                        value: sections[i].value.toStringAsFixed(2), 
                                        currency: settingsState.currency, 
                                        boxRadius: boxRadius, 
                                        textFontSize: textFontSize
                                      )
                                    ],
                                  ),
                                );
                              }
                            )
                          ),
                        ],
                      ),
                    ),
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