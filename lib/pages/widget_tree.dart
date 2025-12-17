import 'package:device_info_plus/device_info_plus.dart';
import 'package:expenses_charts/utils/expense_utils.dart';
import 'package:expenses_charts/pages/details.dart';
import 'package:expenses_charts/pages/expense_graph.dart';
import 'package:expenses_charts/pages/expense_pie.dart';
import 'package:expenses_charts/pages/summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:permission_handler/permission_handler.dart';

final _formKey = GlobalKey<FormBuilderState>();

class WidgetTreePage extends StatefulWidget {
  const WidgetTreePage({super.key});

  @override
  State<WidgetTreePage> createState() => _WidgetTreePageState();
}

class _WidgetTreePageState extends State<WidgetTreePage> {

  int _selectedIndex = 0;

  // Bottom menu with pages
  static const List<Widget> _widgetOptions = <Widget>[
    ExpenseGraphPage(),
    ExpensePiePage(),
    SummaryPage(),
    DetailsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // When first installed, the app requires permission to store data
  Future<PermissionStatus> requestStoragePermission() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: requestStoragePermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          PermissionStatus? status = snapshot.data;
          if (status!.isGranted) { 
            // Got authorization
            return Scaffold(
              body: Stack(
                children: <Widget>[
                  Center(child: _widgetOptions.elementAt(
                    _selectedIndex
                  )),
                ]
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                shape: const CircleBorder(),
                onPressed: () {
                  // Don't set state, just click the button
                  DateTime today = DateTime.now();
                  int millisSinceEpochStart = DateTime(today.year, today.month, today.day, 10).millisecondsSinceEpoch;
                  ExpenseUtils.showExpenseDialog(
                    isNewExpense: true,
                    context: context, 
                    millisSinceEpochStart: millisSinceEpochStart,
                    millisSinceEpochEnd: millisSinceEpochStart, 
                    type: "expense", 
                    category: "grocery", 
                    label: "", 
                    value: "", 
                    currency: "EUR", 
                    isLongExpense: false, 
                    formKey: _formKey, 
                    refreshCallback: () { setState(() {}); }
                  );
                },
                child: const Icon(Icons.add_rounded),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: 'Evolution'),
                  BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline_rounded), label: 'Distribution'),
                  BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Summary'),
                  BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted_rounded), label: 'Details'),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                onTap: _onItemTapped,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            );
          } else {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("Allow Storage"),
                      onPressed: () async {
                        PermissionStatus status = await requestStoragePermission();
                        if (status.isGranted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    );
  }
}