import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tax.dart';

class InvoicesEndpoint extends Endpoint {
  /// Creates an invoice with server-side tax math and a sequential,
  /// per-financial-year invoice number.
  ///
  /// The client never supplies the number or the tax amounts: both are
  /// computed here so they cannot be bypassed or faked from the app.
  Future<Invoice> createInvoice(
    Session session, {
    required String clientName,
    String? clientGstin,
    required int supplierStateCode,
    required int placeOfSupplyStateCode,
    required String financialYear, // e.g. "2026-27"
    required List<InvoiceLine> lines,
  }) async {
    if (clientGstin != null && !isValidGstin(clientGstin)) {
      throw InvalidGstinException(
        message: 'GSTIN "$clientGstin" failed format or check-digit '
            'validation — one of its 15 characters is mistyped',
      );
    }

    final breakup = computeTax(
      lines: lines
          .map((l) => (taxableValue: l.taxableValue, ratePercent: l.gstRatePercent))
          .toList(),
      supplierStateCode: supplierStateCode,
      placeOfSupplyStateCode: placeOfSupplyStateCode,
    );

    // Sequential per FY. NOTE for later: count+1 is fine for a skeleton but
    // is not concurrency-safe; replace with a SELECT ... FOR UPDATE counter
    // row before the demo if two devices create invoices at once.
    final existing = await Invoice.db.count(
      session,
      where: (t) => t.financialYear.equals(financialYear),
    );
    final number = '${existing + 1}';
    if (!isValidInvoiceNumber(number)) {
      throw StateError('Generated invoice number invalid: $number');
    }

    final invoice = Invoice(
      invoiceNumber: number,
      financialYear: financialYear,
      issueDate: DateTime.now(),
      clientName: clientName,
      clientGstin: clientGstin,
      supplierStateCode: supplierStateCode,
      placeOfSupplyStateCode: placeOfSupplyStateCode,
      status: InvoiceStatus.draft,
      lines: lines,
      totalTaxable: breakup.totalTaxable,
      cgst: breakup.cgst,
      sgst: breakup.sgst,
      igst: breakup.igst,
      grandTotal: breakup.grandTotal,
    );
    return Invoice.db.insertRow(session, invoice);
  }

  /// All invoices for a financial year, ordered by document number.
  Future<List<Invoice>> listInvoices(
    Session session,
    String financialYear,
  ) async {
    return Invoice.db.find(
      session,
      where: (t) => t.financialYear.equals(financialYear),
      orderBy: (t) => t.invoiceNumber,
    );
  }

  Future<Invoice> markPaid(Session session, int invoiceId) async {
    final invoice = await Invoice.db.findById(session, invoiceId);
    if (invoice == null) {
      throw ArgumentError('No invoice with id $invoiceId');
    }
    invoice.status = InvoiceStatus.paid;
    return Invoice.db.updateRow(session, invoice);
  }
}
