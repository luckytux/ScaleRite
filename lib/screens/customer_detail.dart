import 'package:flutter/material.dart';
import '../db_helper.dart'; // Import database helper
import 'customer_detail.dart'; // Import customer detail page

class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic>? customer;

  const CustomerDetailPage({super.key, this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late TextEditingController businessNameController;
  late TextEditingController customerNameController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController provinceController;
  late TextEditingController postalCodeController;
  late TextEditingController phoneNumberController;
  late TextEditingController invoiceEmailController;
  late TextEditingController reportEmailController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    businessNameController = TextEditingController(text: widget.customer?['business_name'] ?? '');
    customerNameController = TextEditingController(text: widget.customer?['customer_name'] ?? '');
    addressController = TextEditingController(text: widget.customer?['address'] ?? '');
    cityController = TextEditingController(text: widget.customer?['city'] ?? '');
    provinceController = TextEditingController(text: widget.customer?['province'] ?? '');
    postalCodeController = TextEditingController(text: widget.customer?['postal_code'] ?? '');
    phoneNumberController = TextEditingController(text: widget.customer?['phone_number'] ?? '');
    invoiceEmailController = TextEditingController(text: widget.customer?['invoice_email'] ?? '');
    reportEmailController = TextEditingController(text: widget.customer?['report_email'] ?? '');
    notesController = TextEditingController(text: widget.customer?['notes'] ?? '');
  }

  @override
  void dispose() {
    businessNameController.dispose();
    customerNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    phoneNumberController.dispose();
    invoiceEmailController.dispose();
    reportEmailController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    final dbHelper = DatabaseHelper.instance;
    final customerData = {
      'business_name': businessNameController.text,
      'customer_name': customerNameController.text,
      'address': addressController.text,
      'city': cityController.text,
      'province': provinceController.text,
      'postal_code': postalCodeController.text,
      'phone_number': phoneNumberController.text,
      'invoice_email': invoiceEmailController.text,
      'report_email': reportEmailController.text,
      'notes': notesController.text,
    };

    try {
      if (widget.customer == null || !widget.customer!.containsKey('id')) {
        await dbHelper.insertCompany(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New customer created successfully.')),
        );
      } else {
        await dbHelper.updateCompany({'id': widget.customer!['id'], ...customerData});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer details updated successfully.')),
        );
      }
      Navigator.pop(context, true); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving customer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer?['business_name'] ?? 'New Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Business Name', businessNameController, editable: true),
            _buildTextField('Customer Name', customerNameController, editable: true),
            _buildTextField('Address', addressController),
            _buildTextField('City', cityController),
            _buildTextField('Province', provinceController),
            _buildTextField('Postal Code', postalCodeController),
            _buildTextField('Phone Number', phoneNumberController),
            _buildTextField('Invoice Email', invoiceEmailController),
            _buildTextField('Report Email', reportEmailController),
            _buildTextField('Notes', notesController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCustomer,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: editable,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
