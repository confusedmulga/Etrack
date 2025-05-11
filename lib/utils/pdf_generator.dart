import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/expense_entry.dart';

class PDFGenerator {
  static Future<void> generateMonthlyReport(
    String monthTitle,
    List<ExpenseEntry> entries,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Monthly Report: $monthTitle',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Note', 'Amount', 'Type'],
                data: entries.map((e) {
                  return [
                    "${e.date.day}/${e.date.month}/${e.date.year}",
                    e.note,
                    e.amount.toStringAsFixed(2),
                    e.isCredit ? 'Credit' : 'Debit',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
