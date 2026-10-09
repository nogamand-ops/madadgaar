# Madadgaar — "Help, when you need it."

Pakistan's on-demand roadside assistance platform. Fuel delivery, battery jump-start, flat tire, minor mechanical help and towing — starting in Islamabad + Rawalpindi.

This is a hackathon MVP running in **Demo Mode**: a real local backend with real business logic (pricing engine, matching engine, live WebSocket state), but no external accounts/API keys — nothing here requires Firebase/Supabase/Google Maps/Easypaisa credentials to run.

## Apps

Three separate apps, one shared backend:

- **`apps/customer_app`** — the "I need help" side: request assistance, track the match live on the map, chat, pay, rate.
- **`apps/helper_app`** — the "I want to help & earn" side: register as a Madadgaar, go online, accept/decline nearby jobs, run the job, earnings.
- **`apps/admin_dashboard`** — a separate web dashboard for the business side (live requests, revenue, commission, unit economics, service configuration).

They're kept as three distinct apps rather than one app with a role picker: a customer stranded on the roadside and someone driving around looking for paid jobs are different audiences, different home screens, different everyday use — bundling them behind a mode switch made the home screen (and the first-run decision) confusing rather than simpler. The three apps talk to the same `backend/local-server`, so a request made in `customer_app` is live-visible and actionable in `helper_app` and `admin_dashboard` with no manual refresh anywhere.

## Status

| Piece | State |
|---|---|
| `backend/local-server` | **Done.** Full REST + WebSocket API, seeded Islamabad/Rawalpindi demo data, pricing engine, matching/dispatch engine, admin analytics. Verified end-to-end via automated tests and manual walkthrough. |
| `packages/core` | **Done.** Shared design system, domain models, API/realtime client, live-request state, reusable widgets. `flutter analyze`: 0 issues. |
| `apps/customer_app` | **Done — verified live in Chrome.** Login/OTP → home, emergency request flow (service → "what's wrong?" → location → price → live match/tracking), chat, payment, rating, cancellation, SOS, vehicles, history, profile. `flutter analyze`: 0 issues. |
| `apps/helper_app` | **Done — verified live in Chrome.** Login/OTP → registration (first time) → online/offline, live incoming-job offers with countdown, active-job flow (arrived → start → complete), earnings + simulated withdraw, jobs history, profile. `flutter analyze`: 0 issues. |
| `apps/admin_dashboard` | **Scoped-down but real and working.** Dashboard (demo admin login) showing live cards (active requests, online helpers, today's orders/revenue/commission, completed jobs, cancellation rate), a business-metrics/unit-economics section (GMV, Madadgaar revenue, helper payouts, AOV, response time, completion/cancellation/take rate — labeled DEMO DATA), a live active-requests list, a helpers table, and a Services tab to edit each service's quick-pick problem options live. The live map, pricing-editing panel, city management and disputes tables from the original plan were cut for time. `flutter analyze`: 0 issues. |
| `backend/supabase` | **Not built.** The production-target Postgres schema/RLS described in the plan was not written in the time available. |

Verified live, in the same running backend: a request created in `customer_app` is offered to, and acceptable from, `helper_app` running as a separate app/window, and shows up live on `admin_dashboard` in a third — no manual refresh needed anywhere.

## Running it

Requires Node.js and the bundled Flutter SDK under `tools/flutter` (extracted from `flutter_sdk.zip` — not committed; see below if you need to re-extract it).

```bash
# 1. Backend (from repo root)
cd backend/local-server
npm install
npm start          # http://localhost:4000, ws://localhost:4000/ws
npm test           # pricing + matching engine unit tests

# 2. Customer app (separate terminal)
cd apps/customer_app
flutter pub get
flutter run -d chrome

# 3. Helper app (separate terminal)
cd apps/helper_app
flutter pub get
flutter run -d chrome

# 4. Admin dashboard (separate terminal)
cd apps/admin_dashboard
flutter pub get
flutter run -d chrome
```

All three apps point at `http://localhost:4000` by default (override with `--dart-define=API_BASE_URL=...`). To demo a job end-to-end, run `customer_app` and `helper_app` side by side.

**Demo login:** any Pakistani-format number (`+923XXXXXXXXX`); OTP is always `1234` and is also returned directly in the UI (no real SMS is sent — see the "DEMO MODE" banner). To use the pre-seeded, pre-verified demo persona, log in as:
- Customer **Ali Raza** — `+923001234567`
- Helper **Ahmed Hussain** (verified, online, positioned ~1.8km from Ali) — `+923331234567`
- Admin — just tap "Continue as Admin (Demo)", no phone number needed

## Architecture notes

- **Three independent Flutter apps sharing `packages/core`.** `customer_app` and `helper_app` each have their own login/OTP flow, router, and shell (`app/app_shell.dart`), but both import the same models, theme, API client and widgets from `packages/core` so they stay visually and behaviorally consistent without being the same app.
- **Why a local Node server instead of pure in-memory per-app state:** the customer and helper apps and the separate admin dashboard all need to see the *same* live state — a request created on one side has to be visible and actionable on the other, live. `backend/local-server` is the single source of truth — REST for actions, a WebSocket broadcast for live updates — so it's also what "SupabaseRepository" would eventually replace, not the state model.
- **Pricing** (`backend/local-server/src/pricing.js`) and **matching** (`src/matching.js`) are pure, unit-tested, and fully admin-configurable (`PATCH /api/pricing/:cityId/:serviceKey`, `PATCH /api/pricing/matching-config`) — nothing is hardcoded in the Flutter apps.
- **Maps** use `flutter_map` + OpenStreetMap tiles and OSM Nominatim for search/reverse-geocoding — free and keyless, so the demo doesn't depend on a Google Maps API key. Swappable behind the same widgets later.
- **Auth** is phone + a fixed demo OTP behind the same `verify-otp` endpoint a real Firebase/Supabase phone-auth provider would sit behind.
- **Payments** (COD/Easypaisa/JazzCash) are explicitly simulated and labelled as such — no real payment gateway is connected, and the UI never claims otherwise.

## What "go live" would still require

Real Supabase/Firebase project + credentials; a real SMS/OTP provider; a Google Maps or Mapbox API key (or continued use of OSM at higher volume, which needs a paid/self-hosted tile provider past hobby usage); real Easypaisa/JazzCash merchant integration; a licensed fuel-fulfillment partner per Madadgaar's fuel policy; and a legal/compliance review (Terms, Privacy, cancellation and fuel-transport rules, tax) — none of which is claimed to exist in this demo.
