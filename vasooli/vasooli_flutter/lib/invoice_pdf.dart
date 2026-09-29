/// Rule-46-ready tax invoice PDF, generated client-side from the *server's*
/// numbers (the tax split is never recomputed here — it renders exactly what
/// the server validated).
library;

import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vasooli_client/vasooli_client.dart';

final _d = DateFormat('dd-MM-yyyy');
final _n = NumberFormat.decimalPattern('en_IN');

String _rs(num v) => 'Rs. ${_n.format(v)}';

const _stateNames = {
  27: 'Maharashtra',
  29: 'Karnataka',
  7: 'Delhi',
  6: 'Haryana',
  24: 'Gujarat',
  33: 'Tamil Nadu',
  36: 'Telangana',
  32: 'Kerala',
  19: 'West Bengal',
};

Future<Uint8List> buildInvoicePdf(Invoice inv) async {
  final doc = pw.Document();
  final inter = inv.igst > 0;

  pw.Widget cell(String text, {bool bold = false, pw.TextAlign? align}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : null),
        ),
      );

  pw.Widget hcell(String text, {pw.TextAlign? align}) => pw.Container(
        color: PdfColors.grey200,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text,
            textAlign: align, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TAX INVOICE',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Original for recipient', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Text('VASOOLI',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange800)),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice no: ${inv.invoiceNumber}',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Invoice date: ${_d.format(inv.issueDate)}',
                          style: const pw.TextStyle(fontSize: 10)),
                      if (inv.dueDate != null)
                        pw.Text('Due date: ${_d.format(inv.dueDate!)}',
                            style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Place of supply: ${_stateNames[inv.placeOfSupplyStateCode] ?? ''} (${inv.placeOfSupplyStateCode})',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text('Reverse charge: No', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed to:',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(inv.clientName, style: const pw.TextStyle(fontSize: 11)),
                      if (inv.clientGstin != null)
                        pw.Text('GSTIN: ${inv.clientGstin}',
                            style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1.6),
            },
            children: [
              pw.TableRow(children: [
                hcell('Description of services'),
                hcell('HSN/SAC', align: pw.TextAlign.center),
                hcell('GST %', align: pw.TextAlign.center),
                hcell('Taxable value', align: pw.TextAlign.right),
              ]),
              for (final l in inv.lines)
                pw.TableRow(children: [
                  cell(l.description),
                  cell(l.hsnSac, align: pw.TextAlign.center),
                  cell(l.gstRatePercent.toStringAsFixed(0), align: pw.TextAlign.center),
                  cell(_rs(l.taxableValue), align: pw.TextAlign.right),
                ]),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 220,
              child: pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  _sumRow('Taxable value', _rs(inv.totalTaxable)),
                  if (!inter) ...[
                    _sumRow('CGST', _rs(inv.cgst)),
                    _sumRow('SGST/UTGST', _rs(inv.sgst)),
                  ] else
                    _sumRow('IGST', _rs(inv.igst)),
                  _sumRow('Total', _rs(inv.grandTotal), bold: true),
                ],
              ),
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'Supply of services. Tax ${inter ? 'is payable under IGST' : 'split CGST/SGST per intra-state supply'}. '
            'This is a computer-generated invoice and does not require a physical signature.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Generated by Vasooli — GST-correct invoicing on Serverpod',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    ),
  );
  return doc.save();
}

pw.TableRow _sumRow(String label, String value, {bool bold = false}) =>
    pw.TableRow(
      decoration: bold ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: pw.Text(label,
              style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : null)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: pw.Text(value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : null)),
        ),
      ],
    );
