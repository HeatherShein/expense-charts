import 'dart:io';

import 'package:expenses_charts/components/database_helper.dart';
import 'package:expenses_charts/models/expenses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> exportDatabase(BuildContext context) async {
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
    await File(databasePath).copy(destinationPath);

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text("Database exported successfully !"),
      )
    );
  } catch (e) {
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
  try {
    // Prompt the user to select the database file
    debugPrint("SELECTING FILE");
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
              millisSinceEpoch: row['millisSinceEpoch'],
              type: row['type'],
              category: row['category'],
              label: row['label'],
              value: row['value']
            )
          );
        }
      }
    });

    // Show a success message
    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text("Database imported successfully !"),
      )
    );
  } catch (e) {
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
          )
        ];
      },
      onSelected: (value) {
        if (value == 'export_database') {
          // Handle export database action
          exportDatabase(context);
        } else if (value == 'import_database') {
          importDatabase(context);
        }
      },
    );
  }
}