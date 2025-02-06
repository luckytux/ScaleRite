import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ✅ Required for Windows/Linux support

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // ✅ Required for Windows/Linux support
      databaseFactory = databaseFactoryFfi;

      String dbPath = await getDatabasesPath();
      print('📂 Database Path: $dbPath'); // Debugging database path

      return await openDatabase(
        join(dbPath, 'companies.db'),
        version: 1,
        onCreate: (db, version) async {
          print('✅ Creating database table...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS companies (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              business_name TEXT NOT NULL,
              customer_name TEXT NOT NULL,
              address TEXT,
              city TEXT,
              province TEXT,
              postal_code TEXT,
              phone_number TEXT,
              invoice_email TEXT,
              report_email TEXT,
              notes TEXT
            )
          ''');
        },
      );
    } catch (e) {
      print('❌ Database Initialization Error: $e');
      rethrow;
    }
  }

  // ✅ Insert a new customer
  Future<int> insertCompany(Map<String, dynamic> company) async {
    try {
      final db = await database;
      int id = await db.insert(
        'companies',
        company,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Customer Inserted: ID $id');
      return id;
    } catch (e) {
      print('❌ Error inserting customer: $e');
      throw Exception('Error inserting customer: $e');
    }
  }

  // ✅ Update an existing customer
  Future<void> updateCompany(Map<String, dynamic> company) async {
    if (!company.containsKey('id')) {
      throw Exception('ID is required for updating a company');
    }

    try {
      final db = await database;
      await db.update(
        'companies',
        company,
        where: 'id = ?',
        whereArgs: [company['id']],
      );
      print('✅ Customer Updated: ID ${company['id']}');
    } catch (e) {
      print('❌ Error updating company: $e');
      throw Exception('Error updating company: $e');
    }
  }

  // ✅ Delete a customer by ID
  Future<void> deleteCompany(int id) async {
    try {
      final db = await database;
      await db.delete(
        'companies',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('🗑️ Customer Deleted: ID $id');
    } catch (e) {
      print('❌ Error deleting company: $e');
      throw Exception('Error deleting company: $e');
    }
  }

  // ✅ Search companies by name
  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      final db = await database;
      return db.query(
        'companies',
        where: 'business_name LIKE ? OR customer_name LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
    } catch (e) {
      print('❌ Error searching companies: $e');
      throw Exception('Error searching companies: $e');
    }
  }

  // ✅ Fetch all companies
  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    try {
      final db = await database;
      return db.query('companies');
    } catch (e) {
      print('❌ Error fetching companies: $e');
      throw Exception('Error fetching companies: $e');
    }
  }
}
