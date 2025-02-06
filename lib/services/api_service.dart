import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; // Update if needed

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await http.get(Uri.parse("$baseUrl/customers"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load customers");
    }
  }
}
