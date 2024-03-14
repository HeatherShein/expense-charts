class Expense {
  final int? id;
  final int millisSinceEpoch;
  final String type;
  final String category;
  final String label;
  final double value;

  const Expense({
    this.id,
    required this.millisSinceEpoch,
    required this.type,
    required this.category,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'millisSinceEpoch': millisSinceEpoch,
      'type': type,
      'category': category,
      'label': label,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'Expense{id: $id, millisSinceEpoch: $millisSinceEpoch, type: $type, category: $category, label: $label value: $value}';
  }
}