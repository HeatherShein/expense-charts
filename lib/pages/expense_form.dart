import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

final _formKey = GlobalKey<FormBuilderState>();

// ignore: must_be_immutable
class ExpenseForm extends StatelessWidget {

  DateTime startDate;
  DateTime endDate;
  String type;
  String category;
  String label;
  double value;
  int expenseId;

  ExpenseForm({super.key})
    :
    startDate = DateTime.now(),
    endDate = DateTime.now(),
    type = "default",
    category = "default",
    label = "",
    value = 0,
    expenseId = -1;

  ExpenseForm.withValues({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.category,
    required this.label,
    required this.value,
    required this.expenseId
  });

  static Future<ExpenseForm> createWithExpenseId(int millisSinceEpochStart, int millisSinceEpochEnd, String type, String category, String label, double value) async {
    DatabaseHelper dbhelper = DatabaseHelper();
    int expenseId = await dbhelper.getIdFromValues(
      millisSinceEpochStart,
      millisSinceEpochEnd, 
      type, 
      category, 
      label, 
      value
    );
    return ExpenseForm.withValues(
      startDate: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochStart), 
      endDate: DateTime.fromMillisecondsSinceEpoch(millisSinceEpochEnd), 
      type: type, 
      category: category, 
      label: label, 
      value: value, 
      expenseId: expenseId
    );
  }

  @override
  Widget build(BuildContext context) {
    endDate = endDate.difference(startDate).inMilliseconds > 0 ? endDate : startDate;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Form'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                Flexible(
                  child: FormBuilderDateTimePicker(
                    name: "start_date",
                    decoration: const InputDecoration(
                      labelText: "Start date",
                      hintText: "Pick a start date",
                    ),
                    initialValue: startDate,
                    initialDate: startDate,
                  ),
                ),
                Flexible(
                  child: FormBuilderDateTimePicker(
                    name: "end_date",
                    decoration: const InputDecoration(
                      labelText: "End date",
                      hintText: "Pick an end date",
                    ),
                    initialValue: endDate,
                    initialDate: endDate,
                  ),
                ),
                FormBuilderDropdown(
                  name: "type", 
                  decoration: const InputDecoration(
                    labelText: "Type",
                    hintText: "Select a type",
                  ),
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "expense",
                      child: Text("Expense")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "income",
                      child: Text("Income")
                    ),
                  ]
                ),
                FormBuilderDropdown(
                  name: "category", 
                  decoration: const InputDecoration(
                    labelText: "Category",
                    hintText: "Select a category",
                  ),
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "grocery",
                      child: Text("Grocery")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "regular",
                      child: Text("Regular")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "restaurant",
                      child: Text("Restaurant")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "leisure",
                      child: Text("Leisure")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "trip",
                      child: Text("Trip")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "exceptional",
                      child: Text("Exceptional")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "health",
                      child: Text("Health")
                    ),
                    DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: "alcohol",
                      child: Text("Alcohol")
                    ),
                  ]
                ),
                FormBuilderTextField(
                  name: "label",
                  decoration: const InputDecoration(
                    labelText: "Label",
                    hintText: 'Write an expense\'s label',
                  ),
                  initialValue: label,
                ),
                FormBuilderTextField(
                  name: "value", 
                  decoration: const InputDecoration(
                    labelText: "Value",
                    hintText: 'Write a value',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: value.toString(),
                ),
                const SizedBox(height: 10.0,),
                MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    _formKey.currentState?.saveAndValidate();
                    var formValues = _formKey.currentState?.value;
    
                    startDate = formValues?['start_date'];
                    var millisSinceEpochStart = startDate.millisecondsSinceEpoch;
                    endDate = formValues?['end_date'];
                    var millisSinceEpochEnd = endDate.millisecondsSinceEpoch;
                    millisSinceEpochEnd = millisSinceEpochEnd > millisSinceEpochStart ? millisSinceEpochEnd : millisSinceEpochStart;
                    type = formValues?['type'];
                    category = formValues?['category'];
                    label = formValues?['label'];
                    value = double.parse(formValues!['value'].toString().replaceAll(",", "."));
    
                    var dbhelper = DatabaseHelper();

                    if (expenseId != -1) {
                      Expense newExpense = Expense(
                        millisSinceEpochStart: millisSinceEpochStart,
                        millisSinceEpochEnd: millisSinceEpochEnd, 
                        type: type, 
                        category: category, 
                        label: label, 
                        value: value
                      );
                      dbhelper.updateExpense(
                        expenseId,
                        newExpense
                      );
                    } else {
                      dbhelper.insertExpense(
                        Expense(
                          millisSinceEpochStart: millisSinceEpochStart,
                          millisSinceEpochEnd: millisSinceEpochEnd,
                          type: type,
                          category: category,
                          label: label,
                          value: value,
                        )
                      );
                    }

                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      SnackBar(
                        content: const Text("Expense.s inserted successfully !"),
                        action: SnackBarAction(
                          label: "Go back",
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      )
                    );
                  },
                  child: Text(
                    expenseId == -1 ? "Insert expense" : "Update expense"
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}