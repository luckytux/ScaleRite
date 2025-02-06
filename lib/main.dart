import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Ensure this is imported
import 'services/api_service.dart';
import 'screens/customer_lookup.dart'; 
import 'screens/customer_detail.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures async database services are initialized

  try {
    String dbPath = await getDatabasesPath();  // Debugging database path
    print('📂 Database Path: $dbPath');
  } catch (e) {
    print('❌ Database Initialization Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work Order App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {
        'label': 'Customer Lookup',
        'onTap': () => _navigateTo(context, const CustomerLookupPage())
      },
      {
        'label': 'Edit Existing Work Order',
        'onTap': () => _showSnackBar(context, 'Feature coming soon...')
      },
      {
        'label': 'Push All Completed Work Orders',
        'onTap': () => _showSnackBar(context, 'Pushing completed work orders...')
      },
      {
        'label': 'See Open List',
        'onTap': () => _showSnackBar(context, 'Feature coming soon...')
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Work Order App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 3.5,
          children: buttons.map((button) {
            return ElevatedButton(
              onPressed: button['onTap'],
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: Text(button['label'], textAlign: TextAlign.center),
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}