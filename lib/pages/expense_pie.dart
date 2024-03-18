import 'package:expenses_charts/components/indicator.dart';
import 'package:expenses_charts/components/money_amount.dart';
import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/pages/expense_form.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

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
          List<Indicator> indicators = ExpenseUtils.getLegend(totalPerCategory.keys.toList());
          List<PieChartSectionData> sections = getSections(totalPerCategory);
          return Scaffold(
            appBar: AppBar(
              leading: const Icon(
                Icons.pie_chart_outline_rounded,
                color: Vx.orange400,
              ),
              title: const Text("Pie chart"),
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
                                      settingsState.startDate = newStartDate;
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
                                      settingsState.endDate = newEndDate;
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
                                centerSpaceRadius: 120,
                              )
                            )
                          ),
                          const SizedBox(height: 16,),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[0],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[0].value),
                                  indicators[1],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[1].value),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[2],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[2].value),
                                  indicators[3],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[3].value),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[4],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[4].value),
                                  indicators[5],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[5].value),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  indicators[6],
                                  MoneyAmount(width: 100, type: settingsState.entryType, value: sections[6].value),
                                ],
                              ),
                            ]
                          ),
                          const SizedBox(height: 25,),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                dynamic refreshData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ExpenseForm()),
                                );
                                if (refreshData != null && refreshData is bool && refreshData) {
                                  setState(() {});
                                }
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