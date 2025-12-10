import 'dart:io';

import 'package:csv/csv.dart';
import 'package:expenses_charts/constants/categories.dart';
import 'package:expenses_charts/utils/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

final _formKey = GlobalKey<FormBuilderState>();
final _exportFilenameKey = GlobalKey<FormBuilderState>();

Future<String?> _showFilenameDialog(BuildContext context, String defaultFilename, String fileExtension) async {
  String? filename;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter filename'),
        content: FormBuilder(
          key: _exportFilenameKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: "filename",
                decoration: InputDecoration(
                  labelText: "Filename",
                  hintText: defaultFilename,
                  suffixText: '.$fileExtension',
                ),
                initialValue: defaultFilename.replaceAll('.$fileExtension', ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a filename';
                  }
                  if (value.contains('/') || value.contains('\\')) {
                    return 'Filename cannot contain path separators';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_exportFilenameKey.currentState?.saveAndValidate() ?? false) {
                final formValues = _exportFilenameKey.currentState?.value;
                filename = formValues?['filename'] as String?;
                Navigator.pop(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  return filename;
}

Future<void> exportDatabase(BuildContext context) async {
  /**
   * Exports the database to a selected destination with user-specified filename.
   */

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

    // Prompt the user for filename
    String? filename = await _showFilenameDialog(context, 'expense_database.db', 'db');
    if (filename == null || filename.isEmpty) {
      // User canceled or didn't enter filename
      return;
    }

    // Ensure filename has the correct extension
    if (!filename.endsWith('.db')) {
      filename = '$filename.db';
    }

    // Set the destination file path
    String destinationPath = path.join(destinationDir, filename);

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
      // Copy the database file to the destination
      await File(databasePath).copy(destinationPath);

      // Dismiss loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Show a success message
      // ignore: use_build_context_synchronously
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text("Database exported successfully to $filename!"),
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
  } catch (e) {
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error selecting export location: $e"),
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
        var millisSinceEpochEnd = row['millisSinceEpochEnd'] ?? row['millisSinceEpochStart'];
        if (!rowExists) {
          dbHelper.insertExpense(
            Expense(
              millisSinceEpochStart: row['millisSinceEpochStart'] is int 
                ? row['millisSinceEpochStart'] 
                : int.parse(row['millisSinceEpochStart'].toString()),
              millisSinceEpochEnd: millisSinceEpochEnd is int 
                ? millisSinceEpochEnd 
                : int.parse(millisSinceEpochEnd.toString()),
              type: row['type'].toString(),
              category: row['category'].toString(),
              label: row['label'].toString(),
              value: row['value'] is double 
                ? row['value'] 
                : double.parse(row['value'].toString())
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
   * Exports the database to a selected destination as a CSV with proper formatting.
   * Uses the same format as the Python data_process.py script.
   * Allows user to specify the filename.
   */

  try {
    // Prompt the user to select the destination directory
    String? destinationDir = await FilePicker.platform.getDirectoryPath();
    if (destinationDir == null) {
      // User canceled the operation
      return;
    }

    // Prompt the user for filename
    String? filename = await _showFilenameDialog(context, 'expenses.csv', 'csv');
    if (filename == null || filename.isEmpty) {
      // User canceled or didn't enter filename
      return;
    }

    // Ensure filename has the correct extension
    if (!filename.endsWith('.csv')) {
      filename = '$filename.csv';
    }

    // Set the destination file path
    String destinationPath = path.join(destinationDir, filename);

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

      // Create a File object
      File exportedFile = File(destinationPath);

      // Open the file in write mode
      var sink = exportedFile.openWrite();

      // Write the header in the correct format
      sink.write("Date,Intitulé,Montant,Type,Revenu/Dépense\n");

      // Write each row of data with proper formatting
      for (Expense expense in expenses) {
        // Format date as MM/DD/YYYY
        String formattedDate = DateFormat('MM/dd/yyyy').format(
          DateTime.fromMillisecondsSinceEpoch(expense.millisSinceEpochStart)
        );
        
        // Convert type: expense = -1, income = 1
        String typeValue = expense.type == 'expense' ? '-1' : '1';
        
        // Get French category name
        String frenchCategory = ExpenseCategories.getCsvName(expense.category);
        
        sink.write(
          _generateCsvRow([
            formattedDate,
            expense.label,
            expense.value.toString(),
            frenchCategory,
            typeValue,
          ])
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
        SnackBar(
          content: Text("Database exported as CSV successfully! File saved as '$filename'"),
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
          content: Text("Error exporting the database as CSV: $e"),
        )
      );
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Error selecting export location: $e"),
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
      var millisSinceEpochEnd = row['millisSinceEpochEnd'] ?? row['millisSinceEpochStart'];

      // If the row doesn't exist, insert it into the database
      if (!rowExists) {
        dbHelper.insertExpense(
          Expense(
            millisSinceEpochStart: row['millisSinceEpochStart'] is String ? int.parse(row['millisSinceEpochStart']): row['millisSinceEpochStart'],
            millisSinceEpochEnd: millisSinceEpochEnd is String ? int.parse(millisSinceEpochEnd): millisSinceEpochEnd,
            type: row['type'],
            category: row['category'],
            label: row['label'],
            value: row['value'] is String ? double.parse(row['value']): row['value']
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
            break;
          case 'export_csv':
            preExportCsv(context);
            break;
          case 'import_csv':
            importCsv(context);
            break;
          default:
            break;
        }
      },
    );
  }
}