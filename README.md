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

## Start here: the super simple guide

Madadgaar has **4 pieces**:

| Piece | What it is | Where it runs |
|---|---|---|
| **Backend** | The "brain". It remembers every request and connects customers to helpers. | The laptop |
| **Customer app** | The app for someone whose car broke down | Phone 1 |
| **Helper app** | The app for the mechanic who comes to help | Phone 2 |
| **Admin dashboard** | A control panel for the company | The laptop (optional) |

The phones need to **talk to the laptop**, so **the laptop and both phones must be on the same WiFi**. The easiest way is to turn on a **hotspot on one phone** and connect the laptop and the other phone to it. It works even with no internet.

### Part 1: Set up the laptop (do this once)

1. **Install Node.js.** Go to **https://nodejs.org**, click the big **LTS** button, open the downloaded file, and click **Next** until it finishes.
2. **Install Git.** Go to **https://git-scm.com/downloads**, download it for Windows, open it, and click **Next** until it finishes.
3. **Open Command Prompt.** Press the **Windows key**, type `cmd`, and press **Enter**. A black window opens. You type all the commands below into this window and press **Enter** after each one.
4. **Download the project:**
   ```
   git clone https://github.com/nogamand-ops/madadgaar.git
   ```
   (If it asks you to log in, use the GitHub account that has access to the project.)
5. **Go into the backend folder:**
   ```
   cd madadgaar\backend\local-server
   ```
6. **Install the backend's parts** (first time only, takes about a minute):
   ```
   npm install
   ```

### Part 2: Start the backend (every time you demo)

1. Open Command Prompt and go to the backend folder:
   ```
   cd madadgaar\backend\local-server
   ```
2. Start it:
   ```
   npm start
   ```
3. You should see: `Madadgaar local demo server listening on http://localhost:4000`
4. **Leave this window open.** If you close it, the apps stop working.
5. If Windows shows a **firewall popup**, tick **both boxes** and click **Allow access**. If you click Cancel by mistake, the phones won't be able to connect.

Every time the backend restarts, the demo data resets to a fresh start. That's normal.

### Part 3: Find the laptop's address

The phones need to know where the laptop is, like a house address.

1. Connect the laptop to the **same WiFi or hotspot** the phones will use.
2. Open a **second** Command Prompt window (keep the backend one running) and type:
   ```
   ipconfig
   ```
3. Look for the section for your WiFi (**Wireless LAN adapter Wi-Fi**) and find the line **IPv4 Address**. It looks like `192.168.43.25`.
4. Your laptop's full address is that number plus `:4000`, for example:
   ```
   http://192.168.43.25:4000
   ```
5. **Check it:** on a phone connected to the same WiFi, open Chrome and go to `http://192.168.43.25:4000/api/health` (using your own number). If you see `{"ok":true,...}`, the phone can reach the laptop. 🎉

**Important:** the address can change if you join a **different** WiFi. Use the **same hotspot** tonight and at the event so it stays the same.

### Part 4: Make the phone apps (APKs)

Nobody needs Android Studio. GitHub builds the apps for you in the cloud.

1. Go to **https://github.com/nogamand-ops/madadgaar** and click the **Actions** tab at the top.
2. On the left, click **Build Madadgaar APKs**.
3. On the right, click **Run workflow**.
4. In the box, **paste the laptop's address** from Part 3 (for example `http://192.168.43.25:4000`), then click the green **Run workflow** button.
5. Wait about **5–10 minutes** until the run shows a ✅ green tick.
6. Click on the finished run. At the bottom under **Artifacts**, download:
   - **customer_app-apk**: for Phone 1
   - **helper_app-apk**: for Phone 2
7. Each download is a `.zip`. Unzip it to get `app-release.apk`.

If the laptop's address changes, run this again with the new address and reinstall the apps.

### Part 5: Install the apps on the phones

1. Send each APK to its phone (USB cable, Google Drive, or WhatsApp it to yourself).
2. On the phone, tap the APK file.
3. If Android says **"Install unknown apps"** is blocked, tap **Settings**, turn on **Allow from this source**, then go back and tap **Install**.
4. If Google Play Protect warns you, tap **Install anyway**. It warns about every app that isn't from the Play Store.
5. When the app asks for **location**, tap **Allow**.

### Part 6: Do the demo

1. Laptop: backend is running (Part 2) and connected to the hotspot.
2. Both phones are connected to the **same hotspot**.
3. **Phone 1, Madadgaar app:** log in with `3001234567` (that's **Ali Raza**, the customer). The code is always `1234`.
4. **Phone 2, Madadgaar Helper app:** log in with `3331234567` (that's **Ahmed Hussain**, the helper). The code is `1234`. Make sure he's **online**.
5. On Phone 1, pick a problem (for example **Flat tire**) and request help.
6. On Phone 2, a job pops up. Tap **Accept** within 15 seconds.
7. Watch Phone 1 update live: helper on the way → arrived → done → rate.

### If something goes wrong

| Problem | Fix |
|---|---|
| App says it can't connect | Is the backend window still open? Are both phones on the **same** hotspot as the laptop? |
| Phone's Chrome can't open `.../api/health` | The firewall is blocking it. Windows Settings → **Windows Security** → **Firewall** → **Allow an app through firewall** → tick **Node.js** for both Private and Public. |
| `npm` or `git` is "not recognized" | Close Command Prompt, open it again. If it still fails, reinstall Node.js or Git. |
| No helper accepts the job | On Phone 2, check the helper is **online**. Wait for the next offer. |
| Things look stuck or weird | Close the backend window, run `npm start` again, and log in again on both phones. |

## Running it (developers)

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
