import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier{
  String _entryType = "expense";
  String _aggregateType = "day";
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  int _nExpenses = 13;

  String get entryType => _entryType;
  String get aggregateType => _aggregateType;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get nExpenses => _nExpenses;

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
}