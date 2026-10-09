# Madadgaar — "Help, when you need it."

Pakistan's on-demand roadside assistance platform. Fuel delivery, battery jump-start, flat tire, minor mechanical help and towing — starting in Islamabad + Rawalpindi.

This is a hackathon MVP running in **Demo Mode**: a real local backend with real business logic (pricing engine, matching engine, live WebSocket state), but no external accounts/API keys — nothing here requires Firebase/Supabase/Google Maps/Easypaisa credentials to run.

## Apps

- **`apps/customer_app`** — one app, two modes. It opens on a mode picker ("I need help" / "I want to help & earn") and routes into either the customer experience or the helper experience based on who's actually logged in (a phone number's role is set once, server-side, at first sign-up — the picker just chooses which one a *new* number becomes). Two people can run the same URL in two browser windows to demo both sides at once.
- **`apps/admin_dashboard`** — a separate web dashboard for the business side (live requests, revenue, commission, unit economics). This one stays a distinct app deliberately: it's for Madadgaar's own team, not something an end user ever picks between.

## Status

| Piece | State |
|---|---|
| `backend/local-server` | **Done.** Full REST + WebSocket API, seeded Islamabad/Rawalpindi demo data, pricing engine, matching/dispatch engine, admin analytics. Verified end-to-end via automated tests and manual walkthrough. |
| `packages/core` | **Done.** Shared design system, domain models, API/realtime client, live-request state, reusable widgets. `flutter analyze`: 0 issues. |
| `apps/customer_app` | **Done — verified live in Chrome, both modes.** Mode picker → role-aware login/OTP → Customer: home, emergency request flow, live map matching/tracking, chat, payment, rating, cancellation, SOS, vehicles, history, profile. Helper: registration, online/offline, live incoming-job offers with countdown, active-job flow (arrived → start → complete), earnings + simulated withdraw, jobs history, profile. `flutter analyze`: 0 issues. |
| `apps/admin_dashboard` | **Scoped-down but real and working.** One dashboard screen (demo admin login) showing live cards (active requests, online helpers, today's orders/revenue/commission, completed jobs, cancellation rate), a business-metrics/unit-economics section (GMV, Madadgaar revenue, helper payouts, AOV, response time, completion/cancellation/take rate — labeled DEMO DATA), a live active-requests list and a helpers table. The live map, pricing-editing panel, city/service management and disputes tables from the original plan were cut for time. `flutter analyze`: 0 issues. |
| `backend/supabase` | **Not built.** The production-target Postgres schema/RLS described in the plan was not written in the time available. |

Verified live, in the same running backend: a request created in Customer mode is offered to, and acceptable from, Helper mode in a second browser window, and shows up live on the Admin dashboard in a third — no manual refresh needed anywhere.

## Running it

Requires Node.js and the bundled Flutter SDK under `tools/flutter` (extracted from `flutter_sdk.zip` — not committed; see below if you need to re-extract it).

```bash
# 1. Backend (from repo root)
cd backend/local-server
npm install
npm start          # http://localhost:4000, ws://localhost:4000/ws
npm test           # pricing + matching engine unit tests

# 2. The app (customer + helper modes)
cd apps/customer_app
flutter pub get
flutter run -d chrome

# 3. Admin dashboard (separate terminal)
cd apps/admin_dashboard
flutter pub get
flutter run -d chrome
```

Both apps point at `http://localhost:4000` by default (override with `--dart-define=API_BASE_URL=...`). To demo both sides of a job at once, open `apps/customer_app`'s URL in two browser windows — pick "I need help" in one, "I want to help & earn" in the other.

**Demo login:** any Pakistani-format number (`+923XXXXXXXXX`); OTP is always `1234` and is also returned directly in the UI (no real SMS is sent — see the "DEMO MODE" banner). To use the pre-seeded, pre-verified demo persona, log in as:
- Customer **Ali Raza** — `+923001234567`
- Helper **Ahmed Hussain** (verified, online, positioned ~1.8km from Ali) — `+923331234567`
- Admin — just tap "Continue as Admin (Demo)", no phone number needed

## Architecture notes

- **One app, two modes, one shared login/OTP flow.** `features/mode/mode_picker_screen.dart` is the front door; `features/auth/login_screen.dart` and `otp_screen.dart` take a `role` and route to the right shell (`app/app_shell.dart` for customers, `app/helper_app_shell.dart` for helpers) based on the *actual* role the server returns — not just whichever card was tapped, so an existing account always lands in the right place.
- **Why a local Node server instead of pure in-memory per-app state:** the customer and helper experiences (two browser windows of the same app) and the separate admin dashboard all need to see the *same* live state — a request created on one side has to be visible and actionable on the other, live. `backend/local-server` is the single source of truth — REST for actions, a WebSocket broadcast for live updates — so it's also what "SupabaseRepository" would eventually replace, not the state model.
- **Pricing** (`backend/local-server/src/pricing.js`) and **matching** (`src/matching.js`) are pure, unit-tested, and fully admin-configurable (`PATCH /api/pricing/:cityId/:serviceKey`, `PATCH /api/pricing/matching-config`) — nothing is hardcoded in the Flutter apps.
- **Maps** use `flutter_map` + OpenStreetMap tiles and OSM Nominatim for search/reverse-geocoding — free and keyless, so the demo doesn't depend on a Google Maps API key. Swappable behind the same widgets later.
- **Auth** is phone + a fixed demo OTP behind the same `verify-otp` endpoint a real Firebase/Supabase phone-auth provider would sit behind.
- **Payments** (COD/Easypaisa/JazzCash) are explicitly simulated and labelled as such — no real payment gateway is connected, and the UI never claims otherwise.

## What "go live" would still require

Real Supabase/Firebase project + credentials; a real SMS/OTP provider; a Google Maps or Mapbox API key (or continued use of OSM at higher volume, which needs a paid/self-hosted tile provider past hobby usage); real Easypaisa/JazzCash merchant integration; a licensed fuel-fulfillment partner per Madadgaar's fuel policy; and a legal/compliance review (Terms, Privacy, cancellation and fuel-transport rules, tax) — none of which is claimed to exist in this demo.
