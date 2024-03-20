import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class MoneyAmount extends StatelessWidget {
  const MoneyAmount({
    super.key,
    required this.width,
    required this.type,
    required this.value
  });

  final double width;
  final String type;
  final double value;

  @override
  Widget build(BuildContext context) {
    String sign = type == "expense" ? '-' : "+";
    return Container(
      width: width,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: type == 'expense' ? Vx.red200 : Vx.green200,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          "$sign ${value.toStringAsFixed(2)} €",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black
          )
        ),
      )
    );
  }
}