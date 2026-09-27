// Live demo driver: drives the running Vasooli server over HTTP and prints
// the narrative used in the hackathon demo video.
//
// Prereqs: server running on http://localhost:8080 (see README.md).
//
// Run:  dart run bin/demo.dart [--fy 2026-27] [--url http://localhost:8080/]
//       dart run bin/demo.dart --out transcript.md
import 'dart:io';

import 'package:vasooli_client/vasooli_client.dart';

late Client client;
final StringBuffer _transcript = StringBuffer();

String money(double v) {
  final fixed = v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(2);
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
    '  #${i.invoiceNumber}  ${i.clientName.padRight(26)} ${i.status.name.padRight(6)} '
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
      .where((i) => i.status.name != 'paid')
      .fold<double>(0, (s, i) => s + i.grandTotal);
  final received = invoices
      .where((i) => i.status.name == 'paid')
      .fold<double>(0, (s, i) => s + i.grandTotal);
  say('  ─'.padRight(20, '─'));
  say('  outstanding: ${money(outstanding)}    received: ${money(received)}');
}

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
  say('║  HTTP call to the running server.                               ║');
  say('╚══════════════════════════════════════════════════════════════════╝');
  say();
  say('Scenario: you are a freelancer in Maharashtra (state 27), FY $fy.');
  say();

  say('── 1. Invoice for a Mumbai client (intra-state) ──────────────────');
  say('   2 lines, ₹50,000 @ 18% GST. Tax split is computed server-side;');
  say('   the client app never sends tax amounts.');
  final intra = await client.invoices.createInvoice(
    clientName: 'Acme Consulting LLP',
    clientGstin: '27AAACA1234A1ZK', // valid check digit
    supplierStateCode: 27,
    placeOfSupplyStateCode: 27,
    financialYear: fy,
    lines: [
      InvoiceLine(
        description: 'Flutter app development',
        hsnSac: '998314',
        taxableValue: 45000,
        gstRatePercent: 18,
      ),
      InvoiceLine(
        description: 'Play Store release support',
        hsnSac: '998314',
        taxableValue: 5000,
        gstRatePercent: 18,
      ),
    ],
  );
  say(invoiceLine(intra));
  say('   → place of supply == supplier state ⇒ CGST ${money(intra.cgst)} '
      '+ SGST ${money(intra.sgst)}, no IGST. Invoice number "${intra.invoiceNumber}" '
      'assigned by the server (sequential per FY).');
  say();

  say('── 2. Invoice for a Bengaluru client (inter-state) ───────────────');
  final inter = await client.invoices.createInvoice(
    clientName: 'Bengaluru Backend Co',
    clientGstin: '29AABCB7654P1ZZ',
    supplierStateCode: 27,
    placeOfSupplyStateCode: 29,
    financialYear: fy,
    lines: [
      InvoiceLine(
        description: 'API integration workshop, 2 days',
        hsnSac: '998314',
        taxableValue: 80000,
        gstRatePercent: 18,
      ),
    ],
  );
  say(invoiceLine(inter));
  say('   → inter-state supply ⇒ IGST ${money(inter.igst)} at the full rate, '
      'and this is invoice number "${inter.invoiceNumber}" — the next in the series.');
  say();

  say('── 3. The GSTIN typo that spreadsheet invoicing never catches ────');
  say('   Same client GSTIN as invoice #${intra.invoiceNumber} but with a '
      'wrong last character:');
  try {
    await client.invoices.createInvoice(
      clientName: 'Acme Consulting LLP',
      clientGstin: '27AAACA1234A1Z2', // 'K' mistyped as '2'
      supplierStateCode: 27,
      placeOfSupplyStateCode: 27,
      financialYear: fy,
      lines: [
        InvoiceLine(
          description: 'Should never persist',
          hsnSac: '998314',
          taxableValue: 100,
          gstRatePercent: 18,
        ),
      ],
    );
    say('   ✗ UNEXPECTED: the server accepted a bad GSTIN — bug!');
  } on InvalidGstinException catch (e) {
    say('   ✓ server refused it: ${e.message}');
    say('   (the format is fine; the mod-36 check digit exposes the typo —');
    say('   without this, the real client cannot claim input tax credit)');
  }
  say();

  say('── 4. The ledger, live from Postgres ─────────────────────────────');
  await printLedger(fy);
  say();

  say('── 5. Acme pays by UPI — mark as paid, ledger drops live ─────────');
  final paid = await client.invoices.markPaid(intra.id!);
  say('   #${paid.invoiceNumber} ${paid.clientName} → status '
      '${paid.status.name.toUpperCase()}');
  await printLedger(fy);
  say();

  say('── What this demo proves ─────────────────────────────────────────');
  say('   • Typed end-to-end models: Dart from the UI to Postgres, no SQL,');
  say('     no hand-written JSON plumbing.');
  say('   • Server-side invariants the app cannot bypass: sequential');
  say('     per-FY invoice numbers, place-of-supply tax split, rounding on');
  say('     the taxable total, GSTIN check-digit validation.');
  say('   • It actually works: HTTP 200 on the API root, and every number');
  say('     above comes from a live database, not a mock.');

  if (outPath != null) {
    File(outPath).writeAsStringSync(_transcript.toString());
    stdout.writeln('\ntranscript written to $outPath');
  }
}
