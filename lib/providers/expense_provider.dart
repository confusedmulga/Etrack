import 'package:flutter/material.dart';
import '../models/expense_entry.dart';
import '../db/expense_db.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseEntry> _entries = [];

  List<ExpenseEntry> get entries => _entries;

  ExpenseProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    _entries = await ExpenseDB.getEntries();
    notifyListeners();
  }

  Future<void> addEntry(ExpenseEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await ExpenseDB.insertEntry(entry);
  }
}
