# gst-invoice-checker

Offline validation for the GST invoices Indian freelancers actually write: the
spreadsheet-era mistakes — a mistyped GSTIN, IGST on an intra-state bill, tax
rounded per line, a duplicated document number — printed as plain, actionable
findings. Zero third-party dependencies; pure Dart.

It is the standalone sibling of the server-side invariants in
[`../vasooli`](../vasooli) (the hackathon app): the tax math is deliberately
duplicated in both places, so a bug in either copy shows up as a disagreement
between them rather than as silent wrong invoices.

## What it checks

| Rule | Finding level |
|---|---|
| Rule 46 document number: max 16 chars, letters/digits/`/`/`-` only | error |
| Document numbers unique per financial year (Rule 46) | error |
| Gaps in an all-numeric series (cancelled/missing invoices) | warning |
| GSTIN format (15 chars, PAN-style body, `Z`, check char) | error |
| **GSTIN mod-36 check digit** — catches a single mistyped character | error |
| GST state codes valid (supplier, buyer GSTIN, place of supply) | error |
| Intra-state supply must be CGST+SGST; inter-state must be IGST | error |
| Tax recomputed from lines: rounded **on the invoice total, not per line** | error |
| Grand total == taxable + tax | error |
| Recognised GST slabs: 0 / 0.25 / 3 / 5 / 12 / 18 / 28 % | error |
| HSN/SAC 4, 6 or 8 digits; non-empty description; non-negative amounts | error |
| Buyer GSTIN state ≠ place of supply (usually wrong for B2B services) | warning |
| Missing client GSTIN (fine below the threshold; B2B usually expects one) | info |

> **Verify before filing with it.** The GST rules here (thresholds, states list,
> accepted formats) encode the publicly documented structure plus the GSTN
> check-digit algorithm. This is a freelancer's copy-edit tool, not a
> substitute for the CGST Rules text — same caveat as the main project notes.

## Usage

```bash
dart pub get

# Validate a file of invoices (see example/ for the JSON shape)
dart run bin/gst_invoice_checker.dart check example/good_invoices.json
dart run bin/gst_invoice_checker.dart check example/bad_invoices.json
dart run bin/gst_invoice_checker.dart check my_invoices.json --json

# Validate GSTINs directly; --fix prints the check digit the prefix needs
dart run bin/gst_invoice_checker.dart gstin 27AAACA1234A1ZK
dart run bin/gst_invoice_checker.dart gstin 27AAACA1234A1Z2 --fix

# List valid GST state codes
dart run bin/gst_invoice_checker.dart states
```

Exit codes: `0` clean · `1` findings with severity error · `2` bad input.

## The JSON shape

```json
{
  "supplierStateCode": 27,
  "financialYear": "2026-27",
  "invoices": [
    {
      "number": "1",
      "issueDate": "2026-04-10",
      "clientName": "Acme Consulting LLP",
      "clientGstin": "27AAACA1234A1ZK",
      "placeOfSupplyStateCode": 27,
      "lines": [
        {"description": "Flutter app development", "hsnSac": "998314",
         "taxableValue": 45000, "ratePercent": 18}
      ],
      "totalTaxable": 45000, "cgst": 4050, "sgst": 4050, "igst": 0,
      "grandTotal": 53100
    }
  ]
}
```

Amounts as plain numbers. Omit `clientGstin` for unregistered buyers.

## Examples in this repo

- `example/good_invoices.json` — two clean invoices (intra- and inter-state),
  passes with zero findings.
- `example/bad_invoices.json` — the same three mistakes freelancers make every
  month: a GSTIN typo, IGST on an intra-state bill, a duplicate document
  number, a sequence gap after a cancelled invoice, and a ₹1 rounding slip.
  The checker reports all of them.

## Tests

```bash
dart test        # 24 tests: checksum math, tax rules, engine, JSON decode
```
