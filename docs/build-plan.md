# Build Plan + Serverpod 4 Feature Map

**Today 2026-09-25 → deadline 2026-10-14, 23:59 CEST = 03:29 IST on 15 October. That is 19 days at 10–20 hrs/week ≈ 30–55 hours.**
Budget it as **40 hours of building, and reserve the last 3 days for video, README, and deployment.** Everything below assumes solo.

Serverpod 4 ("Jetstream", released 2026-09-14) is the version to target. It needs **Flutter 3.44.4+ / Dart 3.12.2**, and it ships an **embedded Postgres**, so Docker is no longer required for local dev.

**Two rules that shape the plan:**
- **New projects only.** The project must be newly created during the submission period — no existing startup code, no fork of it. Start a fresh repo on day one, even if the idea came from your own business.
- **Disclose AI tooling** in the text description. It's permitted and encouraged, but disclosure is required. Put the sentence in your README on day one so it isn't a deadline-night scramble.

**Start a `feedback.md` today.** The Most Valuable Feedback prize is $500 cash + $500 credits, awarded to individuals, and it just needs actionable notes (bugs, UI issues, integration ideas) filed on the feedback form. You're building on a framework that shipped 11 days ago — you will find things. Writing them down as you go costs nothing.

---

## The Serverpod 4 features that actually earn rubric points

Score for "Use of the Serverpod stack" (25%) comes from features that would be *wrong* to hand-roll — not from using many of them.

| Feature | Where it goes in this app | Why it beats hand-rolling |
|---|---|---|
| **Models + migrations** | `Account`, `Invoice`, `InvoiceLine`, `Payment`, `Client`, `Reminder` | Typed end-to-end, Postgres schema generated, no SQL. This is the spine of the app. |
| **Endpoints (typed methods)** | `createInvoice`, `recordPayment`, `importUpiStatement`, `monthlySummary` | Client and server share types; a bad call is a compile error, not a runtime 400. |
| **Server-side invariants** | Sequential invoice number per FY (max 16 chars), place of supply → CGST+SGST vs IGST, rounding on the taxable total not per line | This is the "craft" score. Correctness that cannot be bypassed by the client. |
| **Streams** | Receivable total, invoice status flips, "client just paid" on every open device | The live demo moment. Also the thing judges see that Firebase-style apps fake with polling. |
| **Recurring future calls** | Daily overdue scan → escalating reminders; month-end GST summary | Serverpod 4 declares these as normal Dart methods with generated scheduling, including recurring ones. |
| **Storage** | Generated invoice PDFs, imported UPI statement files | Expanded storage APIs in 4.0; keeps the DB lean. |
| **Auth** | Email + Google sign-in, then row-level scoping so a user only ever reads their own ledger | Serverpod 4 supports email, Google, Apple, Facebook, GitHub, Microsoft, Firebase, and anonymous. Do not build your own. |
| **Client-side DB + offline sync (experimental in 4.0)** | Flutter app keeps a local SQLite copy; invoice created offline syncs on reconnect | The genuinely impressive Serverpod-4-only feature. Mark it `database: sync` on the model. **It's experimental — build the app so it still works if sync misbehaves.** |
| **`serverpod start` + full-stack hot reload** | Your whole dev loop | One command runs server + DB + Flutter app with sub-second hot reload. Change a model, the DB migrates. This is what makes a 40-hour build feasible. |
| **Health endpoints + Serverpod Cloud** | `/health` returning the deployed version; public URL for judges | "Does it work" is 30%. A URL that opens beats a video that plays. Cloud starts around $5/mo and the hackathon hands out cloud credits. |

---

## 19-day plan

### Days 1–2 (Sept 25–26) — Skeleton that runs end to end
- `serverpod create` with your IDE + agent selected. Get `serverpod start` running server + DB + Flutter app together.
- One model (`Invoice`), one endpoint (`createInvoice`), one screen with a button. No styling.
- **Exit test: tap a button in Flutter → row appears in Postgres.** Nothing else matters until this works.

### Days 3–6 (Sept 27–30) — The invoice core (highest craft score)
- Models: `Account`, `Client`, `Invoice`, `InvoiceLine`, `Payment`.
- Server-side: sequential invoice number per financial year, 16-char cap; place of supply → CGST+SGST vs IGST split; round on the taxable total.
- Tests for the tax math. **Write these before the UI** — this is the part you'll be asked about.
- Invoice detail screen + PDF generation → storage.

### Days 7–9 (Oct 1–3) — Payments and the live moment
- `recordPayment` (manual UPI entry) → invoice flips to paid.
- Stream the invoice status + receivable total. Second device open on the same account updates instantly.
- **Exit test: two windows open, mark paid in one, watch the other flip.** That's your demo.

### Days 10–12 (Oct 4–6) — Import + reminders
- UPI statement import (CSV export from GPay/PhonePe) → parse, match to invoices, show unmatched.
- Recurring future call: daily overdue scan, escalating reminder copy.

### Days 13–15 (Oct 7–9) — Offline sync + month-end
- `database: sync` on `Invoice`/`Payment`; verify create-offline → sync-on-reconnect.
- Monthly GST summary screen (CGST/SGST/IGST totals, receivables) + shareable PDF.

