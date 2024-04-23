// Test for the 'utils' folder.
// Utils contains methods for expenses and databases manipulations.

import 'package:expenses_charts/models/expenses.dart';
import 'package:expenses_charts/utils/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  test("insertExpense inserts one expense successfully", () async {
    // Access DatabaseHelper
    DatabaseHelper databaseHelper = DatabaseHelper();
    const millisSinceEpochStart = 0;
    const millisSinceEpochEnd = 0;
    const type = "test";
    const category = "test";
    const label = "TEST";
    const value = 250.0;
    // Insert fake expense
    int insertedId = await databaseHelper.insertExpense(
      const Expense(
        millisSinceEpochStart: millisSinceEpochStart, 
        millisSinceEpochEnd: millisSinceEpochEnd, 
        type: type, 
        category: category, 
        label: label, 
        value: value
      )
    );
    // Test
    expect(insertedId, isA<int>());

    // Clean up
    await databaseHelper.deleteExpense(
      millisSinceEpochStart, 
      millisSinceEpochEnd, 
      type, 
      category, 
      label, 
      value
    );
  });

  test("getIdFromValues queries unique id", () {

  });
}