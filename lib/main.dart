import 'package:expenses_charts/pages/widget_tree.dart';
import 'package:expenses_charts/providers/budget_provider.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Main entry point of the Money Tracker application
/// 
/// Initializes the SQLite database and sets up the app with providers
/// for state management (Settings and Budget).
Future main() async {
  // Initialize SQLite for desktop platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

/// Root widget of the Money Tracker application
/// 
/// Configures the app with Material Design 3 theme and providers
/// for state management across the entire application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Setup providers for state management
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: 'Money Tracker',
        home: const WidgetTreePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 9, 26, 180),
            brightness: Brightness.light
          ),
          cardColor: const Color.fromARGB(73, 9, 169, 180)
        ),
      ),
    );
  }
}