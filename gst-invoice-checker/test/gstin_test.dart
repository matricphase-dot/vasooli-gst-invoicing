import 'package:gst_invoice_checker/gst_invoice_checker.dart';
import 'package:test/test.dart';

void main() {
  group('gstinCheckChar', () {
    // Check digits computed with this library, cross-checked against the
    // published mod-36 algorithm description.
    test('computes known check digits', () {
      expect(gstinCheckChar('27AAACA1234A1Z'), 'K');
      expect(gstinCheckChar('29AABCB7654P1Z'), 'Z');
      expect(gstinCheckChar('27ABCDE1234F1Z'), '0');
    });

    test('rejects wrong-length or invalid-char input', () {
      expect(() => gstinCheckChar('27AAACA1234A1'), throwsArgumentError);
      expect(() => gstinCheckChar('27AAACA1234A1\$'), throwsArgumentError);
    });
  });

  group('isValidGstin', () {
    test('accepts GSTINs with a correct check digit', () {
      expect(isValidGstin('27AAACA1234A1ZK'), isTrue);
      expect(isValidGstin('29AABCB7654P1ZZ'), isTrue);
      expect(isValidGstin('27ABCDE1234F1Z0'), isTrue);
    });

    test('rejects a single mistyped character', () {
      // Flip the 5th character C->D: format still matches, checksum fails.
      expect(hasGstinFormat('27AAADA1234A1ZK'), isTrue);
      expect(isValidGstin('27AAADA1234A1ZK'), isFalse);
    });

    test('rejects a wrong check digit', () {
      expect(hasGstinFormat('27AAACA1234A1Z2'), isTrue);
      expect(isValidGstin('27AAACA1234A1Z2'), isFalse);
    });

    test('rejects bad format', () {
      expect(isValidGstin('27AAACA1234A1Z'), isFalse); // 14 chars
      expect(isValidGstin('27aaaca1234a1zk'), isFalse); // lowercase
    });
  });

  group('gstinProblems', () {
    test('explains the check digit mismatch', () {
      final problems = gstinProblems('27AAACA1234A1Z2');
      expect(problems, hasLength(1));
      expect(problems.single, contains("expected 'K'"));
    });

    test('flags unknown state codes', () {
      expect(gstinProblems('98AAACA1234A1ZK'),
          contains(contains('not a registered GST state code')));
    });

    test('clean GSTIN has no problems', () {
      expect(gstinProblems('27AAACA1234A1ZK'), isEmpty);
    });
  });

  group('gstinStateCode', () {
    test('extracts the state', () {
      expect(gstinStateCode('27AAACA1234A1ZK'), 27);
      expect(gstinStateCode('29AABCB7654P1ZZ'), 29);
    });
    test('null for malformed', () {
      expect(gstinStateCode('x'), isNull);
      expect(gstinStateCode('98AAACA1234A1ZK'), isNull);
    });
  });
}
