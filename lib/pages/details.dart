import 'package:expenses_charts/components/expense_tile.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

final _formKey = GlobalKey<FormBuilderState>();

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
          SizedBox(
            width: 30,
            child: TextFormField(
              controller: TextEditingController(text: settingsState.nExpenses.toString()),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onFieldSubmitted: (value) {
                setState(() {
                  settingsState.nExpenses = int.parse(value);
                });
              },
            ),
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
                            millisSinceEpochStart: expense.millisSinceEpochStart,
                            millisSinceEpochEnd: expense.millisSinceEpochEnd, 
                            type: expense.type, 
                            category: expense.category, 
                            label: expense.label, 
                            value: expense.value.toStringAsFixed(2),
                            currency: settingsState.currency,
                            refreshCallback: () { setState(() {}); },
                          );
                        }
                      );       
                    }
                  },
                )
              ),
              const SizedBox(height: 10.0),
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
              const SizedBox(height: 10.0)
            ],
          ),
        ),
      )
    );
  }
}