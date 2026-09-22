# Relationship Manager (RM) Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a new Flutter web/tablet app — `astra_rm_portal` — that lets an authenticated Relationship Manager search their book of clients and see a complete, read-only 360° financial view of any one client: net worth, holdings, portfolio discipline/allocation, every spend/transaction-intelligence metric the backend computes, budget & financial-health diagnostics, goals, income, recurring bills/subscriptions, debt exposure, and the AI narrative/trust/sentiment layer already generated for that user — plus an RM-only workspace to log outreach notes and action items. Visual language, typography, and gradient CTA/text treatment are copied 1:1 from `astra-frontend`.

**Architecture:** New standalone Flutter project (`astra_rm_portal`), Riverpod for state, GoRouter with a persistent side-nav shell (`ShellRoute`), a client-context provider that scopes every screen to the currently-selected client, and a mock-repository layer per domain (mirroring the pattern already proven in `astra-frontend`'s `analytics`/`transactions` features this session) so wiring the real `zeyro_ai`/backend endpoints later is a drop-in repository-body swap, not a screen rewrite.

**Tech Stack:** Flutter (web + tablet target), `flutter_riverpod`, `go_router`, `dio` (for the future API layer, stubbed with mock repos now), `intl`, the copied `DMSans`/`SpaceGrotesk`/`DMMono` font files and `AppTheme`/`AnimatedGradientShimmer`/`TypewriterText` core widgets from `astra-frontend`.

---

## 0. Recommendation & Assumptions (read first)

- **Separate app, shared theme.** RM tooling is a different product surface (internal, desktop-first, "see everything about anyone") from the consumer app. Bundling it into `astra-frontend` would ship RM-only screens and cross-user data-fetch capability inside a binary that ends up on customer phones — a real security/attack-surface concern, not just an architecture nicety. `astra_rm_portal` is a sibling Flutter project; it copies (not imports) `app_theme.dart`, the three font families, `animated_gradient_text.dart`, and `typewriter_text.dart` from `astra-frontend/lib/core/`, so it looks identical without depending on the consumer app's build.
- **All data is mock/repository-stubbed for now**, exactly like this session's `AnalyticsRepository`/`TransactionsRepository` pattern: `Future<T>` methods, simulated latency, `peek()`/`get({forceRefresh})` caching. When `zeyro_ai`'s endpoints exist, only repository bodies change.
- **RM auth** is email + password + a 6-digit TOTP/OTP second factor (RMs are employees handling sensitive data — 2FA is a hard requirement, not optional). No phone-OTP flow like the consumer app.
- **The 60-item analytics list** you pasted maps to backend source files (`trend_analytics.go`, `domain_features.go`, `graph_service.go`, `spending_analyzer.go`, `budget-diagnosis.go`, `financial_metrics.go`, `insight_service.go`, `trust_engine.go`, `sentiment_analyzer.go`, `bandit_engine.go`, `user_baseline.go`, `income_analyzer.go`, `goals/summary.go`, `home/summary.go`, `dashboard_handler.go`, `get-analytics-summary.go`, `get-insights.go`, `ml_decision_engine.go`, `aggregate-monthly-spend.go`, `budget-insights.go`, `budget-manager-analysis.go`). None of these are exposed via any existing astra-frontend screen — they're backend-only today. This plan gives every one of them a home on an RM screen (mapping table in §2).
- **Read-only over the user's own data, read/write over RM workspace data.** The RM can never edit a client's transactions, budget, or holdings — only log notes/flags. This keeps the data model honest and avoids building a parallel write-path into someone else's finances.
- **Task granularity:** one task = one screen module (models → mock repo → widgets → screen → nav wiring), matching how `analytics`/`transactions` were actually built in `astra-frontend` this session — not per-metric TDD steps. At 60+ backend metrics across 10+ screens, per-metric bite-sizing would produce an unreadable, low-value plan. Widget-level unit tests are specified only where there's real calculation logic to verify (trend direction, streaks, health score) — pure layout/UI code follows the codebase's existing convention of no test-first ceremony.

---

## 1. Information Architecture

```
Login (email + password + 2FA)
  └─ RM Shell (persistent left side-nav, client search bar always visible)
       ├─ Book of Business          (/clients)              — home/landing screen
       ├─ Attention Queue           (/alerts)                — cross-client alert feed
       │
       └─ Client 360 (/clients/:id) — everything below is scoped to one selected client
            ├─ Overview              (/clients/:id)
            ├─ Holdings & Portfolio  (/clients/:id/holdings)
            ├─ Portfolio Analysis    (/clients/:id/analysis)   (discipline/allocation, AI insights)
            ├─ Spending Intelligence (/clients/:id/spending)   (the 20-item transaction-analytics list)
            ├─ Budget & Health       (/clients/:id/budget)
            ├─ Goals                (/clients/:id/goals)
            ├─ Income & Cash Flow    (/clients/:id/income)
            ├─ Recurring & Bills     (/clients/:id/recurring)
            ├─ Debt / BNPL           (/clients/:id/debt)
            ├─ AI & Trust            (/clients/:id/ai-insights)
            └─ RM Notes              (/clients/:id/notes)      — RM-only read/write workspace
```

Client-scoped screens share a persistent client header (avatar, name, net worth, health-score pill, quick tab bar) — built once (§2, Task 3) and reused by every screen under `/clients/:id/*`.

---

## 2. Screen-by-screen spec + 60-feature mapping

Each row: **Screen** — what it shows — which numbered items from your list live there.

| Screen | Shows | Source items |
|---|---|---|
| **Book of Business** | Searchable/sortable client list: name, AUM, today's %, health-score pill, unread-alert badge. Tap → Client 360. | — |
| **Attention Queue** | Cross-client feed, most-urgent first: category/merchant spend spikes, bill inflation, MoM trend alerts, dormant-merchant reactivation, overdue recurring bills, goal-at-risk, BNPL danger-zone. Filter by client/type/severity. | Merchant spike, Category spending spike, Category bill inflation, Overall spend trend alert, New/dormant merchant pattern, Recurring bill overdue, Goal progress risk, BNPL danger-zone |
| **Client 360 Overview** | Net worth, total balance, cash-on-hand, credit-card outstanding/available, health score (both variants), trust score, today's/weekly spend rollup, spending growth %, quick links into every sub-screen. | Net worth, Total balance rollup, Cash-on-hand rollup, Credit card outstanding/available, Financial health score (both variants), Trust score, Today's/weekly spend rollups, Spending growth % |
| **Holdings & Portfolio** | Demat holdings, MF holdings + SIPs, FDs, allocation wedge chart (reuse `CategoryAllocationCard` geometry), performance over time. | — (existing app data, no new backend item) |
| **Portfolio Analysis** | Discipline score, allocation vs target (reuse `portfolio_analysis` feature's cards, read-only), investment consistency score. | Investment consistency score |
| **Spending Intelligence** | The big one — tabs: *Patterns*, *Trends*, *Anomalies*, *Recurring*. See breakdown below. | Items 1–20 (full transaction-analytics list) + Today's/weekly rollups, Normalized spend-chart, Balance drawdown %, Top-category concentration, Category allocation status+sparkline, Monthly category aggregation |
| **Budget & Health** | Budget vs actual w/ OK/WARNING/CRITICAL, pacing projection, 6-month trend, ML-suggested budget + reasoning, health score breakdown, savings rate/net cash flow/burn rate/emergency-fund runway, AI recommendations. | Budget vs actual, Budget pacing, 6-month budget trend, Budget diagnosis, ML-suggested budget, Fallback split heuristic, Suggested-budget reasoning, Financial health score, Savings rate/cash flow/burn rate/runway, AI recommendations list, HF budget recommendations |
| **Goals** | Goals list, progress %, days-left, aggregation summary. | Goals summary aggregation, Goal progress % + days-left |
| **Income & Cash Flow** | Payday prediction/interval, income stability & frequency classification. | Income timing/payday prediction, Income stability & frequency |
| **Recurring & Bills** | Active subscription load (verified vs raw), upcoming (7-day) vs overdue, recurring-bill summary, due-date calendar. | Active subscription load, Recurring bill derivation, Upcoming recurring (7-day) |
| **Debt / BNPL** | BNPL exposure ratio to income, danger-zone flag, historical trend. | BNPL exposure & danger-zone |
| **AI & Trust** | Vibe-check/mood card (reuse `AiMoodInsightCard` avatar+shimmer pattern verbatim — this is the exact "attach an insight to the user" ask), header-insight generation log, trust-score decay/session-boost/vulnerability breakdown, sentiment trend, notification-variant bandit stats, user behavior baseline (median tx hour, weekend/weekday ratio). | AI vibe check, Home-header insight generation, Trust score engine, Sentiment analysis, Notification bandit, User behavior baseline |
| **RM Notes** | Timeline of RM-authored notes/flags per client, "mark actioned" on any insight/alert, follow-up reminders. RM-only write surface. | — (new capability, not in backend list) |

### Spending Intelligence — 4 tabs, mapped exactly to your 20-item list

- **Patterns tab:** Weekday vs weekend comparison (1), weekend ratio vs personal baseline (2), average transaction size stats (6), night/late-spend concentration (10), impulse spend profile (11), spending pattern summary — daily/weekly/monthly avgs, largest/smallest tx, per-merchant/per-weekday totals (18).
- **Trends tab:** Daily/weekly/monthly trend analytics — peak/trough, delta, direction, volatility, velocity+projection (3), category trend/anomaly (4), category momentum top-5 rising/falling (8), cross-entity comparison (9), overall MoM spend trend alert (16).
- **Anomalies tab:** Category overspend/savings streaks (5), merchant concentration/dependency (7), frequency spike detection (13), category spending spike (14), merchant spike 2×+ (15), category bill inflation (17), new/dormant merchant reactivation (18b), impulsive purchase heuristic (20).
- **Recurring tab:** Recurring subscription detection via graph (19a), recurring/subscription identification heuristic ≥3 consistent tx (19b).

---

## 3. Design system reuse (exact copy, not reinterpretation)

| Token | Source | Rule for RM portal |
|---|---|---|
| Fonts | `SpaceGrotesk`, `DMSans`, `DMMono` ttf files in `astra-frontend/lib/core/fonts/` | Copy the 4 font files verbatim into `astra_rm_portal/lib/core/fonts/`, same `pubspec.yaml` font block. |
| Type rule | `AppTheme` doc comment: SpaceGrotesk = big headings, DMSans = section headings/labels, DMMono = body | Same rule. Per this session's later correction on `astra-frontend`, **new dense-data screens (tables, RM screens) should default to DMSans for body text too** — DMMono is reserved for literal numeric/monospace contexts (amounts in a ledger row), not prose. |
| Section heading style | `fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -1.0, color: Color(0xFF0F172A)` (home screen convention, just applied to `analytics`) | Every RM screen section heading uses this exact style — that's literally "same fonts as certain sections" from your ask. |
| Colors | `AppTheme` — `bgLight #F8FAFC`, `textLight #0F172A`, `primaryLight #4F46E5` indigo, `secondaryLight #0D9488` teal, `accent #F43F5E` rose | Copy `app_theme.dart` unmodified. RM portal adds one extra token: `rmSeverityWarning #F97316`, `rmSeverityCritical #F43F5E`, `rmSeverityOk #22C55E` for alert-queue chips (matches the amber/rose/green already used across `analytics` status pills). |
| Gradient text / shimmer CTA | `lib/core/widgets/animated_gradient_text.dart` (`AnimatedGradientShimmer` + `SlidingGradientTransform`) used today on the AI insight card | Copy verbatim. Use on: the AI & Trust vibe-check card (direct reuse of `AiMoodInsightCard`), and on the primary CTA text inside empty-state / "generate insight" buttons — anywhere astra-frontend currently shimmer-gradients text, RM portal shimmer-gradients the equivalent text. Do **not** invent new gradient usages beyond where the consumer app already has them — this keeps "same theme," not a reinterpretation. |
| Typewriter reveal | `lib/core/widgets/typewriter_text.dart` | Copy verbatim. Reused only where astra-frontend uses it today: the AI insight narrative text. |
| Card radius | Per this session's latest change, analytics section cards were **flattened to no-card / direct-on-background** with `borderRadius: 4` reserved for small chips/pills only | RM portal's dense screens (tables, lists) follow the same instinct — group with `Divider`/whitespace, not nested card boxes, matching the `design_patterns`/`design_taste_frontend` "anti-card-overuse" principle you also just loaded. Use a real card (radius 4, `#E6E6E6` border) only for genuinely elevated, tappable summary tiles (Book-of-Business client rows, Attention Queue alert rows). |
| Buttons | `ElevatedButtonThemeData` in `AppTheme` — indigo fill, `radiusMedium` (16), `w600` label | Reuse unmodified for primary actions (e.g. "Log note", "Mark actioned"). |

---

## 4. File structure

```
astra_rm_portal/
  lib/
    core/
      theme/app_theme.dart                    (copied from astra-frontend)
      widgets/animated_gradient_text.dart      (copied)
      widgets/typewriter_text.dart             (copied)
      widgets/responsive_body.dart             (copied — same LayoutBuilder pattern)
      fonts/ (4 ttf files, copied)
      navigation/app_router.dart               (GoRouter + ShellRoute)
      navigation/rm_side_nav.dart              (persistent side-nav)
    features/
      auth/
        models/rm_session.dart
        data/rm_auth_repository.dart
        screens/rm_login_screen.dart
        screens/rm_otp_screen.dart
      clients/
        models/client_summary.dart
        data/clients_repository.dart
        widgets/client_row.dart
        screens/book_of_business_screen.dart
      alerts/
        models/attention_alert.dart
        data/alerts_repository.dart
        widgets/alert_row.dart
        screens/attention_queue_screen.dart
      client_context/
        providers/selected_client_provider.dart  (Riverpod — the one thing every client-scoped screen reads)
        widgets/client_header.dart                (shared header used by every /clients/:id/* screen)
      overview/
        models/client_overview.dart
        data/overview_repository.dart
        widgets/net_worth_card.dart
        widgets/health_score_row.dart
        widgets/quick_stats_grid.dart
        screens/client_overview_screen.dart
      holdings/
        models/holdings_models.dart
        data/holdings_repository.dart
        widgets/holdings_list.dart
        widgets/allocation_wedge_card.dart        (port of astra's _WedgeChartPainter)
        screens/holdings_screen.dart
      portfolio_analysis/
        models/analysis_models.dart
        data/analysis_repository.dart
        widgets/discipline_card.dart
        widgets/allocation_vs_target_card.dart
        screens/portfolio_analysis_screen.dart
      spending_intelligence/
        models/spending_intel_models.dart
        data/spending_intel_repository.dart
        widgets/patterns_tab.dart
        widgets/trends_tab.dart
        widgets/anomalies_tab.dart
        widgets/recurring_tab.dart
        screens/spending_intelligence_screen.dart
      budget_health/
        models/budget_health_models.dart
        data/budget_health_repository.dart
        widgets/budget_vs_actual_card.dart
        widgets/health_score_breakdown_card.dart
        widgets/ml_suggested_budget_card.dart
        screens/budget_health_screen.dart
      goals/
        models/goal_models.dart
        data/goals_repository.dart
        widgets/goal_row.dart
        screens/goals_screen.dart
      income/
        models/income_models.dart
        data/income_repository.dart
        widgets/payday_forecast_card.dart
        screens/income_screen.dart
      recurring_bills/
        models/recurring_models.dart
        data/recurring_repository.dart
        widgets/subscription_row.dart
        screens/recurring_screen.dart
      debt/
        models/debt_models.dart
        data/debt_repository.dart
        widgets/bnpl_exposure_card.dart
        screens/debt_screen.dart
      ai_trust/
        models/ai_trust_models.dart
        data/ai_trust_repository.dart
        widgets/vibe_check_card.dart              (near-verbatim port of AiMoodInsightCard)
        widgets/trust_score_card.dart
        widgets/sentiment_trend_card.dart
        screens/ai_trust_screen.dart
      rm_notes/
        models/rm_note.dart
        data/rm_notes_repository.dart             (the one repo with real writes, in-memory for now)
        widgets/note_composer.dart
        widgets/note_timeline.dart
        screens/rm_notes_screen.dart
    main.dart
  pubspec.yaml
```

---

## 5. Tasks

### Task 0: Project scaffold + theme port

**Files:**
- Create: `astra_rm_portal/` (new `flutter create --platforms=web,windows astra_rm_portal`)
- Create: `astra_rm_portal/lib/core/theme/app_theme.dart`
- Create: `astra_rm_portal/lib/core/widgets/animated_gradient_text.dart`
- Create: `astra_rm_portal/lib/core/widgets/typewriter_text.dart`
- Create: `astra_rm_portal/lib/core/widgets/responsive_body.dart`
- Create: `astra_rm_portal/lib/core/fonts/*.ttf` (copy 4 files)
- Modify: `astra_rm_portal/pubspec.yaml`

- [ ] **Step 1:** Run `flutter create --platforms=web,windows --org com.astra astra_rm_portal` in the directory alongside `astra-frontend`.
- [ ] **Step 2:** Copy `astra-frontend/lib/core/theme/app_theme.dart`, `animated_gradient_text.dart`, `typewriter_text.dart`, `responsive_body.dart`, and the 4 files in `astra-frontend/lib/core/fonts/` into the matching paths under `astra_rm_portal/lib/core/`. No edits — verify each file compiles standalone (they only depend on `package:flutter/material.dart`).
- [ ] **Step 3:** Add the font block to `astra_rm_portal/pubspec.yaml`, copied verbatim from `astra-frontend/pubspec.yaml`'s `flutter: fonts:` section, plus `flutter_riverpod: ^2.6.1`, `go_router: ^14.6.0`, `intl: ^0.19.0`, `dio: ^5.7.0` under `dependencies`.
- [ ] **Step 4:** Run `flutter pub get`, then `flutter run -d chrome` and confirm a default counter app renders with no font-loading errors in console.
- [ ] **Step 5:** Commit.

```bash
git add -A
git commit -m "scaffold astra_rm_portal, port theme/fonts/gradient widgets from astra-frontend"
```

### Task 1: RM auth (login + 2FA) + session provider

**Files:**
- Create: `lib/features/auth/models/rm_session.dart`
- Create: `lib/features/auth/data/rm_auth_repository.dart`
- Create: `lib/features/auth/screens/rm_login_screen.dart`
- Create: `lib/features/auth/screens/rm_otp_screen.dart`
- Create: `lib/features/auth/providers/rm_auth_provider.dart`

- [ ] **Step 1:** Define `RmSession` (`{String rmId, String name, String email, DateTime issuedAt}`) with `fromJson`.
- [ ] **Step 2:** `RmAuthRepository` singleton: `Future<bool> requestOtp({required String email, required String password})` (mock: any non-empty password succeeds after 500ms delay), `Future<RmSession?> verifyOtp({required String email, required String code})` (mock: accepts `"000000"`), matching the `Future` + simulated-delay convention from `AnalyticsRepository`.
- [ ] **Step 3:** `rm_auth_provider.dart` — a Riverpod `StateNotifierProvider<RmAuthNotifier, RmSession?>` exposing `login`/`verifyOtp`/`logout`, mirroring `astra-frontend`'s `auth_provider.dart` shape so the pattern is familiar to whoever implements the real API later.
- [ ] **Step 4:** `RmLoginScreen` — email + password fields, primary CTA styled from `AppTheme.lightTheme.elevatedButtonTheme`, headline in `SpaceGrotesk` 28px (same scale as astra's `LoginForm` "What's your number?" headline), on submit calls `requestOtp` then pushes `RmOtpScreen`.
- [ ] **Step 5:** `RmOtpScreen` — 6-box OTP input, on success sets the session provider and `context.go('/clients')`.
- [ ] **Step 6:** Wire `GoRouter.redirect` in `app_router.dart` (created in Task 2) to bounce to `/login` whenever `rm_auth_provider` is null.
- [ ] **Step 7:** Manually verify: run app, submit any email/password, enter `000000`, confirm redirect to `/clients` (stub screen from Task 2).
- [ ] **Step 8:** Commit.

```bash
git add lib/features/auth
git commit -m "add RM login + OTP auth flow with mock repository"
```

### Task 2: Router shell + side-nav + client search

**Files:**
- Create: `lib/core/navigation/app_router.dart`
- Create: `lib/core/navigation/rm_side_nav.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1:** `app_router.dart` — `GoRouter` with a top-level `/login`, `/otp`, and a `ShellRoute` wrapping everything else in `RmSideNav`; nested routes for `/clients`, `/alerts`, and `/clients/:clientId` + its children (paths listed in §1), each route builder reading `state.pathParameters['clientId']` into `selectedClientProvider` before building the child screen.
- [ ] **Step 2:** `RmSideNav` — fixed-width (240px) left rail: logo/wordmark top, nav items (Book of Business, Attention Queue) styled with `DMSans` 14px `w600`, active-item indicated by a left accent bar in `AppTheme.primaryLight` (no pill-background hover states — this is a dense admin rail, not the consumer bottom-nav pill). When a client is selected, render a secondary in-rail section listing the 10 client-scoped screens.
- [ ] **Step 3:** `main.dart` — `ProviderScope` + `MaterialApp.router` using `AppTheme.lightTheme`, `routerConfig: appRouter`.
- [ ] **Step 4:** Stub every screen referenced by the router as a bare `Scaffold(body: Center(child: Text('<name> — TODO')))` so the router compiles end-to-end before any real screen exists.
- [ ] **Step 5:** Run the app, log in, confirm every nav item routes to its stub without a GoRouter exception.
- [ ] **Step 6:** Commit.

```bash
git add lib/core/navigation lib/main.dart
git commit -m "add RM portal router shell, side-nav, and screen stubs"
```

### Task 3: Client context provider + shared client header

**Files:**
- Create: `lib/features/client_context/providers/selected_client_provider.dart`
- Create: `lib/features/client_context/widgets/client_header.dart`
- Create: `lib/features/clients/models/client_summary.dart`
- Create: `lib/features/clients/data/clients_repository.dart`

- [ ] **Step 1:** `ClientSummary` model — `{id, name, email, phoneMasked, avatarInitial, aumTotal, todayChangePercent, healthScore, trustScore, unreadAlertCount}`, `fromJson`.
- [ ] **Step 2:** `ClientsRepository.instance` — `Future<List<ClientSummary>> search(String query)` and `Future<ClientSummary?> getById(String id)`, backed by an in-memory mock list of ~15 realistic client rows (Indian names, varied AUM ₹2L–₹85L, mixed health scores).
- [ ] **Step 3:** `selectedClientProvider` — `StateProvider<ClientSummary?>`, set by the router (Task 2) whenever a `/clients/:clientId` route builds.
- [ ] **Step 4:** `ClientHeader` widget — avatar circle + name (`DMSans` 20/600, the section-heading style from §3), net-worth line, a horizontal row of small stat chips (health score, trust score, today's %), and a horizontal scrollable tab strip for the 10 client-scoped screens (reuses `AppTheme.primaryLight` for the active tab underline). Every client-scoped screen wraps its body in `Column([ClientHeader(client), Expanded(child: <screen content>)])`.
- [ ] **Step 5:** Wire `book_of_business_screen.dart` stub (Task 2) to real data: `ListView` of `ClientRow` widgets from `ClientsRepository.search('')`, a search `TextField` at top filtering by name, tapping a row does `context.go('/clients/${client.id}')`.
- [ ] **Step 6:** Manually verify: log in, see 15 client rows, search narrows the list, tapping one shows `ClientHeader` correctly on the (still-stub) overview screen.
- [ ] **Step 7:** Commit.

```bash
git add lib/features/client_context lib/features/clients
git commit -m "add client search, selected-client context, and shared client header"
```

### Task 4: Attention Queue

**Files:**
- Create: `lib/features/alerts/models/attention_alert.dart`
- Create: `lib/features/alerts/data/alerts_repository.dart`
- Create: `lib/features/alerts/widgets/alert_row.dart`
- Create: `lib/features/alerts/screens/attention_queue_screen.dart`

- [ ] **Step 1:** `AttentionAlert` model — `{id, clientId, clientName, type (enum: merchantSpike, categorySpike, billInflation, overallTrend, dormantMerchant, overdueRecurring, goalAtRisk, bnplDanger), severity (ok/warning/critical), title, detail, detectedAt}`, `fromJson`.
- [ ] **Step 2:** `AlertsRepository.instance` — `Future<List<AttentionAlert>> getAll({String? clientId, AlertSeverity? severity})`, mock data spanning all 8 `type`s across several of the 15 mock clients, severities weighted toward `warning`.
- [ ] **Step 3:** `AlertRow` — severity-colored left bar (`rmSeverityWarning`/`Critical`/`Ok` tokens from §3), client name + alert title (`DMSans` 14/600), detail line (`DMSans` 12, `#64748B`), relative timestamp; tapping navigates to `/clients/{clientId}` (deep-links into the screen matching the alert's `type`, per the mapping table in §2's Attention Queue row).
- [ ] **Step 4:** `AttentionQueueScreen` — filter chip row (All / by type / by severity) above a `ListView.separated` of `AlertRow`s, section heading "Attention queue" in the §3 heading style, no card wrapper (flat list + `Divider`, per the anti-card-overuse rule).
- [ ] **Step 5:** Manually verify: alerts render, filters narrow the list, tapping one routes to the right client + screen.
- [ ] **Step 6:** Commit.

```bash
git add lib/features/alerts
git commit -m "add cross-client attention queue"
```

### Task 5: Client Overview

**Files:**
- Create: `lib/features/overview/models/client_overview.dart`
- Create: `lib/features/overview/data/overview_repository.dart`
- Create: `lib/features/overview/widgets/net_worth_card.dart`
- Create: `lib/features/overview/widgets/health_score_row.dart`
- Create: `lib/features/overview/widgets/quick_stats_grid.dart`
- Create: `lib/features/overview/screens/client_overview_screen.dart`

- [ ] **Step 1:** `ClientOverview` model covering: `netWorth`, `totalBalance`, `cashOnHand`, `ccOutstanding`, `ccAvailable`, `healthScore100` (budget-penalized variant), `healthScoreHumanizer` (multi-factor variant), `trustScore`, `todaySpend`, `weeklySpend`, `spendingGrowthPercent`. `fromJson`.
- [ ] **Step 2:** `OverviewRepository.instance` — `Future<ClientOverview> getOverview(String clientId)`, peek/cache pattern identical to `AnalyticsRepository.getSummary`.
- [ ] **Step 3:** `NetWorthCard` — big number in `SpaceGrotesk` (matches astra's big-number treatment, e.g. `home_portfolio_growth.dart`'s 20px+ DMSans numerals — use the same weight/scale astra uses for its largest on-screen currency figures), no card box, sits directly under `ClientHeader`.
- [ ] **Step 4:** `HealthScoreRow` — two side-by-side score dials (the 100-pt budget-penalized score and the humanizer multi-factor score) so an RM can see both variants and their disagreement at a glance — a genuinely new comparison view, since no existing astra screen shows both.
- [ ] **Step 5:** `QuickStatsGrid` — 2×3 grid (cash-on-hand, CC outstanding/available, today's spend, weekly spend, spending growth %), each cell `DMSans` label + `DMSans` value, no per-cell card border — separated by hairline dividers only.
- [ ] **Step 6:** `ClientOverviewScreen` assembles `ClientHeader` (Task 3) + the three widgets above + a "Jump to" row of text links to the other 9 client-scoped screens.
- [ ] **Step 7:** Manually verify against 2–3 different mock clients (varied health scores) that both score dials and the grid render sensibly at extremes (0 and 100).
- [ ] **Step 8:** Commit.

```bash
git add lib/features/overview
git commit -m "add client overview screen: net worth, dual health score, quick stats"
```

### Task 6: Holdings & Portfolio

**Files:**
- Create: `lib/features/holdings/models/holdings_models.dart`
- Create: `lib/features/holdings/data/holdings_repository.dart`
- Create: `lib/features/holdings/widgets/holdings_list.dart`
- Create: `lib/features/holdings/widgets/allocation_wedge_card.dart`
- Create: `lib/features/holdings/screens/holdings_screen.dart`

- [ ] **Step 1:** Models: `Holding {instrumentType (equity/mf/fd), name, quantity, avgPrice, currentPrice, currentValue, gainPercent}`. `fromJson`.
- [ ] **Step 2:** `HoldingsRepository.instance` — `Future<List<Holding>> getHoldings(String clientId)`, mock ~8–12 holdings per client mixing all 3 instrument types.
- [ ] **Step 3:** `HoldingsList` — grouped by `instrumentType` (section heading per group, §3 style), each row: name, qty×avg→current, gain % in green/rose.
- [ ] **Step 4:** `AllocationWedgeCard` — direct port of `astra-frontend`'s `_WedgeChartPainter` from `category_allocation_card.dart` (same rounded-wedge geometry, `asin`-based gap math), fed by instrument-type totals instead of spend categories. Copy the painter code, don't reinvent it — this is the literal "same look" the RM portal should have wherever a wedge/donut breakdown appears.
- [ ] **Step 5:** `HoldingsScreen` assembles `ClientHeader` + `AllocationWedgeCard` + `HoldingsList`.
- [ ] **Step 6:** Manually verify holdings sum to a value consistent with `NetWorthCard` on Overview (adjust mock data if they visibly diverge — RM data must look internally consistent).
- [ ] **Step 7:** Commit.

```bash
git add lib/features/holdings
git commit -m "add holdings screen with ported wedge-chart allocation view"
```

### Task 7: Portfolio Analysis (discipline, allocation-vs-target, investment consistency)

**Files:**
- Create: `lib/features/portfolio_analysis/models/analysis_models.dart`
- Create: `lib/features/portfolio_analysis/data/analysis_repository.dart`
- Create: `lib/features/portfolio_analysis/widgets/discipline_card.dart`
- Create: `lib/features/portfolio_analysis/widgets/allocation_vs_target_card.dart`
- Create: `lib/features/portfolio_analysis/widgets/investment_consistency_card.dart`
- Create: `lib/features/portfolio_analysis/screens/portfolio_analysis_screen.dart`

- [ ] **Step 1:** Models: `DisciplineScore {score0to100, label}`, `AllocationTarget {category, targetPercent, actualPercent}`, `InvestmentConsistency {activeMonthPercent, currentStreakMonths, missedMonths, avgInvestedPerMonth}`. `fromJson` on each.
- [ ] **Step 2:** `AnalysisRepository.instance` — three `Future` getters, mock data.
- [ ] **Step 3:** `DisciplineCard` — reuse astra's `home_portfolio_analysis.dart` visual pattern (icon + "Analyse your wealth"-style `DMSans` 20 heading, braille-dot decorative flourish if present) rather than inventing a new look, since this is literally the same concept surfaced to an RM instead of the user.
- [ ] **Step 4:** `AllocationVsTargetCard` — horizontal bar per category, target marker vs actual fill, `DMSans` labels.
- [ ] **Step 5:** `InvestmentConsistencyCard` — streak number large (`SpaceGrotesk`), active-month % as a small sparkline-style row of 12 filled/unfilled month dots.
- [ ] **Step 6:** `PortfolioAnalysisScreen` assembles all three under `ClientHeader`.
- [ ] **Step 7:** Manually verify with a mock client that has a broken streak (missed months > 0) renders the dot row correctly (gaps visible).
- [ ] **Step 8:** Commit.

```bash
git add lib/features/portfolio_analysis
git commit -m "add portfolio analysis screen: discipline, allocation-vs-target, consistency"
```

### Task 8: Spending Intelligence — models, repository, and Patterns tab

**Files:**
- Create: `lib/features/spending_intelligence/models/spending_intel_models.dart`
- Create: `lib/features/spending_intelligence/data/spending_intel_repository.dart`
- Create: `lib/features/spending_intelligence/widgets/patterns_tab.dart`
- Create: `lib/features/spending_intelligence/screens/spending_intelligence_screen.dart`

This is the largest single task — split across Tasks 8–11 (one per tab) sharing one model file and one repository.

- [ ] **Step 1:** Define every model needed across all 4 tabs in `spending_intel_models.dart` up front (so Tasks 9–11 don't redefine overlapping shapes): `WeekdayWeekendSplit`, `WeekendBaselineDeviation`, `TrendAnalytics {period, peak, trough, deltaPercent, direction (enum: increasing/decreasing/flat/volatile), volatilityStdDev, velocity, projection30Day}`, `CategoryTrend {category, momChangePercent, direction, isAnomaly}`, `SpendStreak {category, streakType (over/under), consecutiveMonths}`, `TransactionSizeStats {avgDebit, avgCredit, avgOverall, maxDebit, minDebit}`, `MerchantConcentration {merchant, sharePercent}`, `CategoryMomentum {category, changePercent, rising}`, `NightSpendConcentration {percentOfTotal}`, `ImpulseProfile {windowStart, windowEnd, score0to100, topCategories}`, `FrequencySpike {merchant, currentRate, historicAvgRate}`, `SpendAnomaly {type, description, severity, detectedAt}`, `RecurringSubscription {merchant, amount, intervalDays, nextExpectedDate, source (graph/heuristic)}`. Every model gets `fromJson`.
- [ ] **Step 2:** `SpendingIntelRepository.instance` — one `Future<SpendingIntelBundle>` getter per client that returns all of the above in one payload (mirrors `AnalyticsRepository.getSummary`'s single-bundle pattern), plus `peekBundle`/cache.
- [ ] **Step 3:** Mock-data generation: reuse the deterministic-per-day pseudo-random approach from `astra-frontend`'s `AnalyticsRepository._buildMockFocusData` (seeded `Random` per date) so trend/anomaly numbers are stable across rebuilds for the same client, not re-randomized every navigation.
- [ ] **Step 4:** `PatternsTab` widget — sections (each with a §3-style heading, no card wrapper): "Weekday vs weekend" (bar pair + %), "Weekend spend vs your baseline" (deviation badge + top weekend category + social-spend %), "Transaction size" (avg debit/credit/overall + max/min as a `QuickStatsGrid`-style row), "Night spend" (% pill + short sentence), "Impulse profile" (0–100 gauge + top impulse categories chip row), "Spending pattern summary" (daily/weekly/monthly avg table + largest/smallest tx + per-weekday mini bar row).
- [ ] **Step 5:** `SpendingIntelligenceScreen` — `ClientHeader` + a 4-tab `TabBar` (Patterns/Trends/Anomalies/Recurring) styled with the same active-underline treatment as `RmSideNav`'s active tab, `TabBarView` showing `PatternsTab` for tab 0 and placeholder `SizedBox.shrink()` for the other 3 (filled in Tasks 9–11).
- [ ] **Step 6:** Manually verify Patterns tab renders sensibly for 3 different mock clients.
- [ ] **Step 7:** Commit.

```bash
git add lib/features/spending_intelligence
git commit -m "add spending intelligence models, repository, and Patterns tab"
```

### Task 9: Spending Intelligence — Trends tab

**Files:**
- Create: `lib/features/spending_intelligence/widgets/trends_tab.dart`
- Modify: `lib/features/spending_intelligence/screens/spending_intelligence_screen.dart`

- [ ] **Step 1:** `TrendsTab` — daily/weekly/monthly period switcher (segmented control, `DMSans` 13/600), then: trend chart (port `astra-frontend`'s `_SpendTrendsPainter` bar-chart geometry from `spend_trends_card.dart` — same dashed grid + avg-line pill + tap-to-select bar treatment, fed by the selected period's series) with peak/trough markers and a direction badge (INCREASING/DECREASING/FLAT/VOLATILE, colored per §3 severity tokens), volatility (std-dev + CoV) and 30-day projection as a stat row below the chart.
- [ ] **Step 2:** Category trend/anomaly list — reuse `_CategoryBudgetRow`-style row layout from `astra-frontend`'s `category_spends_screen.dart` (name, %, colored delta), append an anomaly flag chip when `isAnomaly`.
- [ ] **Step 3:** Category momentum — two columns, "Rising" (top 5 by `changePercent` desc) and "Falling" (bottom 5), arrow icon + %.
- [ ] **Step 4:** Cross-entity comparison — a simple multi-select chip row (categories/merchants) + a live-updating stacked bar showing exact % share across the current selection.
- [ ] **Step 5:** Wire `TrendsTab` into `SpendingIntelligenceScreen`'s tab 1.
- [ ] **Step 6:** Manually verify: switching daily/weekly/monthly changes the chart data and direction badge consistently (e.g. a client with rising spend shows INCREASING + upward chart).
- [ ] **Step 7:** Commit.

```bash
git add lib/features/spending_intelligence
git commit -m "add spending intelligence Trends tab: period trend chart, momentum, cross-entity compare"
```

### Task 10: Spending Intelligence — Anomalies tab

**Files:**
- Create: `lib/features/spending_intelligence/widgets/anomalies_tab.dart`
- Modify: `lib/features/spending_intelligence/screens/spending_intelligence_screen.dart`

- [ ] **Step 1:** `AnomaliesTab` — flat `ListView` of `SpendAnomaly` rows (reuse `AlertRow` styling from Task 4 — same severity-bar + title/detail pattern, since these are the same shape of information at the client-scoped level instead of cross-client), covering: category overspend/savings streaks, merchant concentration/dependency (top-3 concentration %), frequency spike, category spending spike, merchant spike (2×+), category bill inflation (>1.2×), new/dormant-merchant reactivation, impulsive-purchase heuristic hits.
- [ ] **Step 2:** A small stat strip above the list: top-3 merchant concentration %, current longest streak (over/under, whichever active).
- [ ] **Step 3:** Wire into tab 2.
- [ ] **Step 4:** Manually verify severity coloring matches: `critical` for merchant spike/bill inflation, `warning` for streaks/concentration, `ok`-tone (informational, not alarming) for dormant-merchant reactivation.
- [ ] **Step 5:** Commit.

```bash
git add lib/features/spending_intelligence
git commit -m "add spending intelligence Anomalies tab"
```

### Task 11: Spending Intelligence — Recurring tab

**Files:**
- Create: `lib/features/spending_intelligence/widgets/recurring_tab.dart`
- Modify: `lib/features/spending_intelligence/screens/spending_intelligence_screen.dart`

- [ ] **Step 1:** `RecurringTab` — list of `RecurringSubscription`, grouped by `source` (Detected via pattern-graph / Detected via heuristic) since the backend runs two independent detectors (28–32-day graph match vs ≥3-consistent-amount heuristic) and an RM benefits from seeing which method flagged what (graph detections are higher-confidence).
- [ ] **Step 2:** Each row: merchant, amount, interval, next-expected date, small confidence chip derived from `source`.
- [ ] **Step 3:** Wire into tab 3, completing `SpendingIntelligenceScreen`.
- [ ] **Step 4:** Manually verify all 4 tabs are reachable and each renders without a loading spinner stuck (i.e., `SpendingIntelRepository`'s single bundle fetch actually resolves before any tab needs it — check the peek/fetch pattern from Task 8 Step 2 isn't leaving tabs 2–4 in perpetual loading state).
- [ ] **Step 5:** Commit.

```bash
git add lib/features/spending_intelligence
git commit -m "add spending intelligence Recurring tab, complete 4-tab screen"
```

### Task 12: Budget & Financial Health

**Files:**
- Create: `lib/features/budget_health/models/budget_health_models.dart`
- Create: `lib/features/budget_health/data/budget_health_repository.dart`
- Create: `lib/features/budget_health/widgets/budget_vs_actual_card.dart`
- Create: `lib/features/budget_health/widgets/budget_pacing_card.dart`
- Create: `lib/features/budget_health/widgets/budget_trend_history_card.dart`
- Create: `lib/features/budget_health/widgets/ml_suggested_budget_card.dart`
- Create: `lib/features/budget_health/widgets/health_score_breakdown_card.dart`
- Create: `lib/features/budget_health/widgets/cash_flow_metrics_row.dart`
- Create: `lib/features/budget_health/widgets/ai_recommendations_list.dart`
- Create: `lib/features/budget_health/screens/budget_health_screen.dart`

- [ ] **Step 1:** Models: `CategoryBudget {category, budgeted, actual, status (ok/warning/critical), percentUsed}`, `BudgetPacing {spendRatio, monthCompletionRatio, onTrack}`, `BudgetTrendPoint {month, budgeted, actual}` (6 entries), `MlBudgetSuggestion {category, suggestedAmount, reasoning, method (ridgeRegression/hfModel/heuristicFallback)}`, `HealthScoreBreakdown {overall, budgetPenalty, savingsComponent, debtComponent, ...}`, `CashFlowMetrics {savingsRatePercent, netCashFlow, burnRate, emergencyFundRunwayMonths}`, `AiRecommendation {title, description, priority}`. `fromJson` on each.
- [ ] **Step 2:** `BudgetHealthRepository.instance` — one bundle getter, mock data (reuse `astra-frontend`'s `budget` feature's existing mock-data shapes/category names for consistency where categories overlap — check `lib/features/budget/data/budget_mock_providers.dart` for the established category list before inventing new ones).
- [ ] **Step 3:** `BudgetVsActualCard` — reuse `astra-frontend`'s `_CategoryBudgetRow` progress-bar treatment (from `category_spends_screen.dart`), status-colored per §3 severity tokens.
- [ ] **Step 4:** `BudgetPacingCard` — a single horizontal dual-track bar: month-completion marker vs spend-ratio marker, "on pace" / "ahead of spend" / "behind pace" label derived from the gap.
- [ ] **Step 5:** `BudgetTrendHistoryCard` — reuse the `_SpendTrendsPainter` bar-chart port from Task 9, fed budgeted-vs-actual dual series instead of single spend series (extend the ported painter to draw two bars per period rather than duplicating a whole new painter).
- [ ] **Step 6:** `MlSuggestedBudgetCard` — per-category suggested amount + a one-line `reasoning` string in `DMSans` italic-weight-substitute (use `FontStyle.italic` since DMSans doesn't ship a true italic — verify visually, fall back to lighter color-weight if italic synthesis looks bad in Flutter web), small `method` tag chip.
- [ ] **Step 7:** `HealthScoreBreakdownCard` — stacked horizontal bar showing each component's contribution to the overall score, legend below.
- [ ] **Step 8:** `CashFlowMetricsRow` — 4-cell row (savings rate %, net cash flow, burn rate, emergency-fund runway in months), same no-card hairline-divider treatment as `QuickStatsGrid`.
- [ ] **Step 9:** `AiRecommendationsList` — reuse `ActionableInsightsCard`'s horizontal-carousel pod pattern from `astra-frontend`'s analytics feature (staggered fade/scale entrance, 40ms per index) verbatim, since this is literally the same "AI recommendation cards" concept.
- [ ] **Step 10:** `BudgetHealthScreen` assembles all 7 widgets under `ClientHeader`.
- [ ] **Step 11:** Manually verify: a mock client in `CRITICAL` budget status shows the health-score breakdown visibly penalized (lower overall bar) — the two must correlate, don't let them be generated independently and disagree.
- [ ] **Step 12:** Commit.

```bash
git add lib/features/budget_health
git commit -m "add budget & financial health screen"
```

### Task 13: Goals

**Files:**
- Create: `lib/features/goals/models/goal_models.dart`
- Create: `lib/features/goals/data/goals_repository.dart`
- Create: `lib/features/goals/widgets/goal_row.dart`
- Create: `lib/features/goals/screens/goals_screen.dart`

- [ ] **Step 1:** `Goal {id, name, targetAmount, currentAmount, progressPercent, targetDate, daysLeft}`, `fromJson`.
- [ ] **Step 2:** `GoalsRepository.instance` — `Future<List<Goal>> getGoals(String clientId)`, mock 2–4 goals per client (e.g. "Emergency fund", "Goa trip", "Home down payment").
- [ ] **Step 3:** `GoalRow` — name + progress bar + `daysLeft` badge (rose if `daysLeft < 30` and `progressPercent < 80`, else neutral).
- [ ] **Step 4:** `GoalsScreen` — `ClientHeader` + `ListView` of `GoalRow`, aggregate summary line at top ("3 goals · ₹4.2L saved of ₹9L target").
- [ ] **Step 5:** Manually verify a near-deadline underfunded goal shows the rose badge.
- [ ] **Step 6:** Commit.

```bash
git add lib/features/goals
git commit -m "add goals screen"
```

### Task 14: Income & Cash Flow

**Files:**
- Create: `lib/features/income/models/income_models.dart`
- Create: `lib/features/income/data/income_repository.dart`
- Create: `lib/features/income/widgets/payday_forecast_card.dart`
- Create: `lib/features/income/widgets/income_stability_card.dart`
- Create: `lib/features/income/screens/income_screen.dart`

- [ ] **Step 1:** `IncomeProfile {avgIntervalDays, nextPredictedPayday, stabilityScore0to100, frequencyClass (weekly/biweekly/monthly/irregular)}`, `fromJson`.
- [ ] **Step 2:** `IncomeRepository.instance` — mock getter.
- [ ] **Step 3:** `PaydayForecastCard` — next predicted date large (`SpaceGrotesk`), interval detected as caption.
- [ ] **Step 4:** `IncomeStabilityCard` — stability score gauge + frequency-class chip.
- [ ] **Step 5:** `IncomeScreen` assembles both under `ClientHeader`.
- [ ] **Step 6:** Manually verify an `irregular` frequency client renders a lower stability score (keep mock data internally consistent — irregular income should never show 95+ stability).
- [ ] **Step 7:** Commit.

```bash
git add lib/features/income
git commit -m "add income & cash flow screen"
```

### Task 15: Recurring & Bills

**Files:**
- Create: `lib/features/recurring_bills/models/recurring_models.dart`
- Create: `lib/features/recurring_bills/data/recurring_repository.dart`
- Create: `lib/features/recurring_bills/widgets/subscription_row.dart`
- Create: `lib/features/recurring_bills/widgets/upcoming_vs_overdue_split.dart`
- Create: `lib/features/recurring_bills/screens/recurring_screen.dart`

- [ ] **Step 1:** `ActiveSubscription {merchant, amount, verifiedAgainstDebits, dueDate, status (upcoming/overdue/paid)}`, `fromJson`.
- [ ] **Step 2:** `RecurringRepository.instance` — mock ~6–10 subscriptions per client, some `overdue`, most `upcoming` within the 7-day window (reuse the recurring-subscription mock records from Task 11's `SpendingIntelRepository` for merchant/amount consistency — a client's subscriptions shouldn't disagree between the two screens).
- [ ] **Step 3:** `UpcomingVsOverdueSplit` — two-column summary (count + total ₹) at top of screen.
- [ ] **Step 4:** `SubscriptionRow` — merchant, amount, due date, status chip, `verifiedAgainstDebits` shown as a small checkmark/question-mark icon (verified vs unconfirmed).
- [ ] **Step 5:** `RecurringScreen` assembles both under `ClientHeader`.
- [ ] **Step 6:** Manually verify the same merchant/amount appears consistently in this screen and in Spending Intelligence's Recurring tab for the same mock client (cross-check the two mock data sources agree — this is a real correctness bar, not cosmetic).
- [ ] **Step 7:** Commit.

```bash
git add lib/features/recurring_bills
git commit -m "add recurring & bills screen, reconciled with spending-intelligence recurring data"
```

### Task 16: Debt / BNPL

**Files:**
- Create: `lib/features/debt/models/debt_models.dart`
- Create: `lib/features/debt/data/debt_repository.dart`
- Create: `lib/features/debt/widgets/bnpl_exposure_card.dart`
- Create: `lib/features/debt/screens/debt_screen.dart`

- [ ] **Step 1:** `BnplExposure {currentRatioToIncome, historicalAvgRatio, inDangerZone, activeBnplCount}`, `fromJson`.
- [ ] **Step 2:** `DebtRepository.instance` — mock getter; make ~2 of the 15 mock clients `inDangerZone: true` so the Attention Queue (Task 4) has real BNPL-danger alerts to show — go back and add matching `AttentionAlert` rows for those 2 clients if Task 4's mock data doesn't already include this type.
- [ ] **Step 3:** `BnplExposureCard` — current vs historical ratio as a two-bar compare, danger-zone banner (rose background, `DMSans` 13/600 white text) when `inDangerZone`.
- [ ] **Step 4:** `DebtScreen` assembles under `ClientHeader`.
- [ ] **Step 5:** Manually verify the danger-zone banner only shows for the 2 flagged clients, not all 15.
- [ ] **Step 6:** Commit.

```bash
git add lib/features/debt
git commit -m "add debt/BNPL exposure screen"
```

### Task 17: AI & Trust

**Files:**
- Create: `lib/features/ai_trust/models/ai_trust_models.dart`
- Create: `lib/features/ai_trust/data/ai_trust_repository.dart`
- Create: `lib/features/ai_trust/widgets/vibe_check_card.dart`
- Create: `lib/features/ai_trust/widgets/trust_score_card.dart`
- Create: `lib/features/ai_trust/widgets/sentiment_trend_card.dart`
- Create: `lib/features/ai_trust/widgets/behavior_baseline_card.dart`
- Create: `lib/features/ai_trust/screens/ai_trust_screen.dart`

- [ ] **Step 1:** Models: `VibeCheck {mood (happy/neutral/concerned), narrativeText}`, `TrustScoreDetail {score0to100, decayPoints, sessionBoostPoints, vulnerabilityPoints, trend7Day}`, `SentimentPoint {date, sentimentScore}` (list, keyword-based per `sentiment_analyzer.go`), `BehaviorBaseline {medianTxHour, weekendWeekdayRatio}`. `fromJson` on each.
- [ ] **Step 2:** `AiTrustRepository.instance` — mock getter, reusing the same `AiMood` enum semantics (`happy`/`neutral`/`concerned`) already defined in `astra-frontend`'s `analytics_models.dart` so the vibe-check port in Step 3 doesn't need a translation layer.
- [ ] **Step 3:** `VibeCheckCard` — near-verbatim port of `astra-frontend`'s `AiMoodInsightCard` + `_MoodAvatar` (the full blob-face + micro-animation state machine — wink/blush for happy, tears/whimper for neutral, anger-flash/head-shake for concerned). Copy the file, rename to `VibeCheckCard`/`_MoodAvatar`, keep every animation controller and the `_BlobFacePainter` geometry unchanged — this is the literal "AI insights on the user, shown by AI" feature from the request, and it should look exactly like the consumer app's version because it's showing the same underlying signal to a different audience.
- [ ] **Step 4:** `TrustScoreCard` — overall score gauge + 3-row breakdown (decay/session-boost/vulnerability points, each signed +/− with color), small 7-day trend sparkline (reuse `_SparklinePainter` from `astra-frontend`'s `monthly_spending_level_card.dart`).
- [ ] **Step 5:** `SentimentTrendCard` — line chart of `SentimentPoint`s over the last 30 days (reuse the `_FocusChartPainter` line-geometry port style from Task 9's trend chart, single series, no fill).
- [ ] **Step 6:** `BehaviorBaselineCard` — two stat cells: median transaction hour (formatted as e.g. "2:40 PM"), weekend/weekday spend ratio.
- [ ] **Step 7:** `AiTrustScreen` assembles all 4 under `ClientHeader`. Skip surfacing "Notification variant selection (multi-armed bandit)" as a dedicated widget — it's an internal system-tuning mechanism (which notification copy variant to show a user), not information that helps an RM understand or help a client; note this explicitly as an intentional scope cut rather than a silent omission.
- [ ] **Step 8:** Manually verify the vibe-check avatar's micro-animations actually play (wink/tears/head-shake per mood) exactly as they do in `astra-frontend` — this was a point of emphasis in the original consumer-app work and must carry over faithfully.
- [ ] **Step 9:** Commit.

```bash
git add lib/features/ai_trust
git commit -m "add AI & trust screen with ported vibe-check avatar"
```

### Task 18: RM Notes (the one RM-write surface)

**Files:**
- Create: `lib/features/rm_notes/models/rm_note.dart`
- Create: `lib/features/rm_notes/data/rm_notes_repository.dart`
- Create: `lib/features/rm_notes/widgets/note_composer.dart`
- Create: `lib/features/rm_notes/widgets/note_timeline.dart`
- Create: `lib/features/rm_notes/screens/rm_notes_screen.dart`

- [ ] **Step 1:** `RmNote {id, clientId, authorRmId, authorName, text, linkedAlertId?, createdAt, followUpDate?}`, `fromJson`.
- [ ] **Step 2:** `RmNotesRepository.instance` — `Future<List<RmNote>> getNotes(String clientId)` (mock 2–3 seed notes per client) and `Future<RmNote> addNote({required String clientId, required String text, String? linkedAlertId, DateTime? followUpDate})` — the one repository method in this whole plan that actually mutates in-memory state rather than just returning mock data, since RM notes are a real write surface even before a backend exists.
- [ ] **Step 3:** `NoteComposer` — multiline `TextField` + optional follow-up date picker + "Log note" button (`AppTheme` primary button style).
- [ ] **Step 4:** `NoteTimeline` — reverse-chronological list, each entry: author + relative time + text, follow-up date shown as a small badge if set.
- [ ] **Step 5:** `RmNotesScreen` — `ClientHeader` + `NoteComposer` + `NoteTimeline`.
- [ ] **Step 6:** Add a "Log note" quick action from `AlertRow` (Task 4) that deep-links here with `linkedAlertId` pre-filled — closes the loop between "RM sees an anomaly" and "RM records what they did about it," which is the actual point of this screen existing.
- [ ] **Step 7:** Manually verify: add a note, navigate away, navigate back — note persists (in-memory for the session) and appears at the top of the timeline.
- [ ] **Step 8:** Commit.

```bash
git add lib/features/rm_notes
git commit -m "add RM notes workspace, linked from attention-queue alerts"
```

### Task 19: End-to-end pass

**Files:** none new — verification only.

- [ ] **Step 1:** Run `flutter analyze` across the whole `astra_rm_portal` project; fix everything until "No issues found!".
- [ ] **Step 2:** Manual click-through: login → OTP → Book of Business → search a client → open Overview → visit all 10 client-scoped tabs via the side-nav → open Attention Queue → click an alert → confirm it deep-links correctly → log an RM note from that alert → confirm it appears in RM Notes.
- [ ] **Step 3:** Resize the browser window from ~1440px down to ~900px (tablet width) and confirm the side-nav + `ClientHeader` + every screen's `ResponsiveBody`-wrapped content stays usable with no horizontal scroll and no overlapping text — RM portal is desktop/tablet-only by design (no phone breakpoint needed), but must not break above ~900px.
- [ ] **Step 4:** Cross-check the "internal consistency" spots flagged in earlier tasks: Holdings total vs Overview net worth (Task 6), Budget status vs Health score breakdown (Task 12), Income stability vs frequency class (Task 14), Recurring merchants matching between Recurring screen and Spending Intelligence (Task 15), BNPL danger-zone clients matching Attention Queue entries (Task 16).
- [ ] **Step 5:** Commit any fixes found during this pass.

```bash
git add -A
git commit -m "RM portal end-to-end verification pass and consistency fixes"
```

---

## 6. Self-review

**Spec coverage** — every numbered item from your pasted list has a home in §2's mapping table; the four dashboard/net-worth items and the behavioral/narrative items are covered in Overview and AI & Trust respectively. Items explicitly scoped out with reasoning: notification-bandit variant selection (Task 17, Step 7 — internal system mechanism, not RM-relevant information).

**Placeholder scan** — no "TBD"/"add validation later" language; every task lists concrete model fields, concrete widgets to port with named source files, and concrete manual-verification steps in place of automated tests (justified in §0 — matches this codebase's established UI-testing convention rather than inventing a heavier one for this plan alone).

**Type consistency** — `ClientSummary.id` (Task 3) is the same `clientId` string threaded through every repository method in Tasks 4–18; `AiMood` reuses the exact 3-value enum from `astra-frontend`; severity coloring (`rmSeverityOk/Warning/Critical`, §3) is the single vocabulary used by `AlertRow` (Task 4), `AnomaliesTab` (Task 10), and `CategoryBudget.status` (Task 12) rather than three separate ad hoc color schemes.
