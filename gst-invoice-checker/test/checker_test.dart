import 'dart:convert';
import 'dart:io';

import 'package:gst_invoice_checker/gst_invoice_checker.dart';
import 'package:test/test.dart';

InvoiceChecker checkerFor({int supplier = 27, String fy = '2026-27'}) =>
    InvoiceChecker(supplierStateCode: supplier, defaultFinancialYear: fy);

InvoiceInput invoice({
  String number = '1',
  int placeOfSupply = 27,
  String? clientGstin,
  List<LineInput>? lines,
  double totalTaxable = 1000,
  double cgst = 90,
  double sgst = 90,
  double igst = 0,
  double? grandTotal,
}) =>
    InvoiceInput(
      invoiceNumber: number,
      issueDate: DateTime(2026, 4, 10),
      clientName: 'Acme',
      clientGstin: clientGstin,
      placeOfSupplyStateCode: placeOfSupply,
      lines: lines ??
          [
            LineInput(
              description: 'Consulting',
              hsnSac: '998314',
              taxableValue: 1000,
              gstRatePercent: 18,
            )
          ],
      totalTaxable: totalTaxable,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      grandTotal: grandTotal ?? totalTaxable + cgst + sgst + igst,
    );

List<Issue> errors(List<Issue> issues) =>
    issues.where((i) => i.severity == Severity.error).toList();

bool anyIssue(List<Issue> issues, Pattern p, {Severity? severity}) => issues
    .any((i) => (severity == null || i.severity == severity) &&
        i.message.contains(p));

void main() {
  group('document number (Rule 46)', () {
    test('rejects >16 chars and bad symbols', () {
      final bad = checkerFor()
          .checkInvoice(invoice(number: 'THIS-NUMBER-IS-WAY-TOO-LONG'));
      expect(anyIssue(errors(bad), 'Rule 46'), isTrue);
    });
    test('accepts 16 chars with allowed separators', () {
      final ok = checkerFor().checkInvoice(invoice(number: 'ABCD/2026-27/001'));
      expect(errors(ok), isEmpty);
    });
  });

  group('tax recomputation', () {
    test('correct intra-state invoice passes', () {
      expect(errors(checkerFor().checkInvoice(invoice())), isEmpty);
    });

    test('IGST used intra-state is an error', () {
      final issues = checkerFor().checkInvoice(invoice(
        cgst: 0,
        sgst: 0,
        igst: 180,
        grandTotal: 1180,
      ));
      expect(anyIssue(errors(issues), 'intra-state'), isTrue);
      expect(anyIssue(errors(issues), 'CGST 0.0 != expected 90.0'), isTrue);
    });

    test('CGST/SGST used inter-state is an error', () {
      final issues = checkerFor().checkInvoice(
          invoice(placeOfSupply: 29, cgst: 90, sgst: 90, igst: 0));
      expect(anyIssue(errors(issues), 'inter-state'), isTrue);
    });

    test('per-line-style rounding differences are caught', () {
      // 3 lines of 33.30 @ 18%: tax on the total is round(17.982) = 18.
      final lines = List.filled(
        3,
        LineInput(
          description: 'x',
          hsnSac: '9983',
          taxableValue: 33.3,
          gstRatePercent: 18,
        ),
      );
      final ok = checkerFor().checkInvoice(invoice(
        lines: lines,
        totalTaxable: 99.9,
        cgst: 9,
        sgst: 9,
        grandTotal: 117.9,
      ));
      expect(errors(ok), isEmpty);

      final roundedWrong = checkerFor().checkInvoice(invoice(
        lines: lines,
        totalTaxable: 99.9,
        cgst: 9.01, // off-by-paisa drift from per-line rounding
        sgst: 8.99,
        grandTotal: 117.9,
      ));
      expect(anyIssue(errors(roundedWrong), 'CGST'), isTrue);
    });

    test('unrecognised slab rate is an error', () {
      final issues = checkerFor().checkInvoice(invoice(
        lines: [
          LineInput(
              description: 'x',
              hsnSac: '9983',
              taxableValue: 100,
              gstRatePercent: 20)
        ],
        totalTaxable: 100,
        cgst: 10,
        sgst: 10,
        grandTotal: 120,
      ));
      expect(anyIssue(errors(issues), 'recognised slab'), isTrue);
    });
  });

  group('cross-invoice checks', () {
    test('duplicate numbers in one FY are errors', () {
      final issues = checkerFor()
          .checkSet([invoice(number: '1'), invoice(number: '1')]);
      expect(anyIssue(errors(issues), 'unique') , isTrue);
    });

    test('gaps in the numeric series are warnings, not errors', () {
      final issues = checkerFor()
          .checkSet([invoice(number: '1'), invoice(number: '3')]);
      expect(errors(issues), isEmpty);
      expect(anyIssue(issues, 'gap', severity: Severity.warning), isTrue);
    });

    test('same number in different FYs is fine', () {
      final issues = checkerFor().checkSet([
        invoice(number: '1'),
        InvoiceInput(
          invoiceNumber: '1',
          issueDate: DateTime(2027, 4, 10),
          clientName: 'Acme',
          clientGstin: null,
          placeOfSupplyStateCode: 27,
          lines: [
            LineInput(
                description: 'x',
                hsnSac: '998314',
                taxableValue: 1000,
                gstRatePercent: 18)
          ],
          totalTaxable: 1000,
          cgst: 90,
          sgst: 90,
          igst: 0,
          grandTotal: 1180,
          financialYear: '2027-28',
        ),
      ]);
      expect(errors(issues), isEmpty);
    });
  });

  group('JSON decoding + example files', () {
    test('decodes the example shape', () {
      final header = decodeInvoiceFile(jsonDecode(
        File('example/good_invoices.json').readAsStringSync(),
      ) as Map<String, Object?>);
      expect(header.invoices, hasLength(2));
    });

    test('good example passes cleanly end-to-end', () {
      final header = decodeInvoiceFile(jsonDecode(
        File('example/good_invoices.json').readAsStringSync(),
      ) as Map<String, Object?>);
      final checker = InvoiceChecker(
        supplierStateCode: header.supplierStateCode,
        defaultFinancialYear: header.financialYear,
      );
      final issues = [
        for (final inv in header.invoices) ...checker.checkInvoice(inv),
      ];
      expect(errors(issues), isEmpty);
    });

    test('bad example surfaces every planted bug', () {
      final header = decodeInvoiceFile(jsonDecode(
        File('example/bad_invoices.json').readAsStringSync(),
      ) as Map<String, Object?>);
      final checker = InvoiceChecker(
        supplierStateCode: header.supplierStateCode,
        defaultFinancialYear: header.financialYear,
      );
      final issues = <Issue>[
        for (final inv in header.invoices) ...checker.checkInvoice(inv),
        ...checker.checkSet(header.invoices),
      ];
      final messages = issues.map((i) => i.message).join('\n');
      expect(messages, contains('check digit mismatch'));
      expect(messages, contains('HSN/SAC'));
      expect(messages, contains('unique')); // duplicate "1"
      expect(messages, contains('gap')); // 1 -> 5
      expect(messages, contains('grand total 23601.0'));
    });
  });
}
