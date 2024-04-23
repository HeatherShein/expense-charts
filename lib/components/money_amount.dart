import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class MoneyAmount extends StatelessWidget {
  const MoneyAmount({
    super.key,
    required this.width,
    required this.type,
    required this.value,
    required this.currency,
    required this.boxRadius,
    required this.textFontSize,
  });

  final double width;
  final String type;
  final String value;
  final String currency;
  final double boxRadius;
  final double textFontSize;

  @override
  Widget build(BuildContext context) {
    String sign = type == "expense" ? '-' : "+";
    return Container(
      width: width,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: type == 'expense' ? Vx.red200 : Vx.green200,
        borderRadius: BorderRadius.circular(boxRadius),
      ),
      child: Center(
        child: Text(
          "$sign $value $currency",
          key: const Key("moneyAmountTextKey"),
          style: TextStyle(
            fontSize: textFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black
          )
        ),
      )
    );
  }
}