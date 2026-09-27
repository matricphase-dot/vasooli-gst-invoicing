// Live demo driver: drives the running Vasooli server over HTTP (and the
// invoices stream over websockets) and prints the narrative used in the
// hackathon demo video.
//
// Prereq: server running on http://localhost:8080 (see README.md).
//
// Run:  dart run bin/demo.dart [--fy 2026-27] [--url http://localhost:8080/]
//       dart run bin/demo.dart --out transcript.md
import 'dart:io';

import 'package:vasooli_client/vasooli_client.dart';

late Client client;
final StringBuffer _transcript = StringBuffer();

String money(double v) {
  final fixed =
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts.first;
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final fromEnd = intPart.length - i;
    buf.write(intPart[i]);
    if (fromEnd > 1 && (fromEnd - 1) % 3 == 0) buf.write(',');
  }
  return '₹$buf${parts.length > 1 ? '.${parts[1]}' : ''}';
}

void say([String line = '']) {
  stdout.writeln(line);
  _transcript.writeln(line);
}

String invoiceLine(Invoice i) =>
    '  #${i.invoiceNumber}  ${i.clientName.padRight(26)} ${i.status.name.padRight(7)} '
    'taxable ${money(i.totalTaxable).padLeft(10)} '
    'CGST ${money(i.cgst).padLeft(7)} SGST ${money(i.sgst).padLeft(7)} '
    'IGST ${money(i.igst).padLeft(9)} total ${money(i.grandTotal).padLeft(10)}';

Future<void> printLedger(String fy) async {
  final invoices = await client.invoices.listInvoices(fy);
  if (invoices.isEmpty) {
    say('  (no invoices in FY $fy yet)');
    return;
  }
  for (final inv in invoices) {
    say(invoiceLine(inv));
  }
  final outstanding = invoices
      .where((i) => i.status != InvoiceStatus.paid)
      .fold<double>(0, (s, i) => s + i.grandTotal);
  final received = invoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold<double>(0, (s, i) => s + i.grandTotal);
  say('  ${'─' * 18}');
  say('  outstanding: ${money(outstanding)}    received: ${money(received)}');
}

InvoiceLine line(String description, double taxable) => InvoiceLine(
      description: description,
      hsnSac: '998314',
      taxableValue: taxable,
      gstRatePercent: 18,
    );

