class ExpenseEntry {
  final DateTime date;
  final String note;
  final double amount;
  final bool isCredit;

  ExpenseEntry({
    required this.date,
    required this.note,
    required this.amount,
    required this.isCredit,
  });
}
