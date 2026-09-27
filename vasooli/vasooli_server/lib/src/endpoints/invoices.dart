import 'package:serverpod/serverpod.dart';

import '../channels.dart';
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
    DateTime? dueDate,
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
    // row before two devices create invoices at once.
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
      dueDate: dueDate,
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
    final saved = await Invoice.db.insertRow(session, invoice);
    await session.messages.postMessage(invoicesUpdatesChannel, saved);
    return saved;
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

  /// Records a (full) payment against an invoice and flips it to paid.
  ///
  /// Typical use: the freelancer sees the client's UPI credit notification,
  /// opens the invoice, taps "paid", optionally notes the UPI reference.
  /// Server-side checks: invoice exists, not already paid, amount matches
  /// the invoice total exactly (partial payments deliberately not yet
  /// supported — under-recording is worse than no recording for taxes).
  Future<Invoice> recordPayment(
    Session session, {
    required int invoiceId,
    required double amount,
    PaymentMethod method = PaymentMethod.upi,
    String? upiReference,
    String? note,
  }) async {
    final invoice = await Invoice.db.findById(session, invoiceId);
    if (invoice == null) {
      throw ArgumentError('No invoice with id $invoiceId');
    }
    if (invoice.status == InvoiceStatus.paid) {
      throw StateError(
        'Invoice ${invoice.invoiceNumber} is already paid; refusing a '
        'second payment',
      );
    }
    if ((amount - invoice.grandTotal).abs() > 0.005) {
      throw ArgumentError(
        'payment ₹$amount does not equal the invoice total '
        '₹${invoice.grandTotal}; partial payments are not supported yet',
      );
    }

    await Payment.db.insertRow(
      session,
      Payment(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        upiReference: upiReference,
        paidAt: DateTime.now(),
        note: note,
      ),
    );
    invoice.status = InvoiceStatus.paid;
    final updated = await Invoice.db.updateRow(session, invoice);
    await session.messages.postMessage(invoicesUpdatesChannel, updated);
    return updated;
  }

  Future<Invoice> markPaid(Session session, int invoiceId) async {
    final invoice = await Invoice.db.findById(session, invoiceId);
    if (invoice == null) {
      throw ArgumentError('No invoice with id $invoiceId');
    }
    return recordPayment(
      session,
      invoiceId: invoiceId,
      amount: invoice.grandTotal,
      method: PaymentMethod.other,
      note: 'marked paid without details',
    );
  }

  /// Flips non-paid invoices past their due date to `overdue`.
  /// Returns the number changed. This is exactly the same logic the daily
  /// future call runs — exposed as an endpoint so the demo (and the app)
  /// can trigger it on demand.
  Future<int> scanOverdue(Session session, String financialYear) async {
    final candidates = await Invoice.db.find(
      session,
      where: (t) => t.financialYear.equals(financialYear),
    );
    var changed = 0;
    for (final invoice in candidates) {
      if (invoice.status != InvoiceStatus.draft &&
          invoice.status != InvoiceStatus.sent) {
        continue; // paid or already overdue — leave untouched
      }
      final due = invoice.dueDate;
      if (due == null || !due.isBefore(DateTime.now())) continue;
      invoice.status = InvoiceStatus.overdue;
      final updated = await Invoice.db.updateRow(session, invoice);
      await session.messages.postMessage(invoicesUpdatesChannel, updated);
      changed++;
    }
    return changed;
  }

  /// Month-end view: counts by status, tax totals (the GSTR story) and how
  /// much money came in vs is still out. Computed from the ledger rows live.
  Future<MonthlySummary> monthlySummary(
    Session session,
    String financialYear,
    int month,
  ) async {
    final invoices = await Invoice.db.find(
      session,
      where: (t) => t.financialYear.equals(financialYear),
    );
    final inMonth =
        invoices.where((i) => i.issueDate.month == month).toList();

    int byStatus(InvoiceStatus s) =>
        inMonth.where((i) => i.status == s).length;
    double sumOf(double Function(Invoice) f, Iterable<Invoice> xs) =>
        xs.fold(0.0, (sum, i) => sum + f(i));

    final paid = inMonth.where((i) => i.status == InvoiceStatus.paid);
    final notPaid = inMonth.where((i) => i.status != InvoiceStatus.paid);

    return MonthlySummary(
      financialYear: financialYear,
      month: month,
      invoiceCount: inMonth.length,
      draftCount: byStatus(InvoiceStatus.draft),
      sentCount: byStatus(InvoiceStatus.sent),
      paidCount: byStatus(InvoiceStatus.paid),
      overdueCount: byStatus(InvoiceStatus.overdue),
      totalTaxable: sumOf((i) => i.totalTaxable, inMonth),
      cgst: sumOf((i) => i.cgst, inMonth),
      sgst: sumOf((i) => i.sgst, inMonth),
      igst: sumOf((i) => i.igst, inMonth),
      collected: sumOf((i) => i.grandTotal, paid),
      outstanding: sumOf((i) => i.grandTotal, notPaid),
    );
  }

  /// The live feed every device subscribes to. Any create / payment /
  /// overdue flip anywhere posts to this channel; subscribing here is the
  /// entire "second device updates instantly" story — no polling.
  Stream<Invoice> watchInvoices(Session session) {
    return session.messages.createStream<Invoice>(invoicesUpdatesChannel);
  }
}
