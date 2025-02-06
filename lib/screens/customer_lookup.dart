import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import API service
import 'customer_detail.dart'; // Import customer detail page
import 'dart:async';
import '../db_helper.dart'; // Local database helper

class CustomerLookupPage extends StatefulWidget {
  const CustomerLookupPage({super.key});

  @override
  State<CustomerLookupPage> createState() => _CustomerLookupPageState();
}

class _CustomerLookupPageState extends State<CustomerLookupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _syncWithRemoteDatabase();
  }

  void _syncWithRemoteDatabase() async {
    try {
      final customers = await apiService.getCustomers();
      for (var customer in customers) {
        await dbHelper.insertOrUpdateCustomer(customer);
      }
      print('✅ Local database synced with remote.');
    } catch (e) {
      print('⚠️ Sync failed: $e');
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await dbHelper.searchCompanies(query);
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching customers: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openCustomerDetail([Map<String, dynamic>? customer]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer ?? {}),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Company or Name',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final customer = _searchResults[index];
                    return ListTile(
                      title: Text(customer['business_name'] ?? 'Unknown Business'),
                      subtitle: Text('${customer['customer_name'] ?? 'Unknown'} - ${customer['city'] ?? 'Unknown'}'),
                      onTap: () => _openCustomerDetail(customer),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No matching customers found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openCustomerDetail(),
              child: const Text('Create New Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
