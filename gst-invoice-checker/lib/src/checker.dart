/// Invoice checking engine. Pure Dart, no I/O: feed it decoded JSON-shaped
/// maps (or the typed input objects below) and get back findings.
library;

import 'gstin.dart';
import 'tax.dart';

/// Findings are ordered [error] < [warning] < [info]; a file with any error
/// fails the check (CLI exit code 1). Warnings are facts a careful human
/// should look at (sequence gaps, unusual PoS) but that can be legitimate.
enum Severity { error, warning, info }

class Issue {
  Issue(this.severity, this.message, {this.invoiceNumber});

  final Severity severity;
  final String message;
  final String? invoiceNumber;

  @override
  String toString() {
    final scope = invoiceNumber != null ? 'invoice $invoiceNumber' : 'file';
    return '[${severity.name.toUpperCase()}] $scope: $message';
  }

  Map<String, Object?> toJson() => {
        'severity': severity.name,
        'invoiceNumber': invoiceNumber,
        'message': message,
      };
}

class LineInput {
  LineInput({
    required this.description,
    required this.hsnSac,
    required this.taxableValue,
    required this.gstRatePercent,
  });

  final String description;
  final String hsnSac;
  final double taxableValue;
  final double gstRatePercent;
}

class InvoiceInput {
  InvoiceInput({
    required this.invoiceNumber,
    required this.issueDate,
    required this.clientName,
    required this.clientGstin,
    required this.placeOfSupplyStateCode,
    required this.lines,
    required this.totalTaxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.grandTotal,
    this.financialYear,
  });

  final String invoiceNumber;
  final DateTime issueDate;
  final String clientName;
  final String? clientGstin;
  final int placeOfSupplyStateCode;
  final List<LineInput> lines;
  final double totalTaxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double grandTotal;

  /// Optional per-invoice FY override ("2026-27"); defaults to the file's.
  final String? financialYear;
}

bool _close(double a, double b) => (a - b).abs() < 0.005;

class InvoiceChecker {
  InvoiceChecker({
    required this.supplierStateCode,
    required this.defaultFinancialYear,
  }) {
    if (!gstStateCodes.containsKey(supplierStateCode)) {
      throw ArgumentError(
        'supplierStateCode $supplierStateCode is not a registered GST state code',
      );
    }
  }

  /// Where the supplier (you) is registered. Drives CGST+SGST vs IGST.
  final int supplierStateCode;

  /// Financial year ("2026-27") used for sequence checks unless a single
  /// invoice overrides it.
  final String defaultFinancialYear;

