import 'package:expenses_charts/models/expense_group.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper(){
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<void> deleteDatabase() async {
    databaseFactory.deleteDatabase(join(await getDatabasesPath(), 'expense_database.db'));
  }

  Future _initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = join(documentsDirectory.path, 'expense_database.db');

    return await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            millisSinceEpoch INTEGER, 
            type TEXT, 
            category TEXT, 
            label TEXT, 
            value REAL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> getIdFromValues(int millisSinceEpoch, String type, String category, String label, double value) async {
    final db = await _getDatabase();

    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      columns: ['id'],
      where: 'millisSinceEpoch = ? AND type = ? AND category = ? AND label = ? AND value = ?',
      whereArgs: [millisSinceEpoch, type, category, label, value]
    );

    if (maps.length == 1) {
      return maps[0]['id'] as int;
    } else {
      throw Exception("Error : multiple ids for this query");
    }
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await _getDatabase();

    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(int expenseId, Expense newExpense) async {
    final db = await _getDatabase();

    await db.update(
      'expenses', 
      newExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expenseId]
    );
  }

  Future<void> deleteExpense(int millisSinceEpoch, String type, String category, String label, double value) async {
    final db = await _getDatabase();

    await db.delete(
      'expenses',
      where: 'millisSinceEpoch = ? AND type = ? AND category = ? AND label = ? AND value = ?',
      whereArgs: [millisSinceEpoch, type, category, label, value],
    );
  }

  Future<List<Expense>> expenses() async {
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int, 
        millisSinceEpoch: maps[i]['millisSinceEpoch'] as int, 
        type: maps[i]['type'] as String, 
        category: maps[i]['category'] as String,
        label: maps[i]['label'] as String,
        value: maps[i]['value'] as double,
      );
    });
  }

  Future<List<Expense>> getLatestExpenses(int n) async {
    debugPrint("Fetching expenses");
    final db = await _getDatabase();
    debugPrint(db.toString());

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: "millisSinceEpoch DESC",
      limit: n
    );

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int, 
        millisSinceEpoch: maps[i]['millisSinceEpoch'] as int, 
        type: maps[i]['type'] as String, 
        category: maps[i]['category'] as String,
        label: maps[i]['label'] as String,
        value: maps[i]['value'] as double,
      );
    });
  }

  Future<List<ExpenseGroup>> getExpensesPerYear(String entryType, DateTime startDate, DateTime endDate) async {
    final db = await _getDatabase();

    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        strftime('%Y', datetime(millisSinceEpoch / 1000, 'unixepoch')) AS year,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpoch / 1000, 'unixepoch') BETWEEN ? AND ?
        AND
        type = ?
      GROUP BY
        year, category
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );

    return List.generate(maps.length, (i) {
      return ExpenseGroup(
        groupAggregate: maps[i]['year'] as String,
        category: maps[i]['category'] as String,
        aggregatedValue: maps[i]['totalValue'] as double
      );
    });
  }

  Future<List<ExpenseGroup>> getExpensesPerMonth(String entryType, DateTime startDate, DateTime endDate) async {
    final db = await _getDatabase();

    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m', datetime(millisSinceEpoch / 1000, 'unixepoch')) AS month,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpoch / 1000, 'unixepoch') BETWEEN ? AND ?
        AND
        type = ?
      GROUP BY
        month, category
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );

    return List.generate(maps.length, (i) {
      return ExpenseGroup(
        groupAggregate: maps[i]['month'] as String,
        category: maps[i]['category'] as String,
        aggregatedValue: maps[i]['totalValue'] as double
      );
    });
  }

  Future<List<ExpenseGroup>> getExpensesPerWeek(String entryType, DateTime startDate, DateTime endDate) async {
    final db = await _getDatabase();

    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m-%W', datetime(millisSinceEpoch / 1000, 'unixepoch')) AS week,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpoch / 1000, 'unixepoch') BETWEEN ? AND ?
        AND
        type = ?
      GROUP BY
        week, category
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );

    return List.generate(maps.length, (i) {
      return ExpenseGroup(
        groupAggregate: maps[i]['week'] as String,
        category: maps[i]['category'] as String,
        aggregatedValue: maps[i]['totalValue'] as double
      );
    });
  }

  Future<List<ExpenseGroup>> getExpensesPerDay(String entryType, DateTime startDate, DateTime endDate) async {
    final db = await _getDatabase();

    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m-%d', datetime(millisSinceEpoch / 1000, 'unixepoch')) AS day,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpoch / 1000, 'unixepoch') BETWEEN ? AND ?
        AND
        type = ?
      GROUP BY
        day, category
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );

    return List.generate(maps.length, (i) {
      return ExpenseGroup(
        groupAggregate: maps[i]['day'] as String,
        category: maps[i]['category'] as String,
        aggregatedValue: maps[i]['totalValue'] as double
      );
    });
  }

}