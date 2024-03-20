import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/components/money_amount.dart';
import 'package:expenses_charts/models/expense_utils.dart';
import 'package:expenses_charts/pages/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class ExpenseTile extends StatefulWidget {
  const ExpenseTile({super.key, required this.millisSinceEpoch, required this.type, required this.category, required this.label, required this.value, required this.refreshCallback});

  final int millisSinceEpoch;
  final String type;
  final String category;
  final String label;
  final double value;
  final VoidCallback refreshCallback;

  @override
  State<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const SizedBox(width: 8.0,),
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
                    DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(widget.millisSinceEpoch)),
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
            MoneyAmount(width: 80, type: widget.type, value: widget.value),
            IconButton(
              onPressed: () async {
                ExpenseForm expenseForm = await ExpenseForm.createWithExpenseId(
                  widget.millisSinceEpoch, 
                  widget.type, 
                  widget.category, 
                  widget.label, 
                  widget.value
                );
                // ignore: use_build_context_synchronously
                dynamic refreshData = await Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => expenseForm)
                );

                if (refreshData != null && refreshData is bool && refreshData) {
                  widget.refreshCallback();
                }
              }, 
              icon: const Icon(Icons.edit),
              color: Vx.blue400,
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
                              widget.millisSinceEpoch, 
                              widget.type, 
                              widget.category, 
                              widget.label, 
                              widget.value,
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
    );
  }
}