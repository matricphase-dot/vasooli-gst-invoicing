╔══════════════════════════════════════════════════════════════════╗
║  VASOOLI — GST invoicing for Indian freelancers, live on        ║
║  Serverpod 4. Demo driver, no UI: every call below is a real    ║
║  request to the running server.                                 ║
╚══════════════════════════════════════════════════════════════════╝

Scenario: you are a freelancer in Maharashtra (state 27), FY 2026-27.

── 0. The live feed is already listening ─────────────────────────
   subscribed to the invoices stream — every server-side change from
   here on should appear over the wire, no polling.

── 1. Invoice for a Mumbai client (intra-state), due next week ───
  #1  Acme Consulting LLP        draft   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
   → place of supply == supplier state ⇒ CGST ₹4,500 + SGST ₹4,500. Number "1" assigned by the server (sequential per FY). Due 2026-10-06.

── 2. Invoice for a Bengaluru client (inter-state), ALREADY DUE ──
  #2  Bengaluru Backend Co       draft   taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
   → inter-state supply ⇒ IGST ₹14,400; due date is in
   the past, so the overdue machinery below should catch it.

── 3. The GSTIN typo that spreadsheet invoicing never catches ────
   ✓ server refused it: GSTIN "27AAACA1234A1Z2" failed format or check-digit validation — one of its 15 characters is mistyped
   (format is fine; the mod-36 check digit exposes the typo —
   without this, the real client cannot claim input tax credit)

── 4. The ledger, live from Postgres ─────────────────────────────
  #1  Acme Consulting LLP        draft   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #2  Bengaluru Backend Co       draft   taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  ──────────────────
  outstanding: ₹153,400    received: ₹0

── 5. The daily overdue scan runs (a future call runs it at 09:00) 
   1 invoice(s) flipped to overdue this pass:
  #2  Bengaluru Backend Co       overdue taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400

── 6. Acme pays ₹59,000 by UPI — recorded with the UPI ref ──
   #1 Acme Consulting LLP → PAID   UPI ref UTR-20260927-8843 saved on the Payment row
   (an extra ₹1 or a repeat tap of pay is refused — exact-amount ledger)
  #1  Acme Consulting LLP        paid    taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #2  Bengaluru Backend Co       overdue taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  ──────────────────
  outstanding: ₹94,400    received: ₹59,000

── 7. What my phone would have shown the whole time ──────────────
   over the invoices stream, unprompted, arrived:
  #1  Acme Consulting LLP        draft   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #2  Bengaluru Backend Co       draft   taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  #2  Bengaluru Backend Co       overdue taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  #1  Acme Consulting LLP        paid    taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
   → the same hook the Flutter app uses; its UI tier is built on
     exactly these events, which is why two devices stay in sync.

── 8. Month-end, done ────────────────────────────────────────────
   FY 2026-27, month 9: 2 invoices (1 paid, 1 overdue, 0 draft, 0 sent)
   taxable ₹130,000  CGST ₹4,500  SGST ₹4,500  IGST ₹14,400
   collected ₹59,000  still out ₹94,400

── What this demo proves ─────────────────────────────────────────
   • typed end-to-end models (Dart UI → Postgres, no SQL, no JSON),
   • server-side invariants the app cannot bypass: sequential per-FY
     numbers, place-of-supply tax split, rounding on the total, GSTIN
     check-digit validation, no partial payments, no double-paying;
   • Serverpod 4 doing what it’s good at: a real stream feeding every
     device, a recurring future call for the daily overdue scan, and
     typed exceptions reaching the caller with a precise message;
   • it works: every number above is a live DB row, not a mock.
