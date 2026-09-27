# gst-invoicing-demo

A live, no-UI demo driver for the [Vasooli](../vasooli) GST invoicing server:
it runs the hackathon demo story as real typed HTTP calls against the running
Serverpod 4 API and prints the whole thing as a narrative transcript
(`demo_transcript.md`).

Useful for: the demo video's script beats (every number on screen is provably
live), smoke-testing a fresh deploy, and showing the rubric exactly where each
Serverpod feature earns its place.

## What it runs

1. **Intra-state invoice** (Maharashtra → Maharashtra) — server computes
   CGST + SGST halves; no IGST. Two lines, ₹50,000 @ 18 %.
2. **Inter-state invoice** (Maharashtra → Karnataka) — same money moves to a
   single IGST line at the full rate. Invoice numbers are sequential per
   financial year and assigned only by the server.
3. **The GSTIN typo** — `27AAACA1234A1ZK` with the last char mistyped to `2`.
   Format-checkers accept it; the server's mod-36 check-digit validation
   refuses with a typed `InvalidGstinException` carrying an exact message.
4. **The ledger** — `listInvoices` straight from Postgres, with an
   outstanding / received rollup.
5. **Client pays by UPI** — `markPaid`, and the outstanding total drops by
   exactly that invoice's value.

## Run it

Prereq: the Vasooli server on `http://localhost:8080` (see
[runbook](#server-runbook-including-the-embedded-postgres-gotcha) below).

```bash
dart pub get
dart run bin/demo.dart                        # print the story
dart run bin/demo.dart --out demo_transcript.md
dart run bin/demo.dart --fy 2027-28 --url http://localhost:8080/
```

Latest captured output is in [`demo_transcript.md`](demo_transcript.md).
Invoice numbers in the transcript continue from the FY's series on the
running database — which is the point: the series is server-enforced and
the numbers are live, never mocked.

## Server runbook (including the embedded-Postgres gotcha)

Serverpod 4's embedded Postgres means **no Docker needed** — but in a
scratch sandbox there is one rough edge to know about (also logged in
`../serverpod-hackathon/feedback.md` for the MVF prize):

1. Make sure no stray postmasters are running: `pgrep -f pg-binaries`.
2. Delete the shared attach bookkeeping file if it exists:
   `rm -f /var/tmp/embedded_postgres_state.json`.
   (The state file points at the *last-started* embedded postmaster — usually
   the test harness's — and the dev server will otherwise attach to the wrong
   cluster and retry `3D000 database does not exist` forever.)
3. Start the server with migrations:

   ```bash
   cd ../vasooli/vasooli_server
   dart bin/main.dart --apply-migrations
   ```

   Expected log: `Applied database migration:` (first run) or
   `Latest database migration already applied`, then
   `WebServer: Webserver listening on http://localhost:8082`.
4. Sanity: `curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080/`
   → `200`.

Memory note for small sandboxes: `serverpod generate` plus a running server
plus the embedded Postgres exceeds ~2 GB RAM and gets OOM-killed — stop the
server before regenerating code, restart it after.

## Rubric mapping (why this story, not another CRUD)

| Judging criterion | What the demo shows |
|---|---|
| Does it work (30 %) | Every call is a logged HTTP request against Postgres; API root returns 200; transcript is reproducible. |
| Serverpod stack (25 %) | Models + migrations, typed endpoints, serializable exceptions; streams / future calls / auth land in later milestones per `../serverpod-hackathon/build-plan.md`. |
| Craft (25 %) | Server-side invariants: per-FY sequential numbers, place-of-supply tax split, rounding on the taxable total, GSTIN check digit. |
| Usefulness (20 %) | The three failure modes it prevents are the ones freelancers meet monthly; an error message names exactly which character is wrong. |
