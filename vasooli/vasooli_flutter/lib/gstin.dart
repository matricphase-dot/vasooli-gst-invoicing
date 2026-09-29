/// Client-side GSTIN pre-validation: the same mod-36 check digit the GST
/// portal (and this project's server) uses, so typos bite *before* the
/// network round-trip. The server still re-validates authoritatively.
library;

bool gstinFormatValid(String g) =>
    RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$').hasMatch(g);

int _charValue(String c) {
  final u = c.codeUnitAt(0);
  if (u >= 48 && u <= 57) return u - 48; // 0-9
  return u - 55; // A-Z -> 10..35
}

bool gstinCheckDigitValid(String g) {
  if (g.length != 15) return false;
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    var v = _charValue(g[i]);
    final factor = (i % 2 == 0) ? 1 : 2;
    v *= factor;
    sum += v ~/ 36 + v % 36;
  }
  final check = (36 - (sum % 36)) % 36;
  return _charValue(g[14]) == check;
}

/// Full local validation; null means OK, otherwise an error string.
String? gstinError(String g) {
  if (g.isEmpty) return 'GSTIN is empty';
  if (!gstinFormatValid(g)) return 'Format is wrong — a GSTIN has 15 characters';
  if (!gstinCheckDigitValid(g)) {
    return 'Check digit fails — one of the 15 characters is mistyped';
  }
  return null;
}
