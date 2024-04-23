import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.tileAggregate,
    required this.tileAggregateColor,
    required this.tileValue,
    required this.tileValueColor,
    required this.currency,
  });
  final String tileAggregate;
  final Color tileAggregateColor;
  final String tileValue;
  final Color tileValueColor;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Container(
            height: 35,
            width: 90,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: tileAggregateColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Text(
                tileAggregate,
                key: const Key("aggregateKey"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
              color: tileValueColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Text(
                "$tileValue $currency",
                key: const Key("valueKey"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black
                )
              ),
            ),
          ),
        ],
      )
    );
  }
}