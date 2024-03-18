import 'package:expenses_charts/pages/widget_tree.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const MaterialApp(
        title: 'Budget Tracker',
        home: WidgetTreePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}