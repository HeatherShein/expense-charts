import 'package:expenses_charts/pages/details.dart';
import 'package:expenses_charts/pages/expense_graph.dart';
import 'package:expenses_charts/pages/expense_pie.dart';
import 'package:expenses_charts/pages/expense_stats.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
    ExpenseStatsPage(),
    DetailsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // When first installed, the app requires permission to store data
  Future<PermissionStatus> requestStoragePermission() async {
    var status = await Permission.storage.request();
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
          if (status!.isGranted || status.isDenied) { // FIXME : should never be isDenied, but my second phone works while denying for some reasons.
            // Got authorization
            return Scaffold(
              body: Center(child: _widgetOptions.elementAt(
                _selectedIndex
              )),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: 'Graph'),
                  BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline_rounded), label: 'Pie'),
                  BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart_outlined), label: 'Stats'),
                  BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted_rounded), label: 'Details'),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.blueGrey,
                onTap: _onItemTapped,
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