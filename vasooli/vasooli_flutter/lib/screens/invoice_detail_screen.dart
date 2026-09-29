import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:vasooli_client/vasooli_client.dart';

import '../client.dart';
import '../fmt.dart';
import '../invoice_pdf.dart';
import '../widgets.dart';

/// One invoice, full detail, with the two actions a freelancer actually
/// takes: record the UPI payment when the credit notification lands, and
/// share the Rule-46-correct PDF with the client's accounts team.
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.onChanged,
  });

  final Invoice invoice;
  final VoidCallback onChanged;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _inv = widget.invoice;
  bool _busy = false;
  String? _error;

  Future<void> _recordPayment() async {
    final methodCtrl = ValueNotifier<PaymentMethod>(PaymentMethod.upi);
    final refCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final amountCtrl =
        TextEditingController(text: _inv.grandTotal.toStringAsFixed(0));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record payment'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (must match ${money(_inv.grandTotal)})',
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<PaymentMethod>(
                valueListenable: methodCtrl,
                builder: (_, m, _) => DropdownButtonFormField<PaymentMethod>(
                  initialValue: m,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: PaymentMethod.values
                      .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                      .toList(),
                  onChanged: (v) => methodCtrl.value = v ?? PaymentMethod.upi,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'UPI ref / UTR (optional)',
                  hintText: 'from the UPI credit notification',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await client.invoices.recordPayment(
        invoiceId: _inv.id!,
        amount: double.parse(amountCtrl.text),
        method: methodCtrl.value,
        upiReference: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _inv = updated);
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('#${_inv.invoiceNumber} marked paid — every open '
              'device just saw it'),
        ),
      );
    } catch (e) {
      setState(() => _error =
          // The server refuses double-pays and partial amounts with a
          // precise message — surface it verbatim.
          '$e'.replaceFirst('ServerpodClientException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sharePdf() async {
    try {
      final bytes = await buildInvoicePdf(_inv);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice-${_inv.invoiceNumber.replaceAll('/', '-')}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final inter = _inv.igst > 0;
    final payable = _inv.status != InvoiceStatus.paid &&
        _inv.status != InvoiceStatus.draft;
    return Scaffold(
      appBar: AppBar(
        title: Text('#${_inv.invoiceNumber}'),
        actions: [Padding(
          padding: const EdgeInsets.only(right: 16, top: 18),
          child: StatusChip(_inv.status),
        )],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_inv.clientName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  if (_inv.clientGstin != null)
                    Text('GSTIN ${_inv.clientGstin}',
                        style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text(
                    'Issued ${displayDate(_inv.issueDate)}'
                    '${_inv.dueDate != null ? ' · due ${displayDate(_inv.dueDate!)}' : ''}'
                    ' · FY ${_inv.financialYear}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final l in _inv.lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(l.description,
                                style: const TextStyle(fontSize: 13.5)),
                          ),
                          Expanded(
                            child: Text('SAC ${l.hsnSac}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11.5, color: Colors.grey.shade600)),
                          ),
                          Expanded(
                            child: Text('${l.gstRatePercent.toStringAsFixed(0)}%',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11.5, color: Colors.grey.shade600)),
                          ),
                          Expanded(
                            child: Text(money(l.taxableValue),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13.5)),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  _totalRow('Taxable', _inv.totalTaxable),
                  if (!inter) ...[
                    _totalRow('CGST', _inv.cgst),
                    _totalRow('SGST', _inv.sgst),
                  ] else
                    _totalRow('IGST', _inv.igst),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inter ? 'Total (inter-state)' : 'Total (intra-state)',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(money(_inv.grandTotal),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: VasooliColors.saffron)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              if (payable)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _recordPayment,
                    icon: const Icon(Icons.currency_rupee),
                    label: Text(_busy ? 'Recording…' : 'Record payment'),
                  ),
                ),
              if (payable) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Share PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(money(value)),
        ],
      ),
    );
  }
}

class VasooliColors {
  static const saffron = Color(0xFFE8710A);
}
