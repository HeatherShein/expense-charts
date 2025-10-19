import 'package:expenses_charts/models/expenses.dart';
import 'package:expenses_charts/utils/database_helper.dart';
import 'package:expenses_charts/utils/expense_utils.dart';

/// Repository for managing expense data operations
class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Get all expenses within a date range
  Future<List<Expense>> getExpensesInRange(DateTime startDate, DateTime endDate) async {
    return await _dbHelper.getExpensesWithDates(startDate, endDate);
  }

  /// Get latest expenses with optional filtering
  Future<List<Expense>> getLatestExpenses({
    int limit = 50,
    String category = 'all',
    String label = '',
  }) async {
    return await _dbHelper.getLatestExpenses(limit, category, label);
  }

  /// Get expenses over a period for a specific entry type
  Future<List<Map<String, dynamic>>> getExpensesOverPeriod({
    required String entryType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _dbHelper.getExpenseOverPeriod(entryType, startDate, endDate);
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense);
  }

  /// Update an existing expense
  Future<void> updateExpense(int expenseId, Expense expense) async {
    await _dbHelper.updateExpense(expenseId, expense);
  }

  /// Delete an expense by ID (requires getting the expense first)
  Future<void> deleteExpenseById(int expenseId) async {
    final expense = await _dbHelper.getExpenseById(expenseId);
    await _dbHelper.deleteExpense(
      expense.millisSinceEpochStart,
      expense.millisSinceEpochEnd,
      expense.type,
      expense.category,
      expense.label,
      expense.value,
    );
  }

  /// Delete an expense by values
  Future<void> deleteExpense(
    int millisSinceEpochStart,
    int millisSinceEpochEnd,
    String type,
    String category,
    String label,
    double value,
  ) async {
    await _dbHelper.deleteExpense(
      millisSinceEpochStart,
      millisSinceEpochEnd,
      type,
      category,
      label,
      value,
    );
  }

  /// Get expense by ID
  Future<Expense> getExpenseById(int expenseId) async {
    return await _dbHelper.getExpenseById(expenseId);
  }

  /// Check if an expense exists in the database
  Future<bool> expenseExists(Map<String, dynamic> expenseData) async {
    return await _dbHelper.existsInExistingDatabase(expenseData);
  }

  /// Get expense statistics
  Future<Map<String, dynamic>> getExpenseStats({
    required String entryType,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await ExpenseUtils.getExpenseStats(entryType, category, startDate, endDate);
  }
}
