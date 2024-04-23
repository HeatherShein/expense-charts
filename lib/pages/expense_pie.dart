import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/money_amount.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/utils/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final _formKey = GlobalKey<FormBuilderState>();

class ExpensePiePage extends StatefulWidget {
  const ExpensePiePage({super.key});

  @override
  State<ExpensePiePage> createState() => _ExpensePiePageState();
}

class _ExpensePiePageState extends State<ExpensePiePage> {
  List<PieChartSectionData> getSections(Map<String, List<double>> totalPerCategory) {
    List<PieChartSectionData> sections = totalPerCategory.keys.map((category) {
      double total = totalPerCategory[category]!.reduce((value, element) => value + element);
      total = double.parse(total.toStringAsFixed(2));
      return PieChartSectionData(
        value: total,
        title: category,
        showTitle: false,
        color: ExpenseUtils.getColorForCategory(category),
      );
    }).toList();
    sections.sort((a, b) => a.title.compareTo(b.title));
    return sections;
  }

  static List<Indicator> getLegend(List<String> categories) {
    categories.sort();
    return List.generate(categories.length, (index) {
      return Indicator(
        color: ExpenseUtils.getColorForCategory(categories[index]), 
        text: categories[index], 
        isSquare: true,
        isBold: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    return FutureBuilder(
      future: ExpenseUtils.getExpenseGroups(settingsState.entryType, "", settingsState.startDate, settingsState.endDate), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          List<ExpenseGroup>? expenseGroups = snapshot.data;
          Map<String, List<double>> totalPerCategory = ExpenseUtils.getTotalPerCategory(expenseGroups!);
          List<Indicator> indicators = getLegend(totalPerCategory.keys.toList());
          List<PieChartSectionData> sections = getSections(totalPerCategory);
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
              title: const Text("Pie chart"),
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
                                  });
                                }
                              ),
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
                                    settingsState.startDate = DateTime(
                                      newStartDate.year, 
                                      newStartDate.month, 
                                      newStartDate.day
                                    );
                                    if (settingsState.endDate.difference(settingsState.startDate).inMilliseconds < 0) {
                                      // To catch every expense that day
                                      settingsState.endDate = DateTime(
                                        newStartDate.year,
                                        newStartDate.month,
                                        newStartDate.day,
                                        23,
                                        59,
                                        59
                                      );
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
                              fontSize: 16,
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