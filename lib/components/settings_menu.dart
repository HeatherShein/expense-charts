import 'dart:io';

import 'package:cr_file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

final _formKey = GlobalKey<FormBuilderState>();

Future<void> exportDatabase(BuildContext context) async {
  /**
   * Exports the database to a selected destination.
   */

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16,),
            Text("Exporting database ...")
          ],
        ),
      );
    }
  );

  try {
    // Get the source database file
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = join(documentsDirectory.path, 'expense_database.db');

    // Prompt the user to select the destination directory
    String? destinationDir = await FilePicker.platform.getDirectoryPath();
    if (destinationDir == null) {
      // User canceled the operation
      return;
    }
    // Set the destination file path
    String destinationPath = path.join(destinationDir, 'exported_database.db');

    // Copy the database file to the destination directory
    await CRFileSaver.saveFile(
      databasePath,
      destinationFileName: destinationPath,
    );

    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text("Database exported successfully !"),
      )
    );
  } on PlatformException catch (e) {
    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error exporting the database : $e !"),
      )
    );
  }
}

Future<void> importDatabase(BuildContext context) async {
  /**
   * Import a database, merging with existing one.
   */

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16,),
            Text("Importing database ...")
          ],
        ),
      );
    }
  );

  try {
    // Prompt the user to select the database file
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.any,
    ).then((result) => result?.files.single.path);

    if (filePath == null) {
      // User canceled file selection
      return;
    }

    // Open the selected database file
    Database importedDatabase = await openDatabase(filePath);

    DatabaseHelper dbHelper = DatabaseHelper();
    
    // Merge the databases (Example: using a transaction)
    int counter = 0;
    await importedDatabase.transaction((txn) async {
      // Retrieve data from the imported database
      List<Map<String, dynamic>> importedData = await txn.query('expenses');

      // Merge data with the existing database
      for (var row in importedData) {
        // Check if the row already exists in the existing database
        bool rowExists = await dbHelper.existsInExistingDatabase(row);
        if (!rowExists) {
          dbHelper.insertExpense(
            Expense(
              millisSinceEpochStart: row['millisSinceEpochStart'],
              millisSinceEpochEnd: row['millisSinceEpochEnd'] ?? row['millisSinceEpochStart'],
              type: row['type'],
              category: row['category'],
              label: row['label'],
              value: row['value']
            )
          );
          counter++;
        }
      }
    });

    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Database imported successfully ! (${counter.toString()} rows)"),
      )
    );
  } catch (e) {
    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error importing the database : $e !"),
      )
    );
  }
}

String _generateCsvRow(Iterable<dynamic> values) {
  // Convert each value to CSV format and join them with commas
  return '${values.map((value) => '"$value"').join(',')}\n';
}

Future<void> preExportCsv(BuildContext context) async {
  /**
   * Asks the user for date range before exporting csv.
   */

  DateTime startDate;
  DateTime endDate;

  // Show loading dialog
  showDialog(
    context: context, 
    builder: (BuildContext context) {
      SettingsProvider settingsState = context.watch<SettingsProvider>();
      return AlertDialog(
        title: const Text("Select date range"),
        content: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderDateTimePicker(
                name: "start_date",
                decoration: const InputDecoration(
                  labelText: "Start date",
                  hintText: "Pick a start date",
                ),
                initialValue: settingsState.startDate,
                initialDate: settingsState.startDate,
              ),
              FormBuilderDateTimePicker(
                name: "end_date",
                decoration: const InputDecoration(
                  labelText: "End date",
                  hintText: "Pick an end date",
                ),
                initialValue: settingsState.endDate,
                initialDate: settingsState.endDate,
              ),
              const SizedBox(height: 10.0,),
              MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  _formKey.currentState?.saveAndValidate();
                  var formValues = _formKey.currentState?.value;
                  startDate = formValues?['start_date'];
                  endDate = formValues?['end_date'];
                  exportCsv(context, startDate, endDate);
                  // Dismiss loading dialog
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text(
                  "Confirm dates"
                ),
              )
            ],
          )
        ),
      );
    }
  );
}

