import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/components/table_stats.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

final _formKey = GlobalKey<FormBuilderState>();

class ExpenseStatsPage extends StatefulWidget {
  const ExpenseStatsPage({super.key});

  @override
  State<ExpenseStatsPage> createState() => _ExpenseStatsPageState();
}

class _ExpenseStatsPageState extends State<ExpenseStatsPage> {
  String graphTitle = 'Expenses stats';

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    return FutureBuilder(
      future: ExpenseUtils.getExpenseStats(settingsState.entryType, settingsState.expenseCategory, settingsState.startDate, settingsState.endDate), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          Map<String, dynamic>? expenseStats = snapshot.data; 
          return Scaffold(
            appBar: AppBar(
              leading: const Icon(
                Icons.candlestick_chart_outlined,
                color: Vx.orange400,
              ),
              title: const Text("Statistics"),
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
                                    value: settingsState.expenseCategory,
                                    items: const <DropdownMenuItem<String>>[
                                      DropdownMenuItem<String>(
                                        value: 'all',
                                        child: Text('All')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'alcohol',
                                        child: Text('Alcohol')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'exceptional',
                                        child: Text('Exceptional')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'grocery',
                                        child: Text('Grocery')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'health',
                                        child: Text('Health')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'leisure',
                                        child: Text('Leisure')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'regular',
                                        child: Text('Regular')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'restaurant',
                                        child: Text('Restaurant')
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'trip',
                                        child: Text('Trip')
                                      ),
                                    ], 
                                    onChanged: (String? value) {
                                      setState(() {
                                        settingsState.expenseCategory = value!;
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
                          const Text(
                            "General",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          TableStats(
                            nRows: expenseStats!["genNRows"].toString(), 
                            average: expenseStats["genAverage"].toStringAsFixed(2), 
                            min: expenseStats["genMin"].toStringAsFixed(2), 
                            max: expenseStats["genMax"].toStringAsFixed(2)
                          ),
                          const Text(
                            "Daily",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          TableStats(
                            nRows: expenseStats["dailyNRows"].toString(), 
                            average: expenseStats["dailyAverage"].toStringAsFixed(2), 
                            min: expenseStats["dailyMin"].toStringAsFixed(2), 
                            max: expenseStats["dailyMax"].toStringAsFixed(2)
                          ),
                          const SizedBox(height: 5,),
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
                        ]
                      )
                    )
                  ]
                ),
              ),
            )
          );
        }
      }
    );
  }
}