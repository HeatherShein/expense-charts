import 'package:expenses_charts/models/expenses.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {

  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper(){
    /**
     * DatabaseHelper factory.
     * Ensures object unicity.
     */
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    /**
     * Main database getter.
     */
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<void> deleteDatabase() async {
    /**
     * To delete database.
     */
    databaseFactory.deleteDatabase(join(await getDatabasesPath(), 'expense_database.db'));
  }

  Future _initializeDatabase() async {
    /**
     * If needed, creates the database.
     */
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = join(documentsDirectory.path, 'expense_database.db');

    return await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            millisSinceEpochStart INTEGER, 
            millisSinceEpochEnd INTEGER,
            type TEXT, 
            category TEXT, 
            label TEXT, 
            value REAL
          )
        ''');
      },
      version: 2,
      onUpgrade: _upgradeDatabase
    );
  }

  Future<int> getIdFromValues(
    int millisSinceEpochStart, 
    int millisSinceEpochEnd, 
    String type, 
    String category, 
    String label, 
    double value
  ) async {
    /**
     * Retrieves ID from other values.
     * Assumes one expense can be fully defined its variables. Bold assumption, can fail.
     */
    final db = await _getDatabase();
    // Query expenses table to find it.
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      columns: ['id'],
      where: 'millisSinceEpochStart = ? AND millisSinceEpochEnd = ? AND type = ? AND category = ? AND label = ? AND value = ?',
      whereArgs: [millisSinceEpochStart, millisSinceEpochEnd, type, category, label, value]
    );
    // Fails if more than one result.
    if (maps.length == 1) {
      return maps[0]['id'] as int;
    } else {
      throw Exception("Error : multiple ids for this query");
    }
  }

  Future<void> insertExpense(Expense expense) async {
    /**
     * Inserts/Replaces an expense into the table.
     */
    final db = await _getDatabase();
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(int expenseId, Expense newExpense) async {
    /**
     * Updates an expense based on expenseId.
     */
    final db = await _getDatabase();
    await db.update(
      'expenses', 
      newExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expenseId]
    );
  }

  Future<void> deleteExpense(
    int millisSinceEpochStart, 
    int millisSinceEpochEnd, 
    String type, 
    String category, 
    String label, 
    double value
  ) async {
    /**
     * Deletes an expense based on its variables.
     * Can multiple delete if multiple exact same rows.
     */
    final db = await _getDatabase();
    await db.delete(
      'expenses',
      where: 'millisSinceEpochStart = ? AND millisSinceEpochEnd = ? AND type = ? AND category = ? AND label = ? AND value = ?',
      whereArgs: [millisSinceEpochStart, millisSinceEpochEnd, type, category, label, value],
    );
  }

  Future<List<Expense>> expenses() async {
    /**
     * Query every expenses.
     */
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int, 
        millisSinceEpochStart: maps[i]['millisSinceEpochStart'] as int, 
        millisSinceEpochEnd: maps[i]['millisSinceEpochEnd'] as int, 
        type: maps[i]['type'] as String, 
        category: maps[i]['category'] as String,
        label: maps[i]['label'] as String,
        value: maps[i]['value'] as double,
      );
    });
  }

  Future<List<Expense>> getLatestExpenses(int n) async {
    /**
     * Fetchs n latest expenses.
     */
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: "millisSinceEpochStart DESC",
      limit: n
    );
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int, 
        millisSinceEpochStart: maps[i]['millisSinceEpochStart'] as int, 
        millisSinceEpochEnd: maps[i]['millisSinceEpochEnd'] as int, 
        type: maps[i]['type'] as String, 
        category: maps[i]['category'] as String,
        label: maps[i]['label'] as String,
        value: maps[i]['value'] as double,
      );
    });
  }

  /*
  Future<List<ExpenseGroup>> getExpensesPerYear(String entryType, DateTime startDate, DateTime endDate) async {
    final db = await _getDatabase();

    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        strftime('%Y', datetime(millisSinceEpochStart / 1000, 'unixepoch')) AS year,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpochStart / 1000, 'unixepoch') >= date(?)
        AND
        datetime(millisSinceEpochStart / 1000, 'unixepoch') < date(?, '+1 day')
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
        strftime('%Y-%m', datetime(millisSinceEpochStart / 1000, 'unixepoch')) AS month,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpochStart / 1000, 'unixepoch') >= date(?)
        AND
        datetime(millisSinceEpochStart / 1000, 'unixepoch') < date(?, '+1 day')
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
        strftime('%Y-%m-%W', datetime(millisSinceEpochStart / 1000, 'unixepoch')) AS week,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpochStart / 1000, 'unixepoch') >= date(?)
        AND
        datetime(millisSinceEpochStart / 1000, 'unixepoch') < date(?, '+1 day')
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
        strftime('%Y-%m-%d', datetime(millisSinceEpochStart / 1000, 'unixepoch')) AS day,
        category,
        SUM(value) AS totalValue
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpochStart / 1000, 'unixepoch') >= date(?)
        AND
        datetime(millisSinceEpochStart / 1000, 'unixepoch') < date(?, '+1 day')
        AND
        type = ?
      GROUP BY
        day, category
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );

    return List.generate(maps.length, (i) {
      //debugPrint("${maps[i]['day']} : ${maps[i]['category']} / ${maps[i]['totalValue']}");
      return ExpenseGroup(
        groupAggregate: maps[i]['day'] as String,
        category: maps[i]['category'] as String,
        aggregatedValue: maps[i]['totalValue'] as double
      );
    });
  }
  */

  Future<List<Map<String, dynamic>>> getExpenseOverPeriod(String entryType, DateTime startDate, DateTime endDate) async {
    /**
     * Gets every expense based on entryType over a specific period.
     */
    final db = await _getDatabase();
    // Reformat dates
    String formattedStartDate = startDate.toIso8601String();
    String formattedEndDate = endDate.toIso8601String();
    // Query data over a specific period
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        datetime(millisSinceEpochStart / 1000, 'unixepoch') AS startDate,
        datetime(millisSinceEpochEnd / 1000, 'unixepoch') AS endDate,
        category,
        value
      FROM 
        expenses
      WHERE
        datetime(millisSinceEpochStart / 1000, 'unixepoch') >= date(?)
        AND
        datetime(millisSinceEpochStart / 1000, 'unixepoch') < date(?, '+1 day')
        AND
        type = ?
      ''',
      [formattedStartDate, formattedEndDate, entryType],
    );
    return maps;
  }

  Future<bool> existsInExistingDatabase(Map<String, dynamic> row) async {
    /**
     * Checks if row already exists in database.
     * Must have the exact same values.
     */
    final db = await _getDatabase();
    int? count = Sqflite.firstIntValue(await db.rawQuery(
      '''
      SELECT 
        COUNT(*) 
      FROM 
        expenses 
      WHERE 
        id = ? 
        AND millisSinceEpochStart = ?
        AND millisSinceEpochEnd = ?
        AND type = ?
        AND category = ?
        AND label = ?
        AND value = ?
      ''',
      [
        row['id'], 
        row['millisSinceEpochStart'],
        row['millisSinceEpochEnd'],
        row['type'],
        row['category'],
        row['label'],
        row['value']
      ],
    ));
    return count! > 0;
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    /**
     * Script to upgrade database.
     * Version 1 --> 2 : column renaming and adding millisSinceEpochEnd
     */
    if (oldVersion < 2) {
      db.execute('ALTER TABLE expenses RENAME COLUMN millisSinceEpoch TO millisSinceEpochStart');
      db.execute('ALTER TABLE expenses ADD millisSinceEpochEnd INTEGER');
      final List<Map<String, dynamic>> rows = await db.query('expenses');
      for (final row in rows) {
        final expense = Expense(
          id: row['id'],
          millisSinceEpochStart: row['millisSinceEpochStart'],
          millisSinceEpochEnd: row['millisSinceEpochStart'],
          type: row['type'],
          category: row['category'],
          label: row['label'],
          value: row['value'],
        );

        await db.insert('expenses', expense.toMap());
      }
    }
  }

}