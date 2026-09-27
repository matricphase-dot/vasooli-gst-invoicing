// End-to-end smoke test: talks to the running server over HTTP on :8080.
// Run: cd vasooli_client && dart run tool/smoke.dart
import 'package:vasooli_client/src/protocol/invoice_line.dart';
import 'package:vasooli_client/vasooli_client.dart';

void main() async {
  final client = Client('http://localhost:8080/');
  final invoice = await client.invoices.createInvoice(
    clientName: 'Smoke Test Client',
    supplierStateCode: 27,
    placeOfSupplyStateCode: 27,
    financialYear: '2026-27',
    lines: [
      InvoiceLine(
        description: 'Smoke test consulting hour',
        hsnSac: '9983',
        taxableValue: 1000,
        gstRatePercent: 18,
      ),
    ],
  );
  final paid = await client.invoices.markPaid(invoice.id!);
  print(
    'SMOKE OK: invoice #${invoice.invoiceNumber} '
    'grand=${invoice.grandTotal} cgst=${invoice.cgst} sgst=${invoice.sgst} '
    'status=${paid.status}',
  );
}
