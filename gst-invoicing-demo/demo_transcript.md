╔══════════════════════════════════════════════════════════════════╗
║  VASOOLI — GST invoicing for Indian freelancers, live on        ║
║  Serverpod 4. Demo driver, no UI: every call below is a real    ║
║  HTTP call to the running server.                               ║
╚══════════════════════════════════════════════════════════════════╝

Scenario: you are a freelancer in Maharashtra (state 27), FY 2026-27.

── 1. Invoice for a Mumbai client (intra-state) ──────────────────
   2 lines, ₹50,000 @ 18% GST. Tax split is computed server-side;
   the client app never sends tax amounts.
  #4  Acme Consulting LLP        draft  taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
   → place of supply == supplier state ⇒ CGST ₹4,500 + SGST ₹4,500, no IGST. Invoice number "4" assigned by the server (sequential per FY).

── 2. Invoice for a Bengaluru client (inter-state) ───────────────
  #5  Bengaluru Backend Co       draft  taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
   → inter-state supply ⇒ IGST ₹14,400 at the full rate, and this is invoice number "5" — the next in the series.

── 3. The GSTIN typo that spreadsheet invoicing never catches ────
   Same client GSTIN as invoice #4 but with a wrong last character:
   ✓ server refused it: GSTIN "27AAACA1234A1Z2" failed format or check-digit validation — one of its 15 characters is mistyped
   (the format is fine; the mod-36 check digit exposes the typo —
   without this, the real client cannot claim input tax credit)

── 4. The ledger, live from Postgres ─────────────────────────────
  #1  Smoke Test Client          paid   taxable     ₹1,000 CGST     ₹90 SGST     ₹90 IGST        ₹0 total     ₹1,180
  #2  Acme Consulting LLP        paid   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #3  Bengaluru Backend Co       draft  taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  #4  Acme Consulting LLP        draft  taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #5  Bengaluru Backend Co       draft  taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  ──────────────────
  outstanding: ₹247,800    received: ₹60,180

── 5. Acme pays by UPI — mark as paid, ledger drops live ─────────
   #4 Acme Consulting LLP → status PAID
  #1  Smoke Test Client          paid   taxable     ₹1,000 CGST     ₹90 SGST     ₹90 IGST        ₹0 total     ₹1,180
  #2  Acme Consulting LLP        paid   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #3  Bengaluru Backend Co       draft  taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  #4  Acme Consulting LLP        paid   taxable    ₹50,000 CGST  ₹4,500 SGST  ₹4,500 IGST        ₹0 total    ₹59,000
  #5  Bengaluru Backend Co       draft  taxable    ₹80,000 CGST      ₹0 SGST      ₹0 IGST   ₹14,400 total    ₹94,400
  ──────────────────
  outstanding: ₹188,800    received: ₹119,180

── What this demo proves ─────────────────────────────────────────
   • Typed end-to-end models: Dart from the UI to Postgres, no SQL,
     no hand-written JSON plumbing.
   • Server-side invariants the app cannot bypass: sequential
     per-FY invoice numbers, place-of-supply tax split, rounding on
     the taxable total, GSTIN check-digit validation.
   • It actually works: HTTP 200 on the API root, and every number
     above comes from a live database, not a mock.
