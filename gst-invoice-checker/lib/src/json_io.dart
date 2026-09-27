/// JSON file decoding for the checker. Kept separate from the engine so the
/// engine stays pure (and testable) Dart.
library;

import 'checker.dart';

class FileHeader {
  FileHeader({
    required this.supplierStateCode,
    required this.financialYear,
    required this.invoices,
  });

  final int supplierStateCode;
  final String financialYear;
  final List<InvoiceInput> invoices;
}

/// Expected file shape:
///
/// ```json
/// {
///   "supplierStateCode": 27,
///   "financialYear": "2026-27",
///   "invoices": [
///     {
///       "number": "1",
///       "issueDate": "2026-09-15",
///       "clientName": "Acme Pvt Ltd",
///       "clientGstin": "27ABCDE1234F1Z5",
///       "placeOfSupplyStateCode": 27,
///       "lines": [
///         {"description": "Consulting", "hsnSac": "9983",
///          "taxableValue": 1000, "ratePercent": 18}
///       ],
///       "totalTaxable": 1000,
///       "cgst": 90, "sgst": 90, "igst": 0,
///       "grandTotal": 1180
///     }
///   ]
/// }
/// ```
FileHeader decodeInvoiceFile(Map<String, Object?> json) {
  Object? field(Map<String, Object?> m, String name) => m[name];

  final supplier = field(json, 'supplierStateCode');
  if (supplier is! int) {
    throw FormatException('missing or non-integer "supplierStateCode"');
  }
  final fy = field(json, 'financialYear');
  if (fy is! String) {
    throw FormatException('missing "financialYear" (e.g. "2026-27")');
  }
  final list = field(json, 'invoices');
  if (list is! List) {
    throw FormatException('"invoices" must be a list');
  }

  double num2double(Object? v, String what) {
    if (v is num) return v.toDouble();
    throw FormatException('"$what" must be a number, got: $v');
  }

  final invoices = <InvoiceInput>[];
  for (var i = 0; i < list.length; i++) {
    final raw = list[i];
    if (raw is! Map) {
      throw FormatException('invoice ${i + 1} is not an object');
    }
    final m = raw.cast<String, Object?>();
    final at = 'invoice ${i + 1} ("${m['number']}")';

    final rawLines = m['lines'];
    if (rawLines is! List || rawLines.isEmpty) {
      throw FormatException('$at: "lines" must be a non-empty list');
    }
    final lines = <LineInput>[];
    for (var j = 0; j < rawLines.length; j++) {
      final lm = (rawLines[j] as Map).cast<String, Object?>();
      lines.add(LineInput(
        description: (lm['description'] ?? '') as String,
        hsnSac: (lm['hsnSac'] ?? '') as String,
        taxableValue: num2double(lm['taxableValue'], '$at line ${j + 1} taxableValue'),
        gstRatePercent: num2double(lm['ratePercent'], '$at line ${j + 1} ratePercent'),
      ));
    }

    invoices.add(InvoiceInput(
      invoiceNumber: (m['number'] ?? '') as String,
      issueDate: DateTime.tryParse((m['issueDate'] ?? '') as String) ??
          (throw FormatException('$at: unparseable issueDate')),
      clientName: (m['clientName'] ?? '') as String,
      clientGstin: m['clientGstin'] as String?,
      placeOfSupplyStateCode:
          num2double(m['placeOfSupplyStateCode'], '$at placeOfSupplyStateCode').toInt(),
      lines: lines,
      totalTaxable: num2double(m['totalTaxable'], '$at totalTaxable'),
      cgst: num2double(m['cgst'], '$at cgst'),
      sgst: num2double(m['sgst'], '$at sgst'),
      igst: num2double(m['igst'], '$at igst'),
      grandTotal: num2double(m['grandTotal'], '$at grandTotal'),
      financialYear: m['financialYear'] as String?,
    ));
  }
  return FileHeader(
    supplierStateCode: supplier,
    financialYear: fy,
    invoices: invoices,
  );
}
