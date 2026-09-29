import 'package:flutter/material.dart';
import 'package:vasooli_client/vasooli_client.dart';

import 'fmt.dart';

/// Colored chip for an [InvoiceStatus] — one look, whole ledger readable.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      InvoiceStatus.draft => (const Color(0xFFE8E4DC), const Color(0xFF5A544A)),
      InvoiceStatus.sent => (const Color(0xFFDCEDFB), const Color(0xFF1565A7)),
      InvoiceStatus.paid => (const Color(0xFFDDF3E4), const Color(0xFF1E7A3C)),
      InvoiceStatus.overdue => (const Color(0xFFFBE0DC), const Color(0xFFB3261E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

/// One invoice as a ledger row — exactly the columns an Indian freelancer
/// scans for.
class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.invoice, this.onTap});

  final Invoice invoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inter = invoice.igst > 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(
              child: Text(
                invoice.clientName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              money(invoice.grandTotal),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '#${invoice.invoiceNumber} · taxable ${money(invoice.totalTaxable)} · '
            '${inter ? 'IGST' : 'CGST+SGST'} ${money(invoice.cgst + invoice.sgst + invoice.igst)}'
            '${invoice.dueDate != null ? ' · due ${displayDate(invoice.dueDate!)}' : ''}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
          ),
        ),
        trailing: StatusChip(invoice.status),
      ),
    );
  }
}
