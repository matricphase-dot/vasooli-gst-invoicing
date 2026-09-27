# Serverpod 4 feedback log → Most Valuable Feedback prize

**Why this file exists:** the Most Valuable Feedback prize is **$500 cash + $500 credits**, awarded for *actionable* feedback on the SDKs, App Studio, or docs (bug reports, UI improvements, suggested integrations). You need: a registered account ✅, an eligible submission, and the feedback form completed. You are building on a framework that shipped 2026-09-14 — log every rough edge the moment you hit it. Paste this file into the form at the end.

**What "actionable" means (from the rules):** a bug report with repro steps, a UI improvement with the screen named, an integration suggestion with the use case. "Offline sync is confusing" is not actionable. "Offline sync: creating two invoices with the same client while offline and syncing produced a FK error; repro below" is.

---

## Bugs

_Format: date · component · what happened · expected · repro steps · versions (Flutter / Serverpod CLI / OS)_

### 1. Dev server attaches to the test harness's embedded Postgres after `dart test`, then retries `3D000` forever

**Date:** 2026-09-27 · **Component:** embedded Postgres attach (`serverpod_database/embedded.dart` → `startOrAttachEmbeddedPostgres`) · **Versions:** Serverpod 4.0.3, Dart 3.13.4 stable, linux x64 (no Docker)

**What happened:** after running the integration test suite (`dart test` with
`database.dataPath` set in `config/test.yaml`), starting the dev server
(`dart bin/main.dart --apply-migrations`, dev `dataPath` also set) failed
with `database "vasooli" does not exist` (PG code 3D000), retrying every
10 s forever — although a manual connection proved the dev cluster, on the
dev `dataPath`, **did** contain the database.

**Expected:** the dev server's connectivity resolves to the postmaster
owning the **configured** `database.dataPath`.

**Actual:** connectivity resolves from the single shared bookkeeping file
`/var/tmp/embedded_postgres_state.json`, which records the **last-started**
embedded postmaster — the test harness's. After `dart test`, the state file
named `vasooli_test`, and the dev server was in fact connecting to the test
cluster: the server log shows
`SocketException … address = /var/tmp/run/.s.PGSQL.5432, port = 5432`
(the test postmaster's unix socket after I killed it), never the
dev-configured `localhost:8090`. Server config (`host/port/dataPath`) is
overshadowed by the state file despite logging it as the config in use.

**Repro:**
1. `serverpod create demo` style project; set `database.dataPath` in both
   `config/development.yaml` and `config/test.yaml`.
2. Run `dart test` (serverpod_test integration harness) — note it also
   **leaves its postmaster running detached** (bug 2 below), which is what
   makes the state file stay fresh.
3. Start the dev server in a shell: `dart bin/main.dart`. It attaches per
   the state file and retries 3D000 forever.

**Workaround (please confirm this is the supported recovery):** stop stray
postmasters (`pgrep -f pg-binaries`, kill), `rm /var/tmp/embedded_postgres_state.json`,
then start the dev server — it owns its postmaster, applies migrations, and
runs correctly.

**Why it matters beyond me:** any dev who runs the built-in test suite and
then starts their server hits this — i.e. roughly everyone on the new
Docker-less flow — and the log actively points at the wrong config
(`host: localhost, port: 8090` is printed while connecting elsewhere),
so it is very hard to diagnose.

### 2. Test harness leaves the embedded test postmaster running after `dart test` exits

**Date:** 2026-09-27 · **Component:** `serverpod_test` 4.0.3 integration harness

**What happened:** after `dart test` completed successfully, a
`pg-binaries/…/postgres -D <test dataPath>` process remained alive (observed
>10 minutes later, still holding its unix socket). Each test run spawns a new
one; they accumulate until killed by hand.

**Expected:** the test postmaster is reaped when the last test suite exits.

**Actual:** detached postmaster surviving the test process. Combined with
bug 1 above, the stale postmaster + stale state file poison the next dev
server start.

### 3. `serverpod generate` is OOM-killed on a 2 GB machine when the dev server is running

**Date:** 2026-09-27 · **Component:** `serverpod_cli` 4.0.3

**What happened:** `serverpod generate` (analyze + codegen) was SIGKILLed
during "Analyzing changes..." after ~5 minutes while the dev server
(+ embedded Postgres) was running on a machine with 2 GB total RAM
(~780 MB free). With the server stopped, the same command completes in ~2 s.

**Suggested:** document a memory floor, or stream the analysis; a friendlier
outcome than `Killed` would be a warning + incremental pass. Repro:
2 GB sandbox, dev server running, `serverpod generate`.

## UI / DX improvements

_Format: date · where (App Studio screen / CLI output / docs page) · what's confusing · suggested fix_

### 1. "Another process is using the local database" should name the holder

**Date:** 2026-09-27 · **Where:** server startup error output.

The message "Stop other Serverpod or database processes for this project,
then try again." gives no way to find the offender — it names neither the
PID, the data dir, nor the listening socket. On a machine where `dart test`
quietly left behind a second postmaster (bug 2), I had to `ps aux |
grep pg-binaries` to discover it. **Suggested fix:** print the
`postmaster.pid`'s PID, data directory and port — one line, e.g.
"dataDir X is locked by PID 4504 (listening on :8090)".

### 2. The 3D000 retry loop should exit with guidance instead of retrying forever

**Date:** 2026-09-27 · **Where:** server startup / retry log.

A missing-database condition is not transient; retrying every 10 s forever
while printing the (misleading) configured host/port turned a 2-minute fix
into an hour of archaeology. **Suggested fix:** after ~3 identical 3D000
failures, exit non-zero with: database name probed, the endpoint actually
connected to (from the embedded state file if resolved that way), and the
supported recovery (`serverpod` command or file to remove).

### 3. Optional/defaulted endpoint parameters become mandatory in generated clients

**Date:** 2026-09-27 · **Where:** `serverpod generate` output — Dart client + test-tool wrappers.

An endpoint declared with a defaulted parameter —

```dart
Future<Invoice> recordPayment(Session session, int invoiceId, int amountPaise,
    {PaymentMethod method = PaymentMethod.upi, String? reference})
```

— generates client and test-tool code where **`method` is required, default
gone**, while the server-side implementation keeps its default. The compiler
output is the only notice you get:

```
error • missing_required_argument • The named parameter 'method' is required
```

After regenerating, every previously-compiling caller breaks. **Suggested
fix:** carry declared defaults into the generated protocol stubs where the
target language allows (Dart does), or emit an explicit generate-time warning
("endpoint `invoices.recordPayment`: default of `method` will not be visible
to clients").

## Suggested integrations

_Format: date · what · why a Serverpod user needs it_

- [ ] TODO (nothing yet — the day-3 milestone is backend-only; integrations come with PDF storage and imports)

---

## Notes

- One Feedback Submission per entrant — so this file is the single source you submit once, at the end.
- Keep entries raw and dated while building; polish into the form on Oct 12–13.
- The rules say feedback prizes are awarded to individuals; the event website says "per team". Either way, filing it loses you nothing.
