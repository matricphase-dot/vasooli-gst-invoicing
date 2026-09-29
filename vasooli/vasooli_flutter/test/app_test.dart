import 'package:flutter_test/flutter_test.dart';
import 'package:vasooli_flutter/fmt.dart';
import 'package:vasooli_flutter/gstin.dart';

void main() {
  group('financial years', () {
    test('April starts a new FY', () {
      expect(financialYearOf(DateTime(2026, 4, 1)), '2026-27');
    });
    test('March still belongs to the previous FY', () {
      expect(financialYearOf(DateTime(2027, 3, 31)), '2026-27');
    });
  });

  group('money formatting (Indian grouping)', () {
    test('lakh grouping', () {
      expect(money(153400), '₹1,53,400');
    });
    test('plain thousands', () {
      expect(money(59000), '₹59,000');
    });
  });

  group('client-side GSTIN pre-check', () {
    const valid = '27AAACA1234A1ZK';
    test('accepts a valid GSTIN', () {
      expect(gstinError(valid), isNull);
    });
    test('rejects a check-digit typo', () {
      expect(gstinError('27AAACA1234A1Z2'), contains('Check digit'));
    });
    test('rejects a format error before the check digit matters', () {
      expect(gstinError('27AAACA1234A1Z'), contains('Format'));
    });
    test('passes through the other known-good GSTINs', () {
      expect(gstinError('29AABCB7654P1ZZ'), isNull);
      expect(gstinError('27ABCDE1234F1Z0'), isNull);
    });
  });
}
