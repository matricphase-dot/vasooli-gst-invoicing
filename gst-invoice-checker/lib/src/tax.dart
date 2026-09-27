/// GST tax math — the same rules the Vasooli server enforces, duplicated on
/// purpose so this package validates invoices with zero dependencies (and so
/// a bug in one copy shows up as a disagreement with the other).
///
/// Rules implemented:
///  * Intra-state supply (place of supply == supplier state): CGST + SGST,
///    half each.
///  * Inter-state supply: IGST at the full rate.
///  * Rounding on the TOTAL taxable value of the invoice, not per line.
///  * Tax rounded to the nearest whole rupee.
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
}

/// Rounds to the nearest whole rupee, halves rounding up (e.g. 179.5 -> 180).
double roundToNearestRupee(double value) => (value + 0.5).floorToDouble();

/// GST rates in per cent that are recognised on Indian invoices.
/// 0.25 and 3 cover precious stones/metals and jewellery.
const List<double> recognisedGstRates = [0, 0.25, 3, 5, 12, 18, 28];

/// Computes the expected GST breakup for a set of line items.
TaxBreakup computeExpectedTax({
  required List<({double taxableValue, double ratePercent})> lines,
  required int supplierStateCode,
  required int placeOfSupplyStateCode,
}) {
  if (lines.isEmpty) {
    throw ArgumentError('An invoice needs at least one line.');
  }
  final totalTaxable =
      lines.fold<double>(0, (sum, l) => sum + l.taxableValue);

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

/// Rule 46: serial number max 16 chars, letters/digits/"/"-only.
bool isValidInvoiceNumber(String number) {
  if (number.isEmpty || number.length > 16) return false;
  return RegExp(r'^[A-Za-z0-9/\-]+$').hasMatch(number);
}

/// HSN (goods) is 4, 6 or 8 digits; SAC (services) is 6 digits (99…).
bool looksLikeHsnSac(String code) =>
    RegExp(r'^[0-9]{4}$|^[0-9]{6}$|^[0-9]{8}$').hasMatch(code);
