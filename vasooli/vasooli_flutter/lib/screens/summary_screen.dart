import 'package:flutter/material.dart';
import 'package:vasooli_client/vasooli_client.dart';

import '../client.dart';
import '../fmt.dart';

const _months = [
  'April', 'May', 'June', 'July', 'August', 'September',
  'October', 'November', 'December', 'January', 'February', 'March',
];

/// Month-end, done: taxable/collected/outstanding plus the GSTR-ready tax
/// split. Computed live on the server from the ledger — nothing precomputed,
/// nothing losable.
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.fy});

  final String fy;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late int _month = DateTime.now().month;
  MonthlySummary? _summary;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await client.invoices.monthlySummary(widget.fy, _month);
      if (!mounted) return;
      setState(() => _summary = s);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calendar month index: April (start of FY) is index 0.
    final fyMonths = [
      for (var m = 4; m <= 12; m++) m,
      for (var m = 1; m <= 3; m++) m,
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Month-end · FY ${widget.fy}')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final m in fyMonths)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_months[m - 4]),
                      selected: _month == m,
                      onSelected: (_) {
                        setState(() => _month = m);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Failed: $_error'))
                    : _buildBody(_summary!),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MonthlySummary s) {
    Widget section(String title, List<Widget> rows) => Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 8),
                ...rows,
              ],
            ),
          ),
        );

    Widget row(String label, String value, {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                      color: color)),
            ],
          ),
        );

    return ListView(
      children: [
        section('Invoices', [
          row('Raised', '${s.invoiceCount}'),
          row('Draft', '${s.draftCount}'),
          row('Sent / awaiting payment', '${s.sentCount}'),
          row('Overdue', '${s.overdueCount}',
              color: s.overdueCount > 0 ? Colors.red : null),
          row('Paid', '${s.paidCount}',
              color: const Color(0xFF1E7A3C)),
        ]),
        section('GST (the GSTR story)', [
          row('Taxable turnover', money(s.totalTaxable), bold: true),
          row('CGST', money(s.cgst)),
          row('SGST', money(s.sgst)),
          row('IGST', money(s.igst)),
          row('Output tax', money(s.cgst + s.sgst + s.igst), bold: true),
        ]),
        section('Cash', [
          row('Collected this FY', money(s.collected),
              color: const Color(0xFF1E7A3C), bold: true),
          row('Still outstanding', money(s.outstanding),
              color: Colors.red.shade700, bold: true),
        ]),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Text(
            'The screen your CA wants: taxable value per supply split into '
            'CGST/SGST/IGST, reconciled against money actually received.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
