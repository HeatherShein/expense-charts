import 'package:expenses_charts/components/expense_tile.dart';
import 'package:expenses_charts/pages/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late DatabaseHelper dbhelper;
  int nExpenses = 10;

  @override
  void initState() {
    super.initState();
    dbhelper = DatabaseHelper();
  }

  void updateExpenses(bool increase) {
    setState(() {
      if (increase) {
        nExpenses += 10;
      } else {
        if (nExpenses > 10) {
          nExpenses -= 10;
        } else {
          nExpenses = 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () => updateExpenses(false), 
            icon: const Icon(Icons.remove)
          ),
          IconButton(
            onPressed: () => updateExpenses(true), 
            icon: const Icon(Icons.add)
          ),
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
                  future: dbhelper.getLatestExpenses(nExpenses),
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