# Vasooli — GST invoicing & UPI payment tracking for Indian freelancers

Built for **"Build Something Real: The Serverpod Hackathon"** (submission
window Sept 15 – Oct 14, 2026) on **Serverpod 4 ("Jetstream")** with Flutter.

> **AI-tooling disclosure (required by the hackathon rules):** this project
> was built with the assistance of an agentic coding assistant (Arena.ai
> Agent Mode) used for scaffolding, code generation, test authoring, and
> debugging. Design decisions, domain rules, and verification are the
> entrant's.

## Why this exists

Every month, an Indian freelancer does a small tax-compliance dance by hand:

- dig through UPI notifications to find *which client actually paid*,
- hand-build a **GST-compliant invoice** in a spreadsheet,
- remember who still needs chasing.

The common mistakes have real costs: a single wrong character in the client's
GSTIN means the client **cannot claim input tax credit**; IGST on an
intra-state bill (or CGST/SGST on an inter-state one) is a filing error;
tax rounded per line instead of on the invoice total drifts by rupees;
a duplicate invoice number breaks Rule 46's consecutive-series requirement.

Vasooli makes the wrong versions of those impossible **server-side** — the app
UI is just a window onto invariants that live behind typed endpoints.

## What's in this repo

| Directory | What |
|---|---|
| [`vasooli/`](vasooli/) | The Serverpod 4 project: `vasooli_server` (models, endpoints, migrations), `vasooli_client` (generated typed client), `vasooli_flutter` (the app — completed live ledger + PDF tier) |
| [`gst-invoice-checker/`](gst-invoice-checker/) | Standalone zero-dependency **CLI validator** for invoices: GSTIN check digit, Rule 46 numbers, tax recomputation. 24 tests. |
| [`gst-invoicing-demo/`](gst-invoicing-demo/) | No-UI **live demo driver** that runs the demo story against the running API as real HTTP calls and emits a transcript |
| [`docs/`](docs/) | Build plan + feature map, and the running Serverpod feedback log |

## Status (updates as the build progresses)

- ✅ **Flutter web app** (`vasooli/vasooli_flutter`): live ledger driven by
  the `watchInvoices` stream, GSTIN check-digit feedback as you type,
  new-invoice form with per-line GST%, record-payment dialog that refuses
  partials and double-pays, Rule-46 PDF sharing, month-end GSTR summary.
  Served by the server itself at `/` — `web/app` build output.
- ✅ Models: `Invoice`, `InvoiceLine`, `InvoiceStatus`, `Payment`,
  `PaymentMethod`, `ReminderScan`, `MonthlySummary` (+ 3 migrations)
- ✅ Server-side invariants: per-financial-year sequential invoice numbers,
  place-of-supply → CGST+SGST vs IGST split, rounding on the taxable total,
  GSTIN format **and mod-36 check digit**
- ✅ Serializable `InvalidGstinException` — the app shows the precise message
- ✅ Endpoints: `createInvoice` (with `dueDate`), `listInvoices`,
  `recordPayment` (UPI ref, exact-amount match, refuses double-pay and
  partials), `markPaid`, `scanOverdue`, `monthlySummary`, and streamed
  `watchInvoices`
- ✅ **Streams:** every mutation posts to `invoices/updates`; the app and the
  demo both consume the same event source — two devices stay in sync
- ✅ **Future calls:** `daily-overdue-scan` registered at boot
  (`callRecurring(...).every(24h)`)
- ✅ `/health` route (JSON: status, version, runMode) on the web server
- ✅ Tests: server 26 (13 unit + 13 integration), GSTIN checker CLI 24,
  app 8 — all green
- ✅ Demo: 8-beat narrative with real transcript
  ([`gst-invoicing-demo/demo_transcript.md`](gst-invoicing-demo/demo_transcript.md))
- ⏳ UPI statement import, auth UI wiring (server-side email/JWT auth is
  scaffolded), offline sync — stretch goals per
  [`docs/build-plan.md`](docs/build-plan.md)
- ⏳ Deployment to Serverpod Cloud — runbook in [`docs/DEPLOY.md`](docs/DEPLOY.md)

## Run it locally (no Docker needed — Serverpod 4 embeds Postgres)

Prereqs: Flutter 3.44.4+ / Dart 3.12.2+, Serverpod CLI 4.0.x
(`dart pub global activate serverpod_cli`).

```bash
# 1. deps + codegen
cd vasooli && flutter pub get && serverpod generate

# 2. backend (starts embedded Postgres, applies migrations, serves :8080)
cd vasooli_server && dart bin/main.dart --apply-migrations

# 3. tests (spin their own embedded test Postgres; stop the dev server first
#    on machines with ~2GB RAM — see docs/feedback.md bug #1 for a 4.0.3
#    embedded-Postgres quirk you may meet)
dart test

# 4. the demo story against the running server
cd ../../gst-invoicing-demo && dart pub get && dart run bin/demo.dart --out demo_transcript.md

# 5. the standalone validator
cd ../gst-invoice-checker && dart pub get
dart run bin/gst_invoice_checker.dart check example/bad_invoices.json
```

Secrets: dev credentials live in `vasooli/vasooli_server/config/passwords.yaml`
(gitignored template pattern); nothing secret is committed. Production
secrets will live in the deployment platform's secret store.

## The GST details, honestly

Rule 46 document-number shape, place-of-supply tax split, rounding, and the
GSTIN layout/checksum encode the publicly documented structure plus the
published GSTN check-digit algorithm. Verify against the CGST Rules before
relying on them for real filings — this is a build-one-project hackathon
entry, not tax advice.
