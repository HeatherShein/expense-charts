import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class Indicator extends StatelessWidget {
  Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 12,
    this.textColor,
    this.onTap,
    required this.isBold,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  final VoidCallback? onTap;
  bool isBold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Row(
        children: <Widget>[
          Container(
            key: const Key("coloredBoxKey"),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              key: const Key("indicatorTextKey"),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}