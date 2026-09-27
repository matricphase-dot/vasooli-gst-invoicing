import 'package:test/test.dart';
import 'package:vasooli_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

InvoiceLine line(String desc, double taxable, [double rate = 18]) => InvoiceLine(
      description: desc,
      hsnSac: '998314',
      taxableValue: taxable,
      gstRatePercent: rate,
    );

void main() {
  withServerpod('Given payments and overdue tracking', (sessionBuilder, endpoints) {
    Future<Invoice> makeDraft({
      String fy = '2030-31',
      double taxable = 1000,
      DateTime? dueDate,
    }) =>
        endpoints.invoices.createInvoice(
          sessionBuilder,
          clientName: 'Test Client',
          supplierStateCode: 27,
          placeOfSupplyStateCode: 27,
          financialYear: fy,
          dueDate: dueDate,
          lines: [line('Work', taxable)],
        );

    test('recordPayment flips invoice to paid and stores the UPI reference', () async {
      final invoice = await makeDraft();
      final paid = await endpoints.invoices.recordPayment(
        sessionBuilder,
        invoiceId: invoice.id!,
        amount: invoice.grandTotal,
        method: PaymentMethod.upi,
        upiReference: 'UTR12345678',
      );
      expect(paid.status, InvoiceStatus.paid);

      final rows = await Payment.db.find(
        sessionBuilder.build(),
        where: (t) => t.invoiceId.equals(invoice.id!),
      );
      expect(rows, hasLength(1));
      expect(rows.single.amount, 1180);
      expect(rows.single.method, PaymentMethod.upi);
      expect(rows.single.upiReference, 'UTR12345678');
    });

    test('recording against an already-paid invoice is refused', () async {
      final invoice = await makeDraft();
      await endpoints.invoices.recordPayment(
        sessionBuilder,
        invoiceId: invoice.id!,
        amount: invoice.grandTotal,
        method: PaymentMethod.upi,
      );
      expect(
        () => endpoints.invoices.recordPayment(
          sessionBuilder,
          invoiceId: invoice.id!,
          amount: invoice.grandTotal,
          method: PaymentMethod.upi,
        ),
        throwsStateError,
      );
    });

    test('amount mismatch is refused (no silent partial payments)', () async {
      final invoice = await makeDraft();
      expect(
        () => endpoints.invoices.recordPayment(
          sessionBuilder,
          invoiceId: invoice.id!,
          amount: invoice.grandTotal - 100,
          method: PaymentMethod.upi,
        ),
        throwsArgumentError,
      );
    });

    test('scanOverdue flips only non-paid invoices past their due date', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final nextWeek = DateTime.now().add(const Duration(days: 7));

      final unpaidPastDue = await makeDraft(dueDate: yesterday);
      final paidPastDue = await makeDraft(dueDate: yesterday);
      await endpoints.invoices.recordPayment(
        sessionBuilder,
        invoiceId: paidPastDue.id!,
        amount: paidPastDue.grandTotal,
        method: PaymentMethod.upi,
      );
      final futureDue = await makeDraft(dueDate: nextWeek);
      await makeDraft(); // no due date at all

      final changed = await endpoints.invoices.scanOverdue(
        sessionBuilder,
        '2030-31',
      );
      expect(changed, 1);

      final flipped = await Invoice.db.findById(
        sessionBuilder.build(),
        unpaidPastDue.id!,
      );
      expect(flipped!.status, InvoiceStatus.overdue);

      final paidRow = await Invoice.db.findById(
        sessionBuilder.build(),
        paidPastDue.id!,
      );
      expect(paidRow!.status, InvoiceStatus.paid);

      final futureRow = await Invoice.db.findById(
        sessionBuilder.build(),
        futureDue.id!,
      );
      expect(futureRow!.status, InvoiceStatus.draft);
    });

    test('monthlySummary aggregates counts, tax totals, in/out money', () async {
      final now = DateTime.now();
      final a = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'A',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27, // intra: cgst+sgst
        financialYear: '2031-32',
        dueDate: null,
        lines: [line('Consulting', 1000)],
      );
      await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'B',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 29, // inter: igst
        financialYear: '2031-32',
        lines: [line('Workshop', 2000)],
      );
      await endpoints.invoices.recordPayment(
        sessionBuilder,
        invoiceId: a.id!,
        amount: a.grandTotal,
        method: PaymentMethod.upi,
      );

      final summary = await endpoints.invoices.monthlySummary(
        sessionBuilder,
        '2031-32',
        now.month,
      );
      expect(summary.invoiceCount, 2);
      expect(summary.paidCount, 1);
      expect(summary.totalTaxable, 3000);
      expect(summary.cgst, 90);
      expect(summary.sgst, 90);
      expect(summary.igst, 360);
      expect(summary.collected, 1180);
      expect(summary.outstanding, 2360);
    });

    test('dueDate is stored and round-trips', () async {
      final due = DateTime.now().add(const Duration(days: 30));
      final invoice = await makeDraft(fy: '2032-33', dueDate: due);
      expect(invoice.dueDate, isNotNull);
      expect(
        invoice.dueDate!.difference(due).inSeconds.abs(),
        lessThan(2),
      );
    });
  });
}
