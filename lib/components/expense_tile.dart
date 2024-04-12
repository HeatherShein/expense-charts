import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/components/money_amount.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

final _formKey = GlobalKey<FormBuilderState>();

class ExpenseTile extends StatefulWidget {
  const ExpenseTile({
    super.key, 
    required this.index,
    required this.millisSinceEpochStart, 
    required this.millisSinceEpochEnd, 
    required this.type, 
    required this.category, 
    required this.label, 
    required this.value, 
    required this.currency,
    required this.refreshCallback
  });

  final int index;
  final int millisSinceEpochStart;
  final int millisSinceEpochEnd;
  final String type;
  final String category;
  final String label;
  final String value;
  final String currency;
  final VoidCallback refreshCallback;

  @override
  State<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsState = context.watch<SettingsProvider>();
    DateTime dateTimeStartDate = DateTime.fromMillisecondsSinceEpoch(widget.millisSinceEpochStart);
    DateTime dateTimeEndDate = DateTime.fromMillisecondsSinceEpoch(widget.millisSinceEpochEnd);
    String startDate = DateFormat('yyyy-MM-dd').format(dateTimeStartDate);
    String endDate = DateFormat('yyyy-MM-dd').format(dateTimeEndDate);
    bool isDifferentEndDate = dateTimeEndDate.difference(dateTimeStartDate).inMilliseconds > 0;
    bool isLongExpense = isDifferentEndDate;
    // TODO: put a switch case to insert symbols
    String moneyAmountCurrency = widget.currency == "EUR" ? "€" : widget.currency;
    String dateString = isDifferentEndDate ? '$startDate - $endDate' : startDate;
    return GestureDetector(
      onTap: () async {
        ExpenseUtils.showExpenseDialog(
          false,
          context,
          settingsState,
          widget.millisSinceEpochStart,
          widget.millisSinceEpochEnd,
          widget.type,
          widget.category,
          widget.label,
          widget.value,
          widget.currency,
          isLongExpense,
          _formKey,
          widget.refreshCallback,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Container(
            height: 35,
            width: 30,
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Text(
                widget.index.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: Colors.black
                )
              ),
            ),
          ),
          Container(
            height: 35,
            width: 90,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: ExpenseUtils.getColorForCategory(widget.category),
              borderRadius: BorderRadius.circular(4.0)
            ),
            child: Center(
              child: Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                )
              ),
            )
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.trim(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      dateString,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            )
          ),
          Row(
            children: [
              MoneyAmount(
                width: 80, 
                type: widget.type, 
                value: widget.value,
                currency: moneyAmountCurrency,
                boxRadius: 20,
                textFontSize: 12,
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm deletion"),
                        content: const Text("Are you sure to delete this ?"),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.not_interested_rounded)
                          ),
                          IconButton(
                            onPressed: () {
                              DatabaseHelper dbhelper = DatabaseHelper();
                              dbhelper.deleteExpense(
                                widget.millisSinceEpochStart,
                                widget.millisSinceEpochEnd, 
                                widget.type, 
                                widget.category, 
                                widget.label, 
                                double.parse(widget.value),
                              );
                              widget.refreshCallback();
                              Navigator.of(context).pop();
                            }, 
                            icon: const Icon(Icons.done_rounded)
                          ),
                        ]
                      );
                    }
                  );
                }, 
                icon: const Icon(Icons.delete),
                color: Vx.red400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}