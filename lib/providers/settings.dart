import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier{
  String _entryType = "expense";
  String _aggregateType = "day";
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);
  int _nExpenses = 50;
  String _keyFilter = '';
  int _boldIndex = -1;
  String _currency = "EUR";
  String _expenseCategory = "all";
  String _expenseLabel = "";

  String get entryType => _entryType;
  String get aggregateType => _aggregateType;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get nExpenses => _nExpenses;
  String get keyFilter => _keyFilter;
  int get boldIndex => _boldIndex;
  String get currency => _currency;
  String get expenseCategory => _expenseCategory;
  String get expenseLabel => _expenseLabel;

  set entryType(String newEntryType) {
    _entryType = newEntryType;
    notifyListeners();
  }

  set aggregateType(String newAggregateType) {
    _aggregateType = newAggregateType;
    notifyListeners();
  }

  set startDate(DateTime newStartDate) {
    _startDate = newStartDate;
    notifyListeners();
  }

  set endDate(DateTime newEndDate) {
    _endDate = newEndDate;
    notifyListeners();
  }

  set nExpenses (int newNExpenses) {
    _nExpenses = newNExpenses;
    notifyListeners();
  }

  set keyFilter (String newKeyFilter) {
    _keyFilter = newKeyFilter;
    notifyListeners();
  }

  set boldIndex (int newBoldIndex) {
    _boldIndex = newBoldIndex;
    notifyListeners();
  }

  set currency (String newCurrency) {
    _currency = newCurrency;
    notifyListeners();
  }

  set expenseCategory (String newExpenseCategory) {
    _expenseCategory = newExpenseCategory;
    notifyListeners();
  }

  set expenseLabel (String newExpenseLabel) {
    _expenseLabel = newExpenseLabel;
    notifyListeners();
  }
}