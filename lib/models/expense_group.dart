class ExpenseGroup {
  final String groupAggregate;
  final String category;
  final double aggregatedValue;

  const ExpenseGroup({
    required this.groupAggregate,
    required this.category,
    required this.aggregatedValue,
  });

  @override
  String toString() {
    return "ExpenseGroup{groupAggregate: $groupAggregate, category: $category, value: $aggregatedValue}";
  }
}