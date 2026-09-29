import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vasooli_client/vasooli_client.dart';

import '../client.dart';
import '../fmt.dart';
import '../widgets.dart';
import 'invoice_detail_screen.dart';
import 'new_invoice_screen.dart';
import 'summary_screen.dart';

/// The home screen: live ledger driven by the `watchInvoices` SERVER STREAM,
/// with running outstanding/collected chips. Open this on two devices and
/// mutate from one — the other updates with no refresh. That property is the
/// core product claim.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final fy = currentFinancialYear();
  List<Invoice> _invoices = [];
  bool _loading = true;
  Object? _error;
  StreamSubscription<Invoice>? _sub;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _load();
    _listen();
  }

  Future<void> _listen() async {
    await _sub?.cancel();
    try {
      _sub = client.invoices.watchInvoices().listen((inv) {
        if (!mounted || inv.financialYear != fy) return;
        setState(() {
          final i = _invoices.indexWhere((e) => e.id == inv.id);
          if (i >= 0) {
            _invoices[i] = inv;
          } else {
            _invoices.add(inv);
            _invoices.sort(
                (a, b) => a.invoiceNumber.compareTo(b.invoiceNumber));
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Invoice #${inv.invoiceNumber} (${inv.clientName}) is now '
            '${statusLabel(inv.status)}',
          ),
        ));
      });
    } catch (_) {
      // Stream is a bonus layer; the manual refresh still guarantees truth.
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await client.invoices.listInvoices(fy);
      if (!mounted) return;
      setState(() => _invoices = rows);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _rescan() async {
    setState(() => _scanning = true);
    try {
      final flipped = await client.invoices.scanOverdue(fy);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(flipped == 0
            ? 'Overdue scan: nothing new past due'
            : 'Overdue scan flipped $flipped invoice(s)'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  double get _outstanding => _invoices
      .where((i) => i.status != InvoiceStatus.paid && i.status != InvoiceStatus.draft)
      .fold<double>(0, (s, i) => s + i.grandTotal);

  double get _received => _invoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold<double>(0, (s, i) => s + i.grandTotal);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vasooli',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            Text('FY $fy · live ledger',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Run overdue scan',
            onPressed: _scanning ? null : _rescan,
            icon: _scanning
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.alarm_on_outlined),
          ),
          IconButton(
            tooltip: 'Monthly summary',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SummaryScreen(fy: fy)),
            ),
            icon: const Icon(Icons.summarize_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _KpiChip(
                  label: 'Still out',
                  value: money(_outstanding),
                  color: scheme.error,
                ),
                const SizedBox(width: 12),
                _KpiChip(
                  label: 'Collected',
                  value: money(_received),
                  color: const Color(0xFF1E7A3C),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _load)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _invoices.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Text(
                                      'No invoices yet.\nTap + to raise your first GST invoice.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _invoices.length,
                                padding: const EdgeInsets.only(bottom: 90),
                                itemBuilder: (_, i) => InvoiceTile(
                                  invoice: _invoices[i],
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => InvoiceDetailScreen(
                                          invoice: _invoices[i],
                                          onChanged: _load,
                                        ),
                                      ),
                                    );
                                    _load();
                                  },
                                ),
                              ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => NewInvoiceScreen(fy: fy)),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('New invoice'),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            Text('Could not reach the server:\n$error',
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
