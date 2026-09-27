/// GSTIN (GST Identification Number) validation.
///
/// A GSTIN is 15 characters:
///   * 2 digits of state code
///   * 10 characters of PAN (5 letters, 4 digits, 1 letter)
///   * 1 entity code (usually alphanumeric)
///   * the literal 'Z'
///   * 1 check character (position 15)
///
/// The check character is computed over the first 14 characters with the
/// standard mod-36 scheme used by GSTN. A *format* match alone is not enough:
/// a single mistyped key still matches the format, but the check digit
/// catches it. That is the difference between "looks right" and "your client
/// can actually claim ITC".
///
/// CAVEAT (same as the main project notes): this encodes the publicly
/// documented GSTIN format and checksum algorithm. Verify against the
/// official GST portal docs before relying on it for real filings.
library;

/// State codes valid as the first two digits of a GSTIN, with names.
/// Used both for GSTIN checks and for place-of-supply validation.
const Map<int, String> gstStateCodes = {
  1: 'Jammu & Kashmir',
  2: 'Himachal Pradesh',
  3: 'Punjab',
  4: 'Chandigarh',
  5: 'Uttarakhand',
  6: 'Haryana',
  7: 'Delhi',
  8: 'Rajasthan',
  9: 'Uttar Pradesh',
  10: 'Bihar',
  11: 'Sikkim',
  12: 'Arunachal Pradesh',
  13: 'Nagaland',
  14: 'Manipur',
  15: 'Mizoram',
  16: 'Tripura',
  17: 'Meghalaya',
  18: 'Assam',
  19: 'West Bengal',
  20: 'Jharkhand',
  21: 'Odisha',
  22: 'Chhattisgarh',
  23: 'Madhya Pradesh',
  24: 'Gujarat',
  25: 'Daman & Diu',
  26: 'Dadra & Nagar Haveli and Daman & Diu',
  27: 'Maharashtra',
  29: 'Karnataka',
  30: 'Goa',
  31: 'Lakshadweep',
  32: 'Kerala',
  33: 'Tamil Nadu',
  34: 'Puducherry',
  35: 'Andaman & Nicobar Islands',
  36: 'Telangana',
  37: 'Andhra Pradesh',
  38: 'Ladakh',
  97: 'Other Territory',
  99: 'Centre Jurisdiction',
};

final RegExp _gstinFormat =
    RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]$');

int _charValue(String ch) {
  final code = ch.codeUnitAt(0);
  if (code >= 0x30 && code <= 0x39) return code - 0x30; // 0-9 -> 0..9
  if (code >= 0x41 && code <= 0x5A) return code - 0x41 + 10; // A-Z -> 10..35
  return -1;
}

String _valueChar(int v) {
  assert(v >= 0 && v <= 35);
  return v < 10 ? String.fromCharCode(0x30 + v) : String.fromCharCode(0x41 + v - 10);
}

/// Computes the check character for a 14-character GSTIN prefix.
///
/// The algorithm: character values (0-9=0..9, A-Z=10..35) are multiplied,
/// alternating, by 1 and 2 (starting with 1 at the first character). Each
/// product contributes quotient + remainder when divided by 36 to the sum.
/// The check value is (36 - sum mod 36) mod 36.
String gstinCheckChar(String firstFourteen) {
  if (firstFourteen.length != 14) {
    throw ArgumentError(
      'GSTIN check computation needs exactly the first 14 characters, '
      'got ${firstFourteen.length}',
    );
  }
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    final v = _charValue(firstFourteen[i]);
    if (v < 0) {
      throw ArgumentError(
        'GSTIN prefix contains invalid character: ${firstFourteen[i]}',
      );
    }
    final product = v * (i.isEven ? 1 : 2);
    sum += product ~/ 36 + product % 36;
  }
  final check = (36 - sum % 36) % 36;
  return _valueChar(check);
}

/// Format check only. True iff the string has the 15-character GSTIN layout.
/// A format match does NOT mean the GSTIN is real: the check digit at
/// position 15 may still be wrong. Prefer [isValidGstin].
bool hasGstinFormat(String gstin) => _gstinFormat.hasMatch(gstin);

/// Full check: format AND check digit.
bool isValidGstin(String gstin) {
  if (!hasGstinFormat(gstin)) return false;
  return gstinCheckChar(gstin.substring(0, 14)) == gstin[14];
}

/// Errors explaining why [gstin] fails [isValidGstin], empty if valid.
List<String> gstinProblems(String gstin) {
  final problems = <String>[];
  if (gstin.length != 15) {
    problems.add('must be 15 characters, got ${gstin.length}');
    return problems;
  }
  final stateCodeDigits = gstin.substring(0, 2);
  final stateCode = int.tryParse(stateCodeDigits);
  if (stateCode == null || !gstStateCodes.containsKey(stateCode)) {
    problems.add('$stateCodeDigits is not a registered GST state code');
  }
  final body = gstin.substring(2, 12);
  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(body)) {
    problems.add('characters 3-12 must be PAN format: 5 letters, 4 digits, '
        '1 letter (got $body)');
  }
  if (!RegExp(r'^[0-9A-Z]$').hasMatch(gstin[12])) {
    problems.add("entity code '${gstin[12]}' must be a letter or digit");
  }
  if (gstin[13] != 'Z') {
    problems.add("14th character must be 'Z' (got '${gstin[13]}')");
  }
  if (problems.isNotEmpty) return problems; // prefix unusable for checksum
  final expected = gstinCheckChar(gstin.substring(0, 14));
  if (gstin[14] != expected) {
    problems.add(
      "check digit mismatch: got '${gstin[14]}', expected '$expected' "
      '(one of the other characters is probably mistyped)',
    );
  }
  return problems;
}

/// The state code embedded in a GSTIN's first two digits, null if malformed.
int? gstinStateCode(String gstin) {
  if (gstin.length < 2) return null;
  final code = int.tryParse(gstin.substring(0, 2));
  return (code != null && gstStateCodes.containsKey(code)) ? code : null;
}
