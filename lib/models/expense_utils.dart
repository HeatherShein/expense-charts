import 'package:flutter/material.dart';

class ExpenseUtils {
  static Color getColorForCategory(String category) {
    Color outColor = Colors.black;
    switch (category) {
      case 'grocery':
        outColor = Colors.yellow;
        break;
      case 'regular':
        outColor = Colors.blue;
        break;
      case 'restaurant':
        outColor = Colors.orange;
        break;
      case 'pleasure':
        outColor = Colors.purple;
        break;
      case 'trip':
        outColor = Colors.pink;
        break;
      case 'exceptional':
        outColor = Colors.amber;
        break;
      case 'health':
        outColor = Colors.teal;
        break;
      case 'alcohol':
        outColor = Colors.red;
        break;
      default:
        outColor = Colors.black;
    }
    return outColor;
  }
}