// Test for the 'models' folder.
// Each model is a class meant to represent an object (ex: Expense).

import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Expense creation", () {
    // Create expense
    Expense expense = const Expense(
      millisSinceEpochStart: 0, 
      millisSinceEpochEnd: 100, 
      type: "income", 
      category: "regular",
      label: "Salary", 
      value: 2500
    );
    // Assert correctly created
    expect(expense.millisSinceEpochStart, 0);
    expect(expense.millisSinceEpochEnd, 100);
    expect(expense.type, "income");
    expect(expense.category, "regular");
    expect(expense.label, "Salary");
    expect(expense.value, 2500);
  });

  test("Expense mapping", () {
    // Create expense
    Expense expense = const Expense(
      millisSinceEpochStart: 0, 
      millisSinceEpochEnd: 100, 
      type: "income", 
      category: "regular",
      label: "Salary", 
      value: 2500
    );
    // Assert mapping is correct
    expect(expense.toMap(), {
      'millisSinceEpochStart': 0,
      'millisSinceEpochEnd': 100,
      'type': "income",
      'category': "regular",
      'label': "Salary",
      'value': 2500,
    });
  });

  test("Expense to string", () {
    // Create expense
    Expense expense = const Expense(
      millisSinceEpochStart: 0, 
      millisSinceEpochEnd: 100, 
      type: "income", 
      category: "regular",
      label: "Salary", 
      value: 2500
    );
    // Assert toString method
    expect(expense.toString(), 'Expense{id: null, millisSinceEpoch: 0 - 100, type: income, category: regular, label: Salary value: 2500.0}');
  });

  test("ExpenseGroup creation", () {
    // Create expenseGroup
    ExpenseGroup expenseGroup = const ExpenseGroup(
      groupAggregate: "2024-04-21", 
      category: "grocery", 
      aggregatedValue: 250.0
    );
    // Assert correctly created
    expect(expenseGroup.groupAggregate, "2024-04-21");
    expect(expenseGroup.category, "grocery");
    expect(expenseGroup.aggregatedValue, 250.0);
  });

  test("ExpenseGroup to String", () {
    // Create expenseGroup
    ExpenseGroup expenseGroup = const ExpenseGroup(
      groupAggregate: "2024-04-21", 
      category: "grocery", 
      aggregatedValue: 250.0
    );
    // Assert toString method
    expect(expenseGroup.toString(), "ExpenseGroup{groupAggregate: 2024-04-21, category: grocery, value: 250.0}");
  });
}
