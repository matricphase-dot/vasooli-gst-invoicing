import 'package:serverpod/serverpod.dart';

import '../channels.dart';
import '../generated/protocol.dart';

/// Background jobs for reminders. Serverpod runs these from the database
/// (survives restarts), including recurring ones scheduled with cron.
class ReminderCalls extends FutureCall<ReminderScan> {
  /// Daily overdue scan: flips every non-paid invoice whose due date has
  /// passed to `overdue` and broadcasts each change, so any device that is
  /// watching the invoices stream updates instantly.
  Future<void> overdueScan(Session session, ReminderScan trigger) async {
    final fy = trigger.financialYear;
    final List<Invoice> candidates = fy == null
        ? await Invoice.db.find(session)
        : await Invoice.db.find(
            session,
            where: (t) => t.financialYear.equals(fy),
          );

    var changed = 0;
    for (final invoice in candidates) {
      if (invoice.status != InvoiceStatus.draft &&
          invoice.status != InvoiceStatus.sent) {
        continue; // paid or already overdue — leave untouched
      }
      final due = invoice.dueDate;
      if (due == null || !due.isBefore(DateTime.now())) continue;
      invoice.status = InvoiceStatus.overdue;
      final updated = await Invoice.db.updateRow(session, invoice);
      await session.messages.postMessage(invoicesUpdatesChannel, updated);
      changed++;
    }
    if (changed > 0) {
      session.log(
        'overdueScan: $changed invoice(s) flipped to overdue${fy != null ? ' in FY $fy' : ''}',
      );
    }
  }
}
