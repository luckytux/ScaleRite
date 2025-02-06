import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Corrected import for API service
import 'customer_detail.dart'; // Corrected import for customer details page


class CustomerLookupPage extends StatefulWidget {
  const CustomerLookupPage({super.key});

  @override
  State<CustomerLookupPage> createState() => _CustomerLookupPageState();
}

class _CustomerLookupPageState extends State<CustomerLookupPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await apiService.getCustomers();
      final filteredResults = results.where((customer) {
        return customer['business_name'].toLowerCase().contains(query.toLowerCase()) ||
               customer['customer_name'].toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        _searchResults = filteredResults;
      });
    } catch (e) {
      _showError('Error fetching customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectCustomer(Map<String, dynamic> customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
                      title: Text(customer['business_name']),
                      subtitle: Text('${customer['customer_name']} - ${customer['city']}'),
                      onTap: () => _selectCustomer(customer),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
