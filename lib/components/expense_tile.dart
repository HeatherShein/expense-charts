import 'package:expenses_charts/components/database_helper.dart';
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
        const SizedBox(width: 10.0),
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: widget.type == 'expense' ? Vx.red200 : Vx.green200,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: Text(
              widget.type[0],
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              )
            )
          )
        ),
        const SizedBox(width: 8.0,),
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: ExpenseUtils.getColorForCategory(widget.category),
            borderRadius: BorderRadius.circular(4.0)
          ),
          child: Text(
            widget.category,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black
            )
          )
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.trim(),
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
            )
          )
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                widget.value.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                )
              )
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              child: const Text(
                "€",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                )
              )
            ),
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
                  context,
                  MaterialPageRoute(builder: (context) => expenseForm)
                );

                if (refreshData != null && refreshData is bool && refreshData) {
                  widget.refreshCallback();
                }
              }, 
              icon: const Icon(Icons.edit),
              color: Colors.blue,
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
              }, 
              icon: const Icon(Icons.delete),
              color: Colors.blue,
            ),
          ],
        ),
        
      ],
    );
  }
}