class Expense {
  final int? id;
  final int millisSinceEpochStart;
  final int millisSinceEpochEnd;
  final String type;
  final String category;
  final String label;
  final double value;

  const Expense({
    this.id,
    required this.millisSinceEpochStart,
    required this.millisSinceEpochEnd,
    required this.type,
    required this.category,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'millisSinceEpochStart': millisSinceEpochStart,
      'millisSinceEpochEnd': millisSinceEpochEnd,
      'type': type,
      'category': category,
      'label': label,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'Expense{id: $id, millisSinceEpoch: $millisSinceEpochStart - $millisSinceEpochEnd, type: $type, category: $category, label: $label value: $value}';
  }
}