Future<void> main(List<String> args) async {
  var fy = '2026-27';
  var url = 'http://localhost:8080/';
  String? outPath;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--fy':
        fy = args[++i];
      case '--url':
        url = args[++i];
      case '--out':
        outPath = args[++i];
      default:
        stderr.writeln('unknown argument: ${args[i]}');
        exit(2);
    }
  }
  client = Client(url);

  say('╔══════════════════════════════════════════════════════════════════╗');
  say('║  VASOOLI — GST invoicing for Indian freelancers, live on        ║');
  say('║  Serverpod 4. Demo driver, no UI: every call below is a real    ║');
  say('║  request to the running server.                                 ║');
  say('╚══════════════════════════════════════════════════════════════════╝');
  say();
  say('Scenario: you are a freelancer in Maharashtra (state 27), FY $fy.');
  say();

  say('── 0. The live feed is already listening ─────────────────────────');
  final streamed = <Invoice>[];
  final sub = client.invoices.watchInvoices().listen((invoice) {
    streamed.add(invoice);
  });
  say('   subscribed to the invoices stream — every server-side change from');
  say('   here on should appear over the wire, no polling.');
  // Give the stream a beat to fully connect before mutations start;
  // events posted before the connection is established are not replayed.
  await Future<void>.delayed(const Duration(seconds: 2));
  say();

  say('── 1. Invoice for a Mumbai client (intra-state), due next week ───');
  final in7d = DateTime.now().add(const Duration(days: 7));
  final intra = await client.invoices.createInvoice(
    clientName: 'Acme Consulting LLP',
    clientGstin: '27AAACA1234A1ZK', // valid check digit
    supplierStateCode: 27,
    placeOfSupplyStateCode: 27,
    financialYear: fy,
    dueDate: in7d,
    lines: [
      line('Flutter app development', 45000),
      line('Play Store release support', 5000),
    ],
  );
  say(invoiceLine(intra));
  say('   → place of supply == supplier state ⇒ CGST ${money(intra.cgst)} '
      '+ SGST ${money(intra.sgst)}. Number "${intra.invoiceNumber}" assigned '
      'by the server (sequential per FY). Due ${in7d.toLocal().toString().split(' ').first}.');
  say();

  say('── 2. Invoice for a Bengaluru client (inter-state), ALREADY DUE ──');
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final inter = await client.invoices.createInvoice(
    clientName: 'Bengaluru Backend Co',
    clientGstin: '29AABCB7654P1ZZ',
    supplierStateCode: 27,
    placeOfSupplyStateCode: 29,
    financialYear: fy,
    dueDate: yesterday, // they never paid on time
    lines: [line('API integration workshop, 2 days', 80000)],
  );
  say(invoiceLine(inter));
  say('   → inter-state supply ⇒ IGST ${money(inter.igst)}; due date is in');
  say('   the past, so the overdue machinery below should catch it.');
  say();

  say('── 3. The GSTIN typo that spreadsheet invoicing never catches ────');
  try {
    await client.invoices.createInvoice(
      clientName: 'Acme Consulting LLP',
      clientGstin: '27AAACA1234A1Z2', // 'K' mistyped as '2'
      supplierStateCode: 27,
      placeOfSupplyStateCode: 27,
      financialYear: fy,
      lines: [line('Should never persist', 100)],
    );
    say('   ✗ UNEXPECTED: the server accepted a bad GSTIN — bug!');
  } on InvalidGstinException catch (e) {
    say('   ✓ server refused it: ${e.message}');
    say('   (format is fine; the mod-36 check digit exposes the typo —');
    say('   without this, the real client cannot claim input tax credit)');
  }
  say();

  say('── 4. The ledger, live from Postgres ─────────────────────────────');
  await printLedger(fy);
  say();

  say('── 5. The daily overdue scan runs (a future call runs it at 09:00) ');
  final changed = await client.invoices.scanOverdue(fy);
  say('   $changed invoice(s) flipped to overdue this pass:');
  for (final inv in await client.invoices.listInvoices(fy)) {
    if (inv.status == InvoiceStatus.overdue) say(invoiceLine(inv));
  }
  say();

  say('── 6. Acme pays ${money(intra.grandTotal)} by UPI — recorded with the UPI ref ──');
  final paid = await client.invoices.recordPayment(
    invoiceId: intra.id!,
    amount: intra.grandTotal,
    method: PaymentMethod.upi,
    upiReference: 'UTR-20260927-8843',
  );
  say('   #${paid.invoiceNumber} ${paid.clientName} → ${paid.status.name.toUpperCase()}'
      '   UPI ref UTR-20260927-8843 saved on the Payment row');
  say('   (an extra ₹1 or a repeat tap of pay is refused — exact-amount ledger)');
  await printLedger(fy);
  say();

  say('── 7. What my phone would have shown the whole time ──────────────');
  await Future<void>.delayed(const Duration(seconds: 2));
  await sub.cancel();
  if (streamed.isEmpty) {
    say('   (no stream events received — check the stream path!)');
  } else {
    say('   over the invoices stream, unprompted, arrived:');
    for (final inv in streamed) {
      say(invoiceLine(inv));
    }
    say('   → the same hook the Flutter app uses; its UI tier is built on');
    say('     exactly these events, which is why two devices stay in sync.');
  }
  say();

  say('── 8. Month-end, done ────────────────────────────────────────────');
  final summary = await client.invoices.monthlySummary(fy, DateTime.now().month);
  say('   FY ${summary.financialYear}, month ${summary.month}: '
      '${summary.invoiceCount} invoices '
      '(${summary.paidCount} paid, ${summary.overdueCount} overdue, '
      '${summary.draftCount} draft, ${summary.sentCount} sent)');
  say('   taxable ${money(summary.totalTaxable)}  '
      'CGST ${money(summary.cgst)}  SGST ${money(summary.sgst)}  '
      'IGST ${money(summary.igst)}');
  say('   collected ${money(summary.collected)}  '
      'still out ${money(summary.outstanding)}');
  say();

  say('── What this demo proves ─────────────────────────────────────────');
  say('   • typed end-to-end models (Dart UI → Postgres, no SQL, no JSON),');
  say('   • server-side invariants the app cannot bypass: sequential per-FY');
  say('     numbers, place-of-supply tax split, rounding on the total, GSTIN');
  say('     check-digit validation, no partial payments, no double-paying;');
  say('   • Serverpod 4 doing what it\u2019s good at: a real stream feeding every');
  say('     device, a recurring future call for the daily overdue scan, and');
  say('     typed exceptions reaching the caller with a precise message;');
  say('   • it works: every number above is a live DB row, not a mock.');

  if (outPath != null) {
    File(outPath).writeAsStringSync(_transcript.toString());
    stdout.writeln('\ntranscript written to $outPath');
  }
}
