import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/expense_entry.dart';

class ExpenseDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note TEXT,
            amount REAL,
            isCredit INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertEntry(ExpenseEntry entry) async {
    final db = await database;
    await db.insert(
      'entries',
      {
        'note': entry.note,
        'amount': entry.amount,
        'isCredit': entry.isCredit ? 1 : 0,
        'date': entry.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ExpenseEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries', orderBy: 'date DESC');

    return maps.map((e) {
      return ExpenseEntry(
        note: e['note'],
        amount: e['amount'],
        isCredit: e['isCredit'] == 1,
        date: DateTime.parse(e['date']),
      );
    }).toList();
  }
}
