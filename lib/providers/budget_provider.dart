import 'package:flutter/material.dart';
import 'package:expenses_charts/managers/pref_manager.dart';

/// Provider for managing remaining budget state
class BudgetProvider extends ChangeNotifier {
  double _remainingBudget = 0.0;
  bool _isLoading = false;

  double get remainingBudget => _remainingBudget;
  bool get isLoading => _isLoading;

  /// Initialize the budget provider by loading the current budget
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _remainingBudget = await PrefManager.getVariable();
    } catch (e) {
      debugPrint('Error loading budget: $e');
      _remainingBudget = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the remaining budget
  Future<void> updateBudget(double newBudget) async {
    _isLoading = true;
    notifyListeners();

    try {
      await PrefManager.saveVariable(newBudget);
      _remainingBudget = newBudget;
    } catch (e) {
      debugPrint('Error updating budget: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add to the remaining budget (for income)
  Future<void> addToBudget(double amount) async {
    await updateBudget(_remainingBudget + amount);
  }

  /// Subtract from the remaining budget (for expenses)
  Future<void> subtractFromBudget(double amount) async {
    await updateBudget(_remainingBudget - amount);
  }

  /// Check if budget is set (not zero)
  bool get isBudgetSet => _remainingBudget != 0.0;

  /// Get formatted budget string
  String getFormattedBudget(String currency) {
    return '${_remainingBudget.toStringAsFixed(2)} $currency';
  }
}
