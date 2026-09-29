import 'package:flutter/material.dart';
import 'package:vasooli_client/vasooli_client.dart';

import '../client.dart';
import '../fmt.dart';
import '../gstin.dart';

/// Raise a new GST invoice. The client collects only what a freelancer knows
/// (client, GSTIN, what was sold); the server assigns the per-FY invoice
/// number and computes every tax paisa — nothing here can bypass GST.
class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key, required this.fy});

  final String fy;

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _LineRow {
  final desc = TextEditingController();
  final hsn = TextEditingController(text: '9983');
  final taxable = TextEditingController();
  double gstRate = 18;

  void dispose() {
    desc.dispose();
    hsn.dispose();
    taxable.dispose();
  }
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _clientName = TextEditingController();
  final _clientGstin = TextEditingController();
  final _supplierState = TextEditingController(text: '27');
  int _placeOfSupply = 27;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final List<_LineRow> _lines = [_LineRow()];
  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _clientName.dispose();
    _clientGstin.dispose();
    _supplierState.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _taxable => _lines.fold<double>(
      0, (s, l) => s + (double.tryParse(l.taxable.text) ?? 0));

  double get _tax => _lines.fold<double>(
      0,
      (s, l) =>
          s + (double.tryParse(l.taxable.text) ?? 0) * (l.gstRate / 100));

  bool get _interState =>
      _placeOfSupply != (int.tryParse(_supplierState.text) ?? 27);

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: _dueDate,
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String? _validate() {
    if (_clientName.text.trim().isEmpty) return 'Client name is required';
    final g = _clientGstin.text.trim().toUpperCase();
    if (g.isNotEmpty) {
      final err = gstinError(g);
      if (err != null) return 'GSTIN: $err';
      final state = gstinStateCode(g);
      if (state != null && state != _placeOfSupply) {
        return 'GSTIN belongs to state $state but place of supply is '
            '$_placeOfSupply — fix one of them (the server would too)';
      }
    }
    if (_lines.every((l) => (double.tryParse(l.taxable.text) ?? 0) <= 0)) {
      return 'Add at least one line with a taxable amount';
    }
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _serverError = err);
      return;
    }
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final g = _clientGstin.text.trim().toUpperCase();
      await client.invoices.createInvoice(
        clientName: _clientName.text.trim(),
        clientGstin: g.isEmpty ? null : g,
        supplierStateCode: int.tryParse(_supplierState.text) ?? 27,
        placeOfSupplyStateCode: _placeOfSupply,
        financialYear: widget.fy,
        lines: [
          for (final l in _lines)
            if ((double.tryParse(l.taxable.text) ?? 0) > 0)
              InvoiceLine(
                description:
                    l.desc.text.trim().isEmpty ? 'Services' : l.desc.text.trim(),
                hsnSac: l.hsn.text.trim().isEmpty ? '9983' : l.hsn.text.trim(),
                taxableValue: double.parse(l.taxable.text),
                gstRatePercent: l.gstRate,
              ),
        ],
        dueDate: _dueDate,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on InvalidGstinException catch (e) {
      setState(() => _serverError = e.message);
    } catch (e) {
      setState(() => _serverError = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = _clientGstin.text.trim().toUpperCase();
    final gstinDerivedState = gstinStateCode(g);
    if (g.length >= 2 && gstinDerivedState != null) {
      // Live-derived: a typed GSTIN implies place of supply on its own.
      if (_placeOfSupply != gstinDerivedState && g.length == 15) {
        _placeOfSupply = gstinDerivedState;
      }
    }
    final inter = _interState;

    return Scaffold(
      appBar: AppBar(title: const Text('New invoice')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          TextField(
            controller: _clientName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Client name',
              hintText: 'Acme Consulting LLP',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clientGstin,
            textCapitalization: TextCapitalization.characters,
            maxLength: 15,
            decoration: InputDecoration(
              labelText: 'Client GSTIN (optional)',
              hintText: '27AAACA1234A1ZK',
              helperText: g.isEmpty
                  ? null
                  : (gstinError(g) ?? 'Valid GSTIN — state ${gstinDerivedState ?? '?'}'),
              helperStyle: TextStyle(
                color: gstinError(g) == null ? Colors.green.shade700 : Colors.red,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _supplierState,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: 'Your state code',
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Place of supply: state $_placeOfSupply',
                            style: const TextStyle(fontSize: 13)),
                        Text(
                          inter ? '→ IGST applies' : '→ CGST + SGST applies',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: inter ? Colors.deepOrange : Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDueDate,
            icon: const Icon(Icons.event),
            label: Text('Due ${displayDate(_dueDate)}'),
          ),
          const SizedBox(height: 16),
          const Text('Line items',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          for (final l in _lines) _lineEditor(l),
          TextButton.icon(
            onPressed: () => setState(() => _lines.add(_LineRow())),
            icon: const Icon(Icons.add),
            label: const Text('Another line'),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Taxable ${money(_taxable)}',
                          style: const TextStyle(fontSize: 13)),
                      Text(
                          inter
                              ? 'IGST ${money(_tax.roundToDouble())}'
                              : 'CGST ${money(_tax / 2)} + SGST ${money(_tax / 2)} (approx)',
                          style: const TextStyle(fontSize: 13)),
                      const Text('Server computes the official split',
                          style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                  Text(money((_taxable + _tax).roundToDouble()),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          if (_serverError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE0DC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_serverError!,
                  style: const TextStyle(color: Color(0xFFB3261E))),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.receipt_long),
            label: const Text('Raise invoice on the server'),
          ),
        ],
      ),
    );
  }

  Widget _lineEditor(_LineRow l) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: l.desc,
              decoration: const InputDecoration(
                labelText: 'Description',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: l.hsn,
                    decoration: const InputDecoration(
                        labelText: 'HSN/SAC', isDense: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: l.taxable,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Taxable ₹', isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<double>(
                  value: l.gstRate,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0%')),
                    DropdownMenuItem(value: 5, child: Text('5%')),
                    DropdownMenuItem(value: 12, child: Text('12%')),
                    DropdownMenuItem(value: 18, child: Text('18%')),
                    DropdownMenuItem(value: 28, child: Text('28%')),
                  ],
                  onChanged: (v) => setState(() => l.gstRate = v ?? 18),
                ),
                if (_lines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _lines.remove(l)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
