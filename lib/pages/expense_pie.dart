import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/money_amount.dart';
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

class ExpensePiePage extends StatefulWidget {
  const ExpensePiePage({super.key});

  @override
  State<ExpensePiePage> createState() => _ExpensePiePageState();
}

class _ExpensePiePageState extends State<ExpensePiePage> {
  String graphTitle = 'Total expenses';

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
              leading: const Icon(
                Icons.pie_chart_outline_rounded,
                color: Vx.orange400,
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
                          Text(
                            graphTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          const SizedBox(height: 16,),
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
                                      graphTitle = "Total expenses";
                                    } else {
                                      graphTitle = "Total incomes";
                                    }
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
                          Flexible(
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 0,
                                centerSpaceRadius: 100,
                              )
                            )
                          ),
                          const SizedBox(height: 8,),
                          Text(
                            "Total : ${totalExpense.toStringAsFixed(2)} ${settingsState.currency}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            )
                          ),
                          const SizedBox(height: 16,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[0],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[0].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                  indicators[1],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[1].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[2],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[2].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                  indicators[3],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[3].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[4],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[4].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                  indicators[5],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[5].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[6],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[6].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                  indicators[7],
                                  MoneyAmount(
                                    width: moneyAmountWidth, 
                                    type: settingsState.entryType, 
                                    value: sections[7].value.toStringAsFixed(2),
                                    currency: settingsState.currency,
                                    boxRadius: boxRadius,
                                    textFontSize: textFontSize,
                                  ),
                                ],
                              ),
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