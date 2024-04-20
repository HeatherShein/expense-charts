import 'package:expenses_charts/components/expense_tile.dart';
import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:flutter/scheduler.dart';
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

class _DetailsPageState extends State<DetailsPage> with AutomaticKeepAliveClientMixin {
  late DatabaseHelper dbhelper;
  late SettingsProvider settingsState;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    dbhelper = DatabaseHelper();
    _controller = ScrollController();
    _controller.addListener(() { _scrollListener(); });
  }

  void _scrollListener() {
    if (
      _controller.hasClients &&
      _controller.position.pixels == _controller.position.maxScrollExtent
    ) {
      // Reached the end of list, load more data
      setState(() {
        settingsState.nExpenses += 50;
      });

      // Reach the last item viewed
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    settingsState = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.list,
          color: Vx.orange400,
        ),
        title: const Text('Details'),
        actions: [
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
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        onChanged: (String? value) {
                          settingsState.expenseLabel = value!;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search ...',
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height:10.0),
              Flexible(
                child: FutureBuilder<List<Expense>>(
                  future: dbhelper.getLatestExpenses(
                    settingsState.nExpenses, 
                    settingsState.expenseCategory,
                    settingsState.expenseLabel
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error ${snapshot.error}');
                    } else {
                      List<Expense> expenses = snapshot.data!;
                      return ListView.builder(
                        controller: _controller,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          Expense expense = expenses[index];
                          return ExpenseTile(
                            index: index+1,
                            millisSinceEpochStart: expense.millisSinceEpochStart,
                            millisSinceEpochEnd: expense.millisSinceEpochEnd, 
                            type: expense.type, 
                            category: expense.category, 
                            label: expense.label, 
                            value: expense.value.toStringAsFixed(2),
                            currency: settingsState.currency,
                            refreshCallback: () { setState(() {}); },
                          );
                        },
                      );       
                    }
                  },
                )
              ),
            ],
          ),
        ),
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}