Future<void> exportCsv(BuildContext context, DateTime startDate, DateTime endDate) async {
  /**
   * Exports the database to a selected destination as a CSV.
   */

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16,),
            Text("Exporting database as CSV ...")
          ],
        ),
      );
    }
  );

  try {
    DatabaseHelper dbHelper = DatabaseHelper();
    // Get expenses
    List<Expense> expenses = await dbHelper.getExpensesWithDates(startDate, endDate);

    // Prompt the user to select the destination directory
    String? destinationDir = await FilePicker.platform.getDirectoryPath();
    if (destinationDir == null) {
      // User canceled the operation
      return;
    }
    // Set the destination file path
    String destinationPath = path.join(destinationDir, 'exported_database.csv');

    // Create a File object
    File exportedFile = File(destinationPath);

    // Open the file in write mode
    var sink = exportedFile.openWrite();

    // Write the header
    sink.write("id,millisSinceEpochStart,millisSinceEpochEnd,type,category,label,value\n");

    // Write each row of data
    for (Expense expense in expenses) {
      sink.write(
        _generateCsvRow(
          [
            expense.id,
            expense.millisSinceEpochStart,
            expense.millisSinceEpochEnd,
            expense.type,
            expense.category,
            expense.label,
            expense.value,
          ]
        )
      );
    }

    // Close file
    sink.close();

    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text("Database exported as CSV successfully !"),
      )
    );
  } catch (e) {
    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error exporting the database as CSV : $e !"),
      )
    );
  }
}

Future<void> importCsv(BuildContext context) async {
  /**
   * Import a database as a csv, merging with existing one.
   */

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16,),
            Text("Importing database as CSV ...")
          ],
        ),
      );
    }
  );

  try {
    DatabaseHelper dbHelper = DatabaseHelper();
    // Prompt the user to select the database file
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.any,
    ).then((result) => result?.files.single.path);

    if (filePath == null) {
      // User canceled file selection
      return;
    }

    // Open the selected csv file
    File importedCsv = File(filePath);
    String contents = await importedCsv.readAsString();

    // Parse the CSV data
    List<List<dynamic>> rows = const CsvToListConverter().convert(
      contents,
      eol: "\n"
    );

    // Convert each row to a map
    List<Map<String, dynamic>> csvData = [];
    List<dynamic> csvKeys = rows[0];
    for (int i = 1; i < rows.length; i++) {
      Map<String, dynamic> rowData = {};
      for (int j = 0; j < rows[i].length; j++) {
        rowData[csvKeys[j]] = rows[i][j];
      }
      csvData.add(rowData);
    }

    // Iterate over each row in the CSV data
    int counter = 0;
    for (var row in csvData) {
      // Check if the row exists in the database
      bool rowExists = await dbHelper.existsInExistingDatabase(row);

      // If the row doesn't exist, insert it into the database
      if (!rowExists) {
        dbHelper.insertExpense(
          Expense(
            millisSinceEpochStart: row['millisSinceEpochStart'],
            millisSinceEpochEnd: row['millisSinceEpochEnd'],
            type: row['type'],
            category: row['category'],
            label: row['label'],
            value: row['value']
          )
        );
        counter++;
      }
    }

    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Database imported successfully ! ($counter rows)"),
      )
    );
  } catch (e) {
    // Dismiss loading dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error importing the database : $e !"),
      )
    );
  }
}

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'export_database',  
            child: Text("Export database"),
          ),
          const PopupMenuItem(
            value: 'import_database',  
            child: Text("Import database"),
          ),
          const PopupMenuItem(
            value: 'export_csv',  
            child: Text("Export CSV"),
          ),
          const PopupMenuItem(
            value: 'import_csv',  
            child: Text("Import CSV"),
          ),
        ];
      },
      onSelected: (value) {
        switch (value) {
          case 'export_database':
            exportDatabase(context);
            break;
          case 'import_database':
            importDatabase(context);
          case 'export_csv':
            preExportCsv(context);
            break;
          case 'import_csv':
            importCsv(context);
          default:
            break;
        }
      },
    );
  }
}