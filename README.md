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
| `apps/admin_dashboard` | **Scoped-down but real and working.** Dashboard (demo admin login) showing live cards (active requests, online helpers, today's orders/revenue/commission, completed jobs, cancellation rate), a business-metrics/unit-economics section (GMV, Madadgaar revenue, helper payouts, AOV, response time, completion/cancellation/take rate — labeled DEMO DATA), a live active-requests list, a helpers table, and a Services tab to edit each service's quick-pick problem options live. Admin actions: approve/reject new helpers (with a "waiting for approval" alert), suspend/reactivate helpers, and cancel a stuck request (both parties notified). Everything refreshes live over the WebSocket, and the layout works at phone width (sidebar becomes a drawer). The live map, pricing-editing panel, city management and disputes tables from the original plan were cut for time. `flutter analyze`: 0 issues. |
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

### Part 1: Download the project (do this once)

1. Go to **https://github.com/nogamand-ops/madadgaar** (log in to GitHub first if the project is private).
2. Click the green **Code** button, then **Download ZIP**.
3. Open your **Downloads** folder, right-click `madadgaar-master.zip`, and choose **Extract All** → **Extract**.
4. You now have a folder called `madadgaar-master`. That's the whole project.

You **don't** need to install anything by hand. The start file does it for you.

### Part 2: Start everything (every time you demo)

1. Connect the laptop to the **hotspot** the phones will use. **The very first time, it needs internet** to download Node.js and the backend's parts.
2. Open the `madadgaar-master` folder and **double-click `start-demo.bat`**.
   - If Windows shows a blue **"Windows protected your PC"** box, click **More info** → **Run anyway**.
3. **First time only:** if Node.js isn't installed, it installs it automatically. If Windows asks *"Do you want to allow this app to make changes?"*, click **Yes**. If the automatic install fails, the Node.js website opens: click the big **LTS** button, install it, then double-click `start-demo.bat` again.
4. Your browser opens **all three apps** by itself:
   - Customer app: http://localhost:5173
   - Helper app: http://localhost:5174
   - Admin dashboard: http://localhost:5175
5. The black window shows **the laptop's address for the phones**, like `http://192.168.43.25:4000`. Write it down; you need it in Part 3 and Part 4.
6. **Leave both black windows open.** If you close them, the apps stop working.
7. If Windows shows a **firewall popup**, tick **both boxes** and click **Allow access**. If you click Cancel by mistake, the phones won't be able to connect.

Every time you restart it, the demo data resets to a fresh start. That's normal.

To see the apps at phone size on the laptop: press **F12**, then **Ctrl + Shift + M**, and pick a phone at the top.

### Part 3: Check the laptop's address

The phones need to know where the laptop is, like a house address. `start-demo.bat` shows it when it starts.

1. If it shows **more than one** address, use the one that starts like your hotspot's (often `192.168.`). If you're not sure, test each one with step 4.
2. You can also find it yourself: open Command Prompt, type `ipconfig`, and look for **IPv4 Address** under **Wireless LAN adapter Wi-Fi**.
3. Your laptop's full address is that number plus `:4000`, for example:
   ```
   http://192.168.43.25:4000
   ```
4. **Check it:** on a phone connected to the same WiFi, open Chrome and go to `http://192.168.43.25:4000/api/health` (using your own number). If you see `{"ok":true,...}`, the phone can reach the laptop. 🎉

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

**Show the admin side (on the laptop, http://localhost:5175):**

8. Tap **Continue as Admin (Demo)**. Point out that the numbers and the **Requests** list update **by themselves** while the phones are used. Nobody refreshes anything.
9. The yellow bar says **"1 new helper is waiting for approval"**. Tap **Review**. This shows that helpers are checked by Madadgaar before they can take jobs.
10. On **Naveed Aslam**, tap **Details** to show his vehicle and services, then tap **Approve**. He moves to **Verified**.
11. Tap any helper and show **Suspend helper**. That's how Madadgaar removes someone after complaints.
12. Go to **Requests**, tap an active request, and show **Cancel this request**. That's how support steps in when a job gets stuck. Both the customer and the helper are told.
13. Go to **Services** and add a new problem option (for example "Engine overheating"). It appears in the customer app's **"What's wrong?"** list straight away.

Restarting `start-demo.bat` puts everything back to the start (Naveed is pending again), so you can practise as often as you like.

### If something goes wrong

| Problem | Fix |
|---|---|
| App says it can't connect | Is the backend window still open? Are both phones on the **same** hotspot as the laptop? |
| Phone's Chrome can't open `.../api/health` | The firewall is blocking it. Windows Settings → **Windows Security** → **Firewall** → **Allow an app through firewall** → tick **Node.js** for both Private and Public. |
| Browser says "can't reach this page" for an app | Wait 5 seconds and refresh. Check the second black window ("Madadgaar Apps") is still open. |
| Black window says "address already in use" | It's already running in another window. Close all black windows and start again. |
| It keeps saying Node.js isn't installed | Restart the laptop once, then double-click `start-demo.bat` again. |
| No helper accepts the job | On Phone 2, check the helper is **online**. Wait for the next offer. |
| Things look stuck or weird | Close both black windows, double-click `start-demo.bat` again, and log in again on both phones. |

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