### Days 16–17 (Oct 10–11) — Deploy
- Serverpod Cloud deploy, migrations applied, secrets in platform secret management (**nothing hard-coded in the repo**).
- Verify `/health` on the public URL. Confirm the full flow works from a clean machine, not just yours.

### Days 18–19 (Oct 12–13) — Submission package, with buffer
- README a stranger can follow to run it. Text description. Video recorded and uploaded (public, under 2:00).
- Submit on **Oct 13**. Do not submit on Oct 14 — there are no extensions.

### Cut list (if you run out of time — cut in this order)
1. Offline sync (experimental; nice but not required)
2. UPI statement auto-matching → fall back to manual payment entry
3. PDF polish and templates
4. Multi-user/roles beyond basic scoping

---

## Demo video script (under 2 minutes)

**What the rules actually say about the video** — this matters more than the script:

- Judges "**are not required to test the Project** and may judge on the basis of the text description, images and video alone." Design every shot so it lands on someone who never clicks your link.
- "**Presentation quality is not scored separately**... Entrants should spend their time on the Project rather than on video production." So: one take, no editing pass, no motion graphics, no intro animation. Content over craft.
- Under 2 minutes, and judges "**are not required to watch beyond two minutes**" — so put the strongest moment in the first 40 seconds, not the last.
- Must show the project **functioning on the device it was built for**. Must be **public on YouTube or Vimeo**. **No copyrighted music, no third-party trademarks.** All materials in English.
- The project "must function as depicted in the video" — so don't demo anything that isn't really wired up.

| # | Time | Shot |
|---|---|---|
| 1 | 0:00–0:12 | The problem in one sentence: the monthly UPI-to-invoice scramble. Straight in, no intro. |
| 2 | 0:12–0:35 | Create a real invoice. Show the GSTIN field rejecting a bad digit, and the CGST+SGST vs IGST split changing when you change place of supply. |
| 3 | 0:35–0:55 | Share it: PDF opens with the Rule 46 fields visible. |
| 4 | 0:55–1:20 | **The money shot:** two devices open. Record a UPI payment on one; the other flips to paid and the receivable total drops, live over a Serverpod stream. |
| 5 | 1:20–1:40 | Overdue reminder fires from the scheduled future call. Month-end GST summary appears. |
| 6 | 1:40–1:55 | Public URL opens in a browser. One line on the stack. End. |

"Use your own real data, not fake rows" is good practice for credibility, but note it's *my* recommendation, not a written rule — the written requirement is that the project functions as depicted.

---

## Submission checklist

- [ ] Project is newly created during the submission period (no pre-existing code)
- [ ] Functional full-stack app with Serverpod as the backend
- [ ] Repo URL containing all source, assets, and instructions. If private: shared with `viktor@serverpod.dev`, `alexander@serverpod.dev`, `isak@serverpod.dev`
- [ ] Text description covering features, functionality, and how it was built — **including disclosure of AI/agentic tools used**
- [ ] Build/run instructions, tested on a clean machine by someone who didn't write the code
- [ ] Demo video, public on YouTube or Vimeo, under 2:00, shows the target device, no copyrighted music or third-party marks
- [ ] Working testing access — website, demo, or test build — free and unrestricted until judging ends (20 Oct). Include credentials if private.
- [ ] `/health` endpoint returns the deployed version
- [ ] No secrets in the repo or in build output
- [ ] All materials in English
- [ ] `feedback.md` submitted on the feedback form → Most Valuable Feedback eligibility
- [ ] At least one public post during the event identifying the hackathon → Best Hackathon Post eligibility
- [ ] Submitted before 23:59 CEST on 2026-10-14 — **aim for 13 October**; there are no extensions

---

## Verified vs. still to check yourself

**Verified against the primary source this session:** the official rules text (12 pages, published at `https://tinyurl.com/SP-rules`), read via a verbatim greppable copy mirrored at [github.com/Daniel-Escamilla/Hackathon_Serverpod/blob/main/docs/hackathon-rules.md](https://github.com/Daniel-Escamilla/Hackathon_Serverpod/main/docs/hackathon-rules.md), copied into that repo 2026-09-16. Dates, judging weights, prize table, video requirements, and the new-projects-only rule all come from that text.

**Still check yourself:**
- **Re-download the rules before the deadline.** §11 of the rules allows amendments during the event, with the current version posted on the hackathon website. The mirror I read is a participant's copy, not Serverpod's page, and it is 9 days old.
- Serverpod 4 version specifics (offline sync being experimental, exact Flutter floor) — from the 2026-09-14 Serverpod 4 launch post and docs, not re-verified against your installed toolchain.
- Serverpod Cloud's current pricing and whether the hackathon's credits cover a deploy at your app size.
- The GST details in the pitch (Rule 46's 16 fields, 16-char sequential invoice number, ₹5 crore e-invoicing threshold from 1 Apr 2026) come from tax-practitioner blogs, not from the CGST Rules text itself. They're plausible and consistent across sources, but don't ship tax logic without checking the statute.
