import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'models/expense_entry.dart';
import 'providers/expense_provider.dart';
import 'utils/pdf_generator.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const ETrackApp(),
    ),
  );
}

class ETrackApp extends StatelessWidget {
  const ETrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Etrack',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ExpenseInputScreen(),
    HistoryScreen(),
    MonthlyViewScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Input'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Monthly'),
        ],
      ),
    );
  }
}

class ExpenseInputScreen extends StatefulWidget {
  const ExpenseInputScreen({super.key});

  @override
  State<ExpenseInputScreen> createState() => _ExpenseInputScreenState();
}

class _ExpenseInputScreenState extends State<ExpenseInputScreen> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isCredit = false;

  void _addEntry() {
    final note = _noteController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (note.isEmpty || amount <= 0) return;

    final entry = ExpenseEntry(
      date: DateTime.now(),
      note: note,
      amount: amount,
      isCredit: _isCredit,
    );

    Provider.of<ExpenseProvider>(context, listen: false).addEntry(entry);

    _noteController.clear();
    _amountController.clear();
    setState(() => _isCredit = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy').format(today);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Date: $dateStr", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Type: '),
              Switch(
                value: _isCredit,
                onChanged: (val) => setState(() => _isCredit = val),
              ),
              Text(_isCredit ? 'Credit' : 'Debit'),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              onPressed: _addEntry,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Map<String, List<ExpenseEntry>> _groupByMonth(List<ExpenseEntry> entries) {
    final Map<String, List<ExpenseEntry>> map = {};
    for (var e in entries) {
      final m = DateFormat('MMMM yyyy').format(e.date);
      map.putIfAbsent(m, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<ExpenseProvider>(context).entries;
    final grouped = _groupByMonth(entries);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: grouped.entries.map((grp) {
        final month = grp.key;
        final items = grp.value;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...items.map((e) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          e.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: e.isCredit ? Colors.green : Colors.red,
                        ),
                        title: Text(e.note),
                        subtitle: Text(DateFormat('dd MMM yyyy').format(e.date)),
                        trailing: Text(
                          '₹${e.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: e.isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => PDFGenerator.generateMonthlyReport(month, items),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MonthlyViewScreen extends StatefulWidget {
  const MonthlyViewScreen({super.key});

  @override
  State<MonthlyViewScreen> createState() => _MonthlyViewScreenState();
}

class _MonthlyViewScreenState extends State<MonthlyViewScreen> {
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<ExpenseProvider>(context).entries;
    final grouped = <String, List<ExpenseEntry>>{};
    for (var e in entries) {
      final m = DateFormat('MMMM yyyy').format(e.date);
      grouped.putIfAbsent(m, () => []).add(e);
    }
    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final current = _selectedMonth != null ? grouped[_selectedMonth!]! : [];

    final totalCredit = current.where((e) => e.isCredit).fold(0.0, (sum, e) => sum + e.amount);
    final totalDebit = current.where((e) => !e.isCredit).fold(0.0, (sum, e) => sum + e.amount);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('Select Month'),
            value: _selectedMonth,
            isExpanded: true,
            items: months
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMonth = v),
          ),
          const SizedBox(height: 24),
          if (_selectedMonth != null)
            Expanded(
              child: Column(
                children: [
                  Text('Credit vs Debit', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: totalCredit,
                            color: Colors.green,
                            title: 'Credit\n₹${totalCredit.toStringAsFixed(0)}',
                            radius: 70,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: totalDebit,
                            color: Colors.red,
                            title: 'Debit\n₹${totalDebit.toStringAsFixed(0)}',
                            radius: 70,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(child: Center(child: Text("Select a month to view chart"))),
        ],
      ),
    );
  }
}
