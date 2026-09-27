/// GST tax math for [Invoice]s.
///
/// Deliberately pure Dart so it is unit-testable without a database.
///
/// Rules implemented (see project notes; verify against the CGST Rules
/// before shipping to real users):
///  * Intra-state supply (place of supply == supplier state): CGST + SGST,
///    half each.
///  * Inter-state supply: IGST at the full rate.
///  * Rounding happens on the TOTAL taxable value of the invoice, not per
///    line — rounding per line is one of the most common GST invoice
///    mistakes.
///  * The tax amount is rounded to the nearest whole rupee (benefit of
///    rounding under the CGST Act).
library;

class TaxBreakup {
  TaxBreakup({
    required this.totalTaxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  final double totalTaxable;
  final double cgst;
  final double sgst;
  final double igst;

  double get totalTax => cgst + sgst + igst;
  double get grandTotal => totalTaxable + totalTax;

  @override
  String toString() =>
      'TaxBreakup(taxable: $totalTaxable, cgst: $cgst, sgst: $sgst, '
      'igst: $igst, grand: $grandTotal)';
}

/// Rounds to the nearest whole rupee, halves rounding up (e.g. 179.5 -> 180).
double roundToNearestRupee(double value) => (value + 0.5).floorToDouble();

/// Computes the GST breakup for a set of line items.
///
/// [supplierStateCode] and [placeOfSupplyStateCode] are Indian state codes
/// (e.g. 27 = Maharashtra). They decide CGST+SGST vs IGST.
TaxBreakup computeTax({
  required List<({double taxableValue, double ratePercent})> lines,
  required int supplierStateCode,
  required int placeOfSupplyStateCode,
}) {
  if (lines.isEmpty) {
    throw ArgumentError('An invoice needs at least one line.');
  }
  final totalTaxable =
      lines.fold<double>(0, (sum, l) => sum + l.taxableValue);

  // Tax per rate bucket, summed, then rounded ONCE on the total.
  final byRate = <double, double>{};
  for (final line in lines) {
    byRate[line.ratePercent] =
        (byRate[line.ratePercent] ?? 0) + line.taxableValue;
  }
  var rawTotal = 0.0;
  byRate.forEach((rate, taxable) {
    rawTotal += taxable * rate / 100;
  });
  final totalTax = roundToNearestRupee(rawTotal);

  final intraState = supplierStateCode == placeOfSupplyStateCode;
  if (intraState) {
    // Halves may carry 50 paise; that is fine and legal.
    final half = totalTax / 2;
    return TaxBreakup(
      totalTaxable: totalTaxable,
      cgst: half,
      sgst: half,
      igst: 0,
    );
  }
  return TaxBreakup(
    totalTaxable: totalTaxable,
    cgst: 0,
    sgst: 0,
    igst: totalTax,
  );
}

/// Rule 46: the invoice serial number may be at most 16 characters and may
/// contain only letters, digits, "/" and "-".
bool isValidInvoiceNumber(String number) {
  if (number.isEmpty || number.length > 16) return false;
  return RegExp(r'^[A-Za-z0-9/\-]+$').hasMatch(number);
}

/// Minimal GSTIN sanity check: 15 characters, standard layout.
/// This is a format check only — it does NOT verify the check digit.
bool looksLikeGstin(String gstin) =>
    RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]$')
        .hasMatch(gstin);

int _gstinCharValue(String ch) {
  final code = ch.codeUnitAt(0);
  if (code >= 0x30 && code <= 0x39) return code - 0x30; // 0-9 -> 0..9
  if (code >= 0x41 && code <= 0x5A) return code - 0x41 + 10; // A-Z -> 10..35
  return -1;
}

/// The standard GSTN mod-36 check character for the first 14 characters
/// of a GSTIN. Kept in sync with gst-invoice-checker's copy.
String gstinCheckChar(String firstFourteen) {
  if (firstFourteen.length != 14) {
    throw ArgumentError('needs exactly the first 14 characters');
  }
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    final v = _gstinCharValue(firstFourteen[i]);
    if (v < 0) {
      throw ArgumentError('invalid character: ${firstFourteen[i]}');
    }
    final product = v * (i.isEven ? 1 : 2);
    sum += product ~/ 36 + product % 36;
  }
  final check = (36 - sum % 36) % 36;
  return check < 10
      ? String.fromCharCode(0x30 + check)
      : String.fromCharCode(0x41 + check - 10);
}

/// Full GSTIN validation: format AND check digit. This is what the server
/// enforces — a wrong key in any of the 15 positions flips the check digit,
/// so a mistyped GSTIN is rejected instead of silently breaking the
/// client's ITC claim.
bool isValidGstin(String gstin) {
  if (!looksLikeGstin(gstin)) return false;
  return gstinCheckChar(gstin.substring(0, 14)) == gstin[14];
}
