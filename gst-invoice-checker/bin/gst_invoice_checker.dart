// GST invoice checker CLI.
//
// Usage:
//   dart run bin/gst_invoice_checker.dart check <file.json> [--json]
//   dart run bin/gst_invoice_checker.dart gstin <gstin> [more...] [--fix]
//   dart run bin/gst_invoice_checker.dart states
//
// Exit codes: 0 = clean, 1 = findings with severity error, 2 = bad input.
import 'dart:convert';
import 'dart:io';

import 'package:gst_invoice_checker/gst_invoice_checker.dart';

void main(List<String> args) {
  if (args.isEmpty) _usage();

  switch (args.first) {
    case 'check':
      _check(args.sublist(1));
    case 'gstin':
      _gstin(args.sublist(1));
    case 'states':
      for (final e in gstStateCodes.entries) {
        stdout.writeln('${e.key.toString().padLeft(2)}  ${e.value}');
      }
    default:
      _usage();
  }
}

Never _usage([String? message]) {
  if (message != null) stderr.writeln('error: $message');
  stderr.writeln('''
GST invoice checker — offline validation for freelancers' GST invoices.

Commands:
  check <file.json> [--json]  Validate a file of invoices (Rule 46 numbers,
                              GSTIN check digits, PoS tax split, rounding).
  gstin <gstin> [more...]     Validate GSTINs: format + check digit.
      [--fix]                 Also print the check digit each first-14-prefix
                              would need, so a mistyped GSTIN can be repaired.
  states                      List valid GST state codes.

Exit codes: 0 clean, 1 errors found, 2 bad input.
''');
  exit(2);
}

void _check(List<String> args) {
  final jsonOut = args.remove('--json');
  if (args.length != 1) _usage('check needs exactly one file path');
  final path = args.single;

  final File source;
  try {
    source = File(path);
    if (!source.existsSync()) {
      stderr.writeln('error: no such file: $path');
      exit(2);
    }
  } catch (e) {
    stderr.writeln('error: $e');
    exit(2);
  }

  final FileHeader header;
  try {
    final decoded = jsonDecode(source.readAsStringSync());
    if (decoded is! Map) {
      _usage('top level of $path must be a JSON object');
    }
    header = decodeInvoiceFile(decoded.cast<String, Object?>());
  } on FormatException catch (e) {
    stderr.writeln('error in $path: ${e.message}');
    exit(2);
  }

  final checker = InvoiceChecker(
    supplierStateCode: header.supplierStateCode,
    defaultFinancialYear: header.financialYear,
  );

  final issues = <Issue>[];
  for (final inv in header.invoices) {
    issues.addAll(checker.checkInvoice(inv));
  }
  issues.addAll(checker.checkSet(header.invoices));

  issues.sort((a, b) => a.severity.index.compareTo(b.severity.index));
  final errors = issues.where((i) => i.severity == Severity.error).length;
  final warnings = issues.where((i) => i.severity == Severity.warning).length;

  if (jsonOut) {
    stdout.writeln(jsonEncode({
      'file': path,
      'invoices': header.invoices.length,
      'errors': errors,
      'warnings': warnings,
      'issues': issues.map((i) => i.toJson()).toList(),
    }));
  } else {
    stdout.writeln('checked ${header.invoices.length} invoice(s), '
        'supplier state ${header.supplierStateCode}, FY ${header.financialYear}');
    if (issues.isEmpty) {
      stdout.writeln('✓ no findings');
    } else {
      for (final issue in issues) {
        stdout.writeln(issue);
      }
    }
    stdout.writeln('$errors error(s), $warnings warning(s)');
  }
  exit(errors > 0 ? 1 : 0);
}

void _gstin(List<String> args) {
  final fix = args.remove('--fix');
  if (args.isEmpty) _usage('gstin needs at least one GSTIN');

  var hadError = false;
  for (final gstin in args) {
    final upper = gstin.toUpperCase();
    final problems = gstinProblems(upper);
    if (problems.isEmpty) {
      stdout.writeln('✓ $upper  (state: '
          '${gstStateCodes[gstinStateCode(upper)!]})');
    } else {
      hadError = true;
      for (final p in problems) {
        stdout.writeln('✗ $upper  $p');
      }
    }
    if (fix && upper.length >= 14) {
      try {
        final check = gstinCheckChar(upper.substring(0, 14));
        stdout.writeln('  → corrected check digit: "$check" — full GSTIN '
            'would be ${upper.substring(0, 14)}$check');
      } catch (_) {/* reported above already */}
    }
  }
  exit(hadError ? 1 : 0);
}
