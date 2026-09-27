import 'package:test/test.dart';
import 'package:vasooli_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Invoices endpoint', (sessionBuilder, endpoints) {
    test('createInvoice computes intra-state CGST+SGST and number 1', () async {
      final invoice = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'Acme Pvt Ltd',
        clientGstin: '27ABCDE1234F1Z0', // valid check digit
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27,
        financialYear: '2026-27',
        lines: [
          InvoiceLine(
            description: 'Consulting',
            hsnSac: '9983',
            taxableValue: 1000,
            gstRatePercent: 18,
          ),
        ],
      );
      expect(invoice.id, isNotNull);
      expect(invoice.invoiceNumber, '1');
      expect(invoice.cgst, 90);
      expect(invoice.sgst, 90);
      expect(invoice.igst, 0);
      expect(invoice.grandTotal, 1180);
      expect(invoice.status, InvoiceStatus.draft);
    });

    test('invoice numbers are sequential within a financial year', () async {
      // The test harness rolls back each test, so create both rows here.
      final first = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'Acme Pvt Ltd',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27,
        financialYear: '2026-27',
        lines: [
          InvoiceLine(
            description: 'Consulting',
            hsnSac: '9983',
            taxableValue: 1000,
            gstRatePercent: 18,
          ),
        ],
      );
      final second = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'Acme Pvt Ltd',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27,
        financialYear: '2026-27',
        lines: [
          InvoiceLine(
            description: 'Retainer',
            hsnSac: '9983',
            taxableValue: 500,
            gstRatePercent: 18,
          ),
        ],
      );
      expect(first.invoiceNumber, '1');
      expect(second.invoiceNumber, '2');
    });

    test('inter-state supply is IGST', () async {
      final invoice = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'Bengaluru Co',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 29,
        financialYear: '2027-28', // separate FY so numbering starts at 1
        lines: [
          InvoiceLine(
            description: 'Workshop',
            hsnSac: '9984',
            taxableValue: 2000,
            gstRatePercent: 18,
          ),
        ],
      );
      expect(invoice.invoiceNumber, '1');
      expect(invoice.igst, 360);
      expect(invoice.cgst, 0);
      expect(invoice.sgst, 0);
    });

    test('markPaid flips status to paid', () async {
      final invoice = await endpoints.invoices.createInvoice(
        sessionBuilder,
        clientName: 'Paying Client',
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27,
        financialYear: '2028-29',
        lines: [
          InvoiceLine(
            description: 'Advance',
            hsnSac: '9983',
            taxableValue: 100,
            gstRatePercent: 18,
          ),
        ],
      );
      final paid = await endpoints.invoices.markPaid(sessionBuilder, invoice.id!);
      expect(paid.status, InvoiceStatus.paid);
    });

    test('GSTIN with wrong check digit is rejected server-side', () async {
      expect(
        () => endpoints.invoices.createInvoice(
          sessionBuilder,
          clientName: 'Typo Client',
          clientGstin: '27ABCDE1234F1Z5', // format OK, check digit wrong
          supplierStateCode: 27,
          placeOfSupplyStateCode: 27,
          financialYear: '2029-30',
          lines: [
            InvoiceLine(
              description: 'X',
              hsnSac: '9983',
              taxableValue: 10,
              gstRatePercent: 18,
            ),
          ],
        ),
        throwsA(isA<InvalidGstinException>()),
      );
    });

    test('malformed GSTIN is rejected server-side', () async {
      expect(
        () => endpoints.invoices.createInvoice(
          sessionBuilder,
          clientName: 'Bad GSTIN Client',
          clientGstin: 'not-a-gstin',
          supplierStateCode: 27,
          placeOfSupplyStateCode: 27,
          financialYear: '2029-30',
          lines: [
            InvoiceLine(
              description: 'X',
              hsnSac: '9983',
              taxableValue: 10,
              gstRatePercent: 18,
            ),
          ],
        ),
        throwsA(isA<InvalidGstinException>()),
      );
    });
  });
}
