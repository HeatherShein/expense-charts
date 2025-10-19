import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

/// Color constants for expense categories
class CategoryColors {
  /// Color mapping for each expense category
  static const Map<String, Color> _categoryColors = {
    'grocery': Vx.yellow400,
    'regular': Vx.blue400,
    'restaurant': Vx.orange400,
    'leisure': Vx.purple400,
    'trip': Vx.pink400,
    'exceptional': Vx.amber400,
    'health': Vx.teal400,
    'alcohol': Vx.red400,
  };

  /// Default color for unknown categories
  static const Color defaultColor = Vx.black;

  /// Get color for a specific category
  static Color getColorForCategory(String category) {
    return _categoryColors[category] ?? defaultColor;
  }

  /// Get all available colors
  static List<Color> get allColors => _categoryColors.values.toList();

  /// Get all category names
  static List<String> get allCategories => _categoryColors.keys.toList();
}
