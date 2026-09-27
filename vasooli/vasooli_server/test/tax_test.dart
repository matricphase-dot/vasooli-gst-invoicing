import 'package:test/test.dart';
import 'package:vasooli_server/src/tax.dart';

void main() {
  group('computeTax', () {
    test('intra-state 18% splits into CGST + SGST halves', () {
      final t = computeTax(
        lines: [(taxableValue: 1000, ratePercent: 18)],
        supplierStateCode: 27, // Maharashtra
        placeOfSupplyStateCode: 27,
      );
      expect(t.totalTaxable, 1000);
      expect(t.cgst, 90);
      expect(t.sgst, 90);
      expect(t.igst, 0);
      expect(t.grandTotal, 1180);
    });

    test('inter-state 18% is IGST at full rate', () {
      final t = computeTax(
        lines: [(taxableValue: 1000, ratePercent: 18)],
        supplierStateCode: 27,
        placeOfSupplyStateCode: 29, // Karnataka
      );
      expect(t.cgst, 0);
      expect(t.sgst, 0);
      expect(t.igst, 180);
      expect(t.grandTotal, 1180);
    });

    test('rounding happens on the total, not per line', () {
      // Two lines at 99.95 each @ 5%: per-line rounding would give 5+5=10;
      // total rounding gives round(9.995) = 10 too — so use the sharper case:
      // 3 lines of 33.30 @ 18% = 99.90 taxable, raw tax 17.982 -> 18.
      final t = computeTax(
        lines: [
          (taxableValue: 33.3, ratePercent: 18),
          (taxableValue: 33.3, ratePercent: 18),
          (taxableValue: 33.3, ratePercent: 18),
        ],
        supplierStateCode: 27,
        placeOfSupplyStateCode: 27,
      );
      expect(t.totalTaxable, closeTo(99.9, 1e-9));
      expect(t.totalTax, 18);
      expect(t.cgst, 9);
      expect(t.sgst, 9);
    });

    test('mixed rates bucket before rounding', () {
      final t = computeTax(
        lines: [
          (taxableValue: 500, ratePercent: 5),
          (taxableValue: 500, ratePercent: 18),
        ],
        supplierStateCode: 7, // Delhi
        placeOfSupplyStateCode: 7,
      );
      // raw = 25 + 90 = 115
      expect(t.totalTax, 115);
      expect(t.cgst, 57.5);
      expect(t.sgst, 57.5);
    });

    test('empty invoice throws', () {
      expect(
        () => computeTax(
          lines: [],
          supplierStateCode: 27,
          placeOfSupplyStateCode: 27,
        ),
        throwsArgumentError,
      );
    });
  });

  group('isValidInvoiceNumber', () {
    test('accepts 16 chars with allowed symbols', () {
      expect(isValidInvoiceNumber('ABCD/2026-27/001'), isTrue); // 16 chars
    });
    test('rejects 17 chars', () {
      expect(isValidInvoiceNumber('12345678901234567'), isFalse);
    });
    test('rejects empty and bad symbols', () {
      expect(isValidInvoiceNumber(''), isFalse);
      expect(isValidInvoiceNumber('INV 001'), isFalse);
      expect(isValidInvoiceNumber('INV_001'), isFalse);
    });
  });

  group('looksLikeGstin', () {
    test('accepts a well-formed GSTIN', () {
      expect(looksLikeGstin('27ABCDE1234F1Z5'), isTrue);
    });
    test('rejects wrong length / lowercase', () {
      expect(looksLikeGstin('27ABCDE1234F1Z'), isFalse);
      expect(looksLikeGstin('27abcde1234f1z5'), isFalse);
    });
  });

  group('isValidGstin (with check digit)', () {
    test('accepts a GSTIN whose check digit is right', () {
      expect(isValidGstin('27ABCDE1234F1Z0'), isTrue);
      expect(isValidGstin('27AAACA1234A1ZK'), isTrue);
    });
    test('rejects a single mistyped character that keeps the format', () {
      // 27ABCDE -> 27ABCDX: format still matches, checksum catches it
      // (the X variant would need check digit 'H', not '0').
      expect(looksLikeGstin('27ABCDX1234F1Z0'), isTrue);
      expect(isValidGstin('27ABCDX1234F1Z0'), isFalse);
    });
    test('rejects a wrong check digit', () {
      expect(looksLikeGstin('27ABCDE1234F1Z5'), isTrue);
      expect(isValidGstin('27ABCDE1234F1Z5'), isFalse);
    });
  });
}