  /// Checks one invoice and returns findings.
  List<Issue> checkInvoice(InvoiceInput inv) {
    final issues = <Issue>[];
    void err(String m) => issues.add(Issue(Severity.error, m, invoiceNumber: inv.invoiceNumber));
    void warn(String m) => issues.add(Issue(Severity.warning, m, invoiceNumber: inv.invoiceNumber));
    void info(String m) => issues.add(Issue(Severity.info, m, invoiceNumber: inv.invoiceNumber));

    // ---- Rule 46 document number -----------------------------------------
    if (!isValidInvoiceNumber(inv.invoiceNumber)) {
      err('document number "${inv.invoiceNumber}" breaks Rule 46: max 16 '
          'characters, only letters, digits, "/" and "-" allowed');
    }

    // ---- Header fields -----------------------------------------------------
    if (inv.clientName.trim().isEmpty) err('client name is empty');

    if (inv.clientGstin != null) {
      for (final problem in gstinProblems(inv.clientGstin!)) {
        err('client GSTIN ${inv.clientGstin}: $problem');
      }
      final buyerState = gstinStateCode(inv.clientGstin!);
      if (buyerState != null && buyerState != inv.placeOfSupplyStateCode) {
        warn('client GSTIN state ($_stateName(buyerState)) differs from place '
            'of supply (${_stateName(inv.placeOfSupplyStateCode)}); for B2B '
            'services the place of supply is usually the recipient\'s state');
      }
    } else {
      info('no client GSTIN recorded — fine below the registration threshold, '
          'but B2B clients usually expect one');
    }

    if (!gstStateCodes.containsKey(inv.placeOfSupplyStateCode)) {
      err('place of supply state code ${inv.placeOfSupplyStateCode} is not '
          'a registered GST state code');
    }

    // ---- Lines -------------------------------------------------------------
    if (inv.lines.isEmpty) {
      err('invoice has no line items');
    }
    for (var i = 0; i < inv.lines.length; i++) {
      final l = inv.lines[i];
      final at = 'line ${i + 1}';
      if (l.description.trim().isEmpty) err('$at: description is empty');
      if (!looksLikeHsnSac(l.hsnSac)) {
        err('$at: HSN/SAC "${l.hsnSac}" should be 4, 6 or 8 digits');
      }
      if (l.taxableValue < 0) err('$at: taxable value is negative');
      if (!recognisedGstRates.contains(l.gstRatePercent)) {
        err('$at: GST rate ${l.gstRatePercent}% is not a recognised slab '
            '(${recognisedGstRates.join(', ')})');
      }
    }

    // ---- Tax recomputation ---------------------------------------------------
    if (inv.lines.isNotEmpty &&
        gstStateCodes.containsKey(inv.placeOfSupplyStateCode)) {
      final expected = computeExpectedTax(
        lines: inv.lines
            .map((l) => (taxableValue: l.taxableValue, ratePercent: l.gstRatePercent))
            .toList(),
        supplierStateCode: supplierStateCode,
        placeOfSupplyStateCode: inv.placeOfSupplyStateCode,
      );

      if (!_close(inv.totalTaxable, expected.totalTaxable)) {
        err('total taxable ${inv.totalTaxable} != sum of line taxable values '
            '${expected.totalTaxable}');
      }

      final intraState = supplierStateCode == inv.placeOfSupplyStateCode;
      if (intraState && (!_close(inv.igst, 0) || _close(inv.cgst + inv.sgst, 0))) {
        err('supply is intra-state (${_stateName(supplierStateCode)}) so tax '
            'should be CGST+SGST, not IGST');
      }
      if (!intraState && (!_close(inv.cgst, 0) || !_close(inv.sgst, 0))) {
        err('supply is inter-state so tax should be IGST, not CGST/SGST');
      }
      if (!_close(inv.cgst, expected.cgst)) {
        err('CGST ${inv.cgst} != expected ${expected.cgst}');
      }
      if (!_close(inv.sgst, expected.sgst)) {
        err('SGST ${inv.sgst} != expected ${expected.sgst}');
      }
      if (!_close(inv.igst, expected.igst)) {
        err('IGST ${inv.igst} != expected ${expected.igst}');
      }
      if (!_close(inv.grandTotal, expected.grandTotal)) {
        err('grand total ${inv.grandTotal} != taxable + tax '
            '(${expected.grandTotal}); check that tax was rounded on the '
            'invoice total, not per line');
      }
    }

    return issues;
  }

  /// Cross-invoice checks over a whole file: per-financial-year document
  /// numbers must be unique; gaps in a simple numeric series are flagged as
  /// warnings (a missing number means a cancelled or unrecorded invoice,
  /// which must not simply disappear from the books).
  List<Issue> checkSet(List<InvoiceInput> invoices) {
    final issues = <Issue>[];
    final byFy = <String, List<String>>{};
    for (final inv in invoices) {
      final fy = inv.financialYear ?? defaultFinancialYear;
      byFy.putIfAbsent(fy, () => []).add(inv.invoiceNumber);
    }
    byFy.forEach((fy, numbers) {
      final seen = <String, int>{};
      for (final n in numbers) {
        seen[n] = (seen[n] ?? 0) + 1;
        if (seen[n]! > 1) {
          issues.add(Issue(Severity.error,
              'document number "$n" used ${seen[n]} times in FY $fy; Rule 46 '
              'requires the consecutive series to be unique'));
        }
      }
      final numeric = numbers.map(int.tryParse).whereType<int>().toList()
        ..sort();
      if (numeric.length == numbers.length && numeric.length > 1) {
        for (var i = 1; i < numeric.length; i++) {
          if (numeric[i] == numeric[i - 1]) continue; // already reported
          if (numeric[i] != numeric[i - 1] + 1) {
            issues.add(Issue(Severity.warning,
                'FY $fy: sequence gap between ${numeric[i - 1]} and '
                '${numeric[i]} — if invoices were cancelled, keep them '
                'on record with a cancellation note'));
          }
        }
      }
    });
    return issues;
  }
}

String _stateName(int code) => '$code ${gstStateCodes[code] ?? "(unknown)"}';
