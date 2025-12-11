import 'package:flutter/material.dart';
import 'package:expenses_charts/utils/database_helper.dart';

/// Provider for managing remaining budget state
/// Budget is calculated as: sum of all incomes - sum of all expenses
class BudgetProvider extends ChangeNotifier {
  double _remainingBudget = 0.0;
  bool _isLoading = false;

  double get remainingBudget => _remainingBudget;
  bool get isLoading => _isLoading;

  /// Initialize the budget provider by calculating from database
  Future<void> initialize() async {
    await refresh();
  }

  /// Refresh the budget by recalculating from database
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper();
      _remainingBudget = await dbHelper.getRemainingBudget();
    } catch (e) {
      debugPrint('Error calculating budget: $e');
      _remainingBudget = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> getTotalShares() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getTotalShares();
  }

  Future<double> getTotalIncomes() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getTotalIncomes();
  }

  Future<double> getTotalExpenses() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getTotalExpenses();
  }

  // Method to get total money (shares + incomes - expenses)
  Future<double> getTotalMoney() async {
    final shares = await getTotalShares();
    final incomes = await getTotalIncomes();
    final expenses = await getTotalExpenses();
    return shares + incomes - expenses;
  }

  // Method to get total without shares (incomes - expenses)
  Future<double> getTotalWithoutShares() async {
    final incomes = await getTotalIncomes();
    final expenses = await getTotalExpenses();
    return incomes - expenses;
  }

  /// Check if budget is set (not zero)
  bool get isBudgetSet => _remainingBudget != 0.0;

  /// Get formatted budget string
  String getFormattedBudget(String currency) {
    return '${_remainingBudget.toStringAsFixed(2)} $currency';
  }
}
