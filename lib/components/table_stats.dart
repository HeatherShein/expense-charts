import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TableStats extends StatelessWidget {
  const TableStats({
    super.key,
    required this.nRows,
    required this.average,
    required this.min,
    required this.max
  });
  final String nRows;
  final String average;
  final String min;
  final String max;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Vx.black),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children:  [
        const TableRow(
          decoration: BoxDecoration(
            color: Vx.orange400,
          ),
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Aggregate",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Value",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            )
          ]
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: Vx.amber200,
          ),
          children: [
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Count"),
              )
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(nRows),
              )
            )
          ]
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: Vx.amber100,
          ),
          children: [
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Average"),
              )
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(average),
              )
            )
          ]
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: Vx.amber200,
          ),
          children: [
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Min"),
              )
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(min),
              )
            )
          ]
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: Vx.amber100,
          ),
          children: [
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Max"),
              )
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(max),
              )
            )
          ]
        ),
      ]
    );
  }
}