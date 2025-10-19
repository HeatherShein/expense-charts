/// Constants for expense categories used throughout the app
class ExpenseCategories {
  /// All available expense categories
  static const List<String> all = [
    'alcohol',
    'exceptional', 
    'grocery',
    'health',
    'leisure',
    'regular',
    'restaurant',
    'trip'
  ];

  /// Category display names for UI
  static const Map<String, String> displayNames = {
    'alcohol': 'Alcohol',
    'exceptional': 'Exceptional',
    'grocery': 'Grocery',
    'health': 'Health',
    'leisure': 'Leisure',
    'regular': 'Regular',
    'restaurant': 'Restaurant',
    'trip': 'Trip',
  };

  /// Category names for CSV export (French)
  static const Map<String, String> csvNames = {
    'alcohol': 'Alcool',
    'exceptional': 'Exceptionnelle',
    'grocery': 'Course',
    'health': 'Santé',
    'leisure': 'Plaisir',
    'regular': 'Régulier',
    'restaurant': 'Restaurant',
    'trip': 'Voyage',
  };

  /// Check if a category is valid
  static bool isValid(String category) {
    return all.contains(category);
  }

  /// Get display name for a category
  static String getDisplayName(String category) {
    return displayNames[category] ?? category;
  }

  /// Get CSV name for a category
  static String getCsvName(String category) {
    return csvNames[category] ?? category;
  }
}
