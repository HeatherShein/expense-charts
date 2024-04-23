import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/components/stat_tile.dart';
import 'package:expenses_charts/utils/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final _formKey = GlobalKey<FormBuilderState>();

class ExpenseStatsPage extends StatefulWidget {
  const ExpenseStatsPage({super.key});

  @override
  State<ExpenseStatsPage> createState() => _ExpenseStatsPageState();
}

class _ExpenseStatsPageState extends State<ExpenseStatsPage> {
  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    String moneyAmountCurrency = settingsState.currency == "EUR" ? "€" : settingsState.currency;
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
              leading: Icon(
                Icons.candlestick_chart_outlined,
                color: Theme.of(context).colorScheme.primary,
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
                            ],
                          ),
                          const Spacer(),
                          Card(
                            color: Theme.of(context).cardColor,
                            elevation: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 35,
                                    width: 90,
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "General",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        )
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      StatTile(
                                        tileAggregate: "Count",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats!["genNRows"].toString(), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Average",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["genAverage"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Min",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["genMin"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Max",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["genMax"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Card(
                            color: Theme.of(context).cardColor,
                            elevation: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 35,
                                    width: 90,
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Daily",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        )
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      StatTile(
                                        tileAggregate: "Count",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["dailyNRows"].toString(), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Average",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["dailyAverage"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Min",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["dailyMin"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      ),
                                      StatTile(
                                        tileAggregate: "Max",
                                        tileAggregateColor: Colors.white,
                                        tileValue: expenseStats["dailyMax"].toStringAsFixed(2), 
                                        tileValueColor: Theme.of(context).colorScheme.secondary,
                                        currency: moneyAmountCurrency,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
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