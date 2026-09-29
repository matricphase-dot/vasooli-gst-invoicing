# vasooli_flutter — the app tier

Flutter (Material 3) client for Vasooli. It talks **only** through the
generated typed client (`package:vasooli_client`) — every GST rule, every
paisa of tax math, and the invoice-number sequencing happen on the server.

## What you see

- **Live ledger** — invoice list driven by `watchInvoices`, the Serverpod
  stream endpoint. Open it on two devices, record a payment on one, watch
  the other flip to `paid` with a snackbar. No polling.
- **New invoice** — client name, GSTIN with *live* mod-36 check-digit
  feedback (the same algorithm the GST portal and the server use), place of
  supply derived from the GSTIN's first two digits, CGST+SGST vs IGST shown
  as you type, due date, multiple line items with HSN/SAC and per-line GST%.
  The server assigns the per-FY number and computes the official split.
- **Invoice detail** — full Rule-46 read-out, **Record payment**
  (exact-amount; refuses partials and double-pays with the server's words),
  **Share PDF** (client-side PDF that renders exactly the server's numbers).
- **Month-end** — per-month GSTR story: invoices by status, taxable
  turnover, output tax split, collected vs outstanding.

## Run it yourself

```console
$ flutter pub get
$ flutter run -d chrome        # API at http://localhost:8080 (dev server)
```

The API URL resolution order is: `--dart-define=SERVER_URL=...`, then the
bundled `assets/config.json`, then `http://localhost:8080/` — when the build
is served by `vasooli_server`'s web server, that same path returns the
server's real public URL instead (see `server.dart: AppConfigRoute`), so the
same build works locally, in the e2b preview proxy, and on Serverpod Cloud.

Build and hand to the server (it serves `web/app` at `/`):

```console
$ flutter build web --release -O1 --no-wasm-dry-run
$ rm -rf ../vasooli_server/web/app && cp -r build/web ../vasooli_server/web/app
```

(`-O1` compiles a 25-minute job into ~45 s on small CI boxes.)

## Tests

`flutter test` — FY boundary logic, Indian money formatting, and the
client-side GSTIN check-digit pre-check against all the known-good/known-bad
sample GSTINs used by the server test suite.
