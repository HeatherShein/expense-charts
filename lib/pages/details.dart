import 'package:expenses_charts/components/expense_tile.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/pages/expense_form.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late DatabaseHelper dbhelper;

  @override
  void initState() {
    super.initState();
    dbhelper = DatabaseHelper();
  }

  void updateExpenses(bool increase, SettingsProvider settingsState) {
    setState(() {
      if (increase) {
        settingsState.nExpenses += 13;
      } else {
        if (settingsState.nExpenses > 13) {
          settingsState.nExpenses -= 13;
        } else {
          settingsState.nExpenses = 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.list,
          color: Vx.orange400,
        ),
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () => updateExpenses(false, settingsState), 
            icon: const Icon(Icons.remove)
          ),
          IconButton(
            onPressed: () => updateExpenses(true, settingsState), 
            icon: const Icon(Icons.add)
          ),
          const SettingsMenu(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height:10.0),
              Flexible(
                child: FutureBuilder<List<Expense>>(
                  future: dbhelper.getLatestExpenses(settingsState.nExpenses),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error ${snapshot.error}');
                    } else {
                      List<Expense> expenses = snapshot.data!;
                      return ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          Expense expense = expenses[index];
                          return ExpenseTile(
                            millisSinceEpoch: expense.millisSinceEpoch, 
                            type: expense.type, 
                            category: expense.category, 
                            label: expense.label, 
                            value: expense.value,
                            refreshCallback: () { setState(() {}); },
                          );
                        }
                      );       
                    }
                  },
                )
              ),
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
              const SizedBox(height: 10.0)
            ],
          ),
        ),
      )
    );
  }
}