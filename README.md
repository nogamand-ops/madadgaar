# Madadgaar — "Help, when you need it."

Pakistan's on-demand roadside assistance platform. Fuel delivery, battery jump-start, flat tire, minor mechanical help and towing — starting in Islamabad + Rawalpindi.

This is a hackathon MVP running in **Demo Mode**: a real local backend with real business logic (pricing engine, matching engine, live WebSocket state), but no external accounts/API keys — nothing here requires Firebase/Supabase/Google Maps/Easypaisa credentials to run.

## Status

| Piece | State |
|---|---|
| `backend/local-server` | **Done.** Full REST + WebSocket API, seeded Islamabad/Rawalpindi demo data, pricing engine, matching/dispatch engine, admin analytics. Verified end-to-end via automated tests and manual curl walkthrough. |
| `packages/core` | **Done.** Shared design system, domain models, API/realtime client, live-request state, reusable widgets. `flutter analyze`: 0 issues. |
| `apps/customer_app` | **Done — golden path verified in Chrome.** Auth, home, emergency request flow (fuel + generic services), live map matching/tracking, chat, payment, rating, cancellation, SOS, vehicles, history, profile, legal placeholders. `flutter analyze`: 0 issues. |
| `apps/helper_app` | **Done, not yet UI-tested.** "Become a Madadgaar" registration, online/offline, live incoming-job offers with countdown, active-job flow (arrived → start → complete), earnings + simulated withdraw, jobs history, profile. `flutter analyze`: 0 issues. |
| `apps/admin_dashboard` | **Scoped-down but real and working.** One dashboard screen (demo admin login, no typing needed) showing live cards (active requests, online helpers, today's orders/revenue/commission, completed jobs, cancellation rate), a business-metrics/unit-economics section (GMV, Madadgaar revenue, helper payouts, AOV, response time, completion/cancellation/take rate — labeled DEMO DATA), a live active-requests list and a helpers table. The originally-planned live map, pricing-editing panel, city/service management and disputes tables were cut for time. `flutter analyze`: 0 issues. |
| `backend/supabase` | **Not built.** The production-target Postgres schema/RLS described in the plan was not written before the deadline. |

The customer ↔ helper flow (a request created in `customer_app` being offered to, and actionable by, `helper_app`) is architecturally wired (same backend, same WebSocket broadcasts) but was not cross-verified with both apps open simultaneously before the deadline — only each app independently against the backend.

## Running it

Requires Node.js and the bundled Flutter SDK under `tools/flutter` (extracted from `flutter_sdk.zip` — not committed; see below if you need to re-extract it).

```bash
# 1. Backend (from repo root)
cd backend/local-server
npm install
npm start          # http://localhost:4000, ws://localhost:4000/ws
npm test           # pricing + matching engine unit tests

# 2. Each app (in separate terminals), e.g. customer_app:
cd apps/customer_app
flutter pub get
flutter run -d chrome
```

Repeat for `apps/helper_app`. All apps point at `http://localhost:4000` by default (override with `--dart-define=API_BASE_URL=...`).

**Demo login:** any Pakistani-format number (`+923XXXXXXXXX`); OTP is always `1234` and is also returned directly in the UI (no real SMS is sent — see the "DEMO MODE" banner). To use the pre-seeded, pre-verified demo persona, log in as:
- Customer **Ali Raza** — `+923001234567`
- Helper **Ahmed Hussain** (verified, online, positioned ~1.8km from Ali) — `+923331234567`

## Architecture notes

- **Why a local Node server instead of pure in-memory per-app state:** three separately-running Flutter apps each need to see the *same* live state (a request created in the customer app has to be visible and actionable in the helper app, and reflected in the admin view). `backend/local-server` is the single source of truth — REST for actions, a WebSocket broadcast for live updates — so it's also what "SupabaseRepository" would eventually replace, not the state model.
- **Pricing** (`backend/local-server/src/pricing.js`) and **matching** (`src/matching.js`) are pure, unit-tested, and fully admin-configurable (`PATCH /api/pricing/:cityId/:serviceKey`, `PATCH /api/pricing/matching-config`) — nothing is hardcoded in the Flutter apps.
- **Maps** use `flutter_map` + OpenStreetMap tiles and OSM Nominatim for search/reverse-geocoding — free and keyless, so the demo doesn't depend on a Google Maps API key. Swappable behind the same widgets later.
- **Auth** is phone + a fixed demo OTP behind the same `verify-otp` endpoint a real Firebase/Supabase phone-auth provider would sit behind.
- **Payments** (COD/Easypaisa/JazzCash) are explicitly simulated and labelled as such — no real payment gateway is connected, and the UI never claims otherwise.

## What "go live" would still require

Real Supabase/Firebase project + credentials; a real SMS/OTP provider; a Google Maps or Mapbox API key (or continued use of OSM at higher volume, which needs a paid/self-hosted tile provider past hobby usage); real Easypaisa/JazzCash merchant integration; a licensed fuel-fulfillment partner per Madadgaar's fuel policy; and a legal/compliance review (Terms, Privacy, cancellation and fuel-transport rules, tax) — none of which is claimed to exist in this demo.
