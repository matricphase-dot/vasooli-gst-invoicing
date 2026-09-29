/// Formatting helpers shared across the app: Indian-style money (₹ with
/// lakh grouping), financial-year strings (April–March), and display labels.
library;

import 'package:intl/intl.dart';

final _inr = NumberFormat.decimalPattern('en_IN');

/// `59400.0` -> `₹59,400`
String money(num v) => '₹${_inr.format(v)}';

/// Indian GST financial year for [d], e.g. `2026-27` for anything between
/// 1 Apr 2026 and 31 Mar 2027.
String financialYearOf(DateTime d) {
  final start = d.month >= 4 ? d.year : d.year - 1;
  return '$start-${(start + 1) % 100}'.padLeft(0);
}

/// The label the demo used, kept identical so app + demo + tests share a
/// financial-year namespace on the same database.
String currentFinancialYear() => financialYearOf(DateTime.now());

/// "27AAAC...1ZK" -> state code 27, or null when not parseable.
int? gstinStateCode(String? gstin) {
  if (gstin == null || gstin.length < 2) return null;
  return int.tryParse(gstin.substring(0, 2));
}

/// Human labels for invoice statuses (UI keeps the enum for logic).
String statusLabel(Object status) => switch (status.toString().split('.').last) {
      'draft' => 'Draft',
      'sent' => 'Sent',
      'paid' => 'Paid',
      'overdue' => 'Overdue',
      _ => status.toString(),
    };

String displayDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);
