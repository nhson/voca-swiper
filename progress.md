# Session Progress Log

Append a new dated entry at the top of **Log** each session. Keep **Current State** accurate.

## Current State

**Last Updated:** 2026-11-05
**Active Feature:** none — all buildable Phase 1 features done. Next is feat-009, the owner-run 2-week trial (human gate)
**Branch:** main

### What's Done

- [x] Project skeleton written by hand: `pubspec.yaml`, `analysis_options.yaml`, `lib/` (feature-first), `test/widget_test.dart`
- [x] Spec moved to `docs/SPEC.md`
- [x] Agent harness from harness-creator: `AGENTS.md` (+ `CLAUDE.md` import), `feature_list.json`, `progress.md`, `session-handoff.md`, `init.sh`; skill vendored at `.claude/skills/harness-creator`
- [x] Flutter 3.47.9 (Dart 3.13.7) installed via `brew install --cask flutter`; `flutter create` generated `android/` + `ios/`
- [x] Android: Android Studio + SDK installed; cmdline-tools added at `~/Library/Android/sdk/cmdline-tools/latest`; debug APK built and app boots on emulator `Medium_Phone_API_37.0` (API 37)
- [x] iOS: Xcode 27.2 + CocoaPods 1.17.0; app boots on iPhone 18 Pro simulator (iOS 27.2) → feat-001 done
- [x] feat-002: SM-2 scheduler in `lib/core/srs/` (`Sm2Scheduler`, `WordSchedule`, `resolveAnswer`), 25 tests green
- [x] feat-003: session builder in `lib/core/session/` (`SessionBuilder`, immutable `StudySession`, `SessionCard`), 43 tests green
- [x] feat-004: Drift DB (`lib/data/db/`), repositories, `WordBankImporter`; content pipeline builds `assets/word_bank/word_bank.json` (392 Pre-A1 + A1 words, emoji pictures, draft Vietnamese); loads on device
- [x] feat-005: first-run PIN setup, PIN gate (locks on exit), parent area, profile create/edit/delete/reset, profile picker, child home stub, go_router routes
- [x] feat-008: progress screen ("My words") per profile, from child home and parent area
- [x] feat-007: daily reminder — planned a week ahead, re-planned on changes; parent Reminders screen
- [x] feat-010: kid-friendly visual design (owner accepted 2026-11-05)
- [x] feat-006: swipe flashcard session (`lib/features/session/`), device TTS, session summary with stars; progress saved per answer

### What's In Progress

- (none)

### What's Next

1. Owner runs feat-009: the child uses the app 5 days a week for 2 weeks without being pushed (install on a real phone/tablet; turn on the daily reminder). Only the owner can mark it done.
2. Before/while trialling: native-speaker review of the Vietnamese drafts (owner, alongside the trial).
3. Trial note: at 10 min/day the cap slows new words to ~3/day after week 3 (reviews take the room). If the child wants more new words, raise "Minutes per day" to 15.
4. Phase 2 planned (feat-012..020, 2026-11-05); suggested order: 012 quiz → 013 retention → 014 content → 015 placement → 016 level progression → 017 dashboard → 018 custom lists → 019 weekly recap → 020 gate. Trial feedback may reorder.

## Blockers / Risks

- [x] Repo is public at https://github.com/nhson/voca-swiper; owner confirmed word-list licensing 2026-11-05.

- [ ] Vietnamese translations in `content_pipeline/source/words.psv` are drafts — owner/native speaker review needed.
- [x] Review backlog — fixed by feat-011 (session budget, 2026-11-05). Original finding: simulation with the real scheduler (5 new/day, 80% knew) — daily use grows to ~40 cards/session by week 3; 5 days/week gives Monday spikes of ~50; a 10-day break → ~100 cards; a 3-week holiday → ~200. `dailyMinutes` is stored but not enforced.
- [ ] System Java is 1.8; sdkmanager needs `JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` (Flutter/Gradle already use Android Studio's JDK).
- [x] Daily reminder seen firing on the Android emulator (2026-11-05, 80s late — inexact alarm). Still worth a glance on a real phone during the trial.
- [x] Android emulator `Medium_Phone_API_37.0` hung on a systemui "Updating..." screen; fixed 2026-11-05 by killing it and cold-booting with `-wipe-data -no-snapshot`.
- [x] Word-list licensing: owner confirmed on 2026-11-05 (words are written in-house from topic areas; no list copied).

## Decisions Made

- **SM-2 details not fixed by SPEC** (feat-002):
  - "Knew it" leaves ease unchanged (SPEC only says misses lower it).
  - "Almost": a pass; interval = max(1, round(knew-interval × 0.6)); ease −0.15.
  - Miss (didn't know / quiz wrong): repetitions → 0, Learning, 1 day, ease −0.2.
  - Ease floor 1.3 (SM-2 standard); ease rounded to 2 decimals.
  - State after a pass: Mastered if interval ≥ 21d, else Review if repetitions ≥ 2, else Learning.
  - Same-session re-queue of misses belongs to the session builder (feat-003), not the scheduler.
  - Times are UTC; callers pass `now`.

- **Session rules not fixed by SPEC** (feat-003):
  - A missed word is re-queued at the end at most once per session (no loops for a struggling child).
  - Only the first answer per word in a session goes to the scheduler; the retry is practice.
  - Daily new-word goal is per day across sessions (`newIntroducedToday`).
  - Due reviews are not capped.

- **Content for MVP** (feat-004, owner delegated): 392-word starter bank written in-house from Starters/Movers topic areas (not copied lists); pictures are system emoji (no licensing, no assets); Vietnamese translations are drafts to review. Bank format: ADR 0001.
- **New-word order**: current level first, then lower levels, teaching order (rank) within a level; words above the child's age excluded.
- **Defaults**: daily new words 5, daily minutes 10, level by age (4–6 Pre-A1, 7+ A1 — capped at A1 until more content), quiet hours 21:00–07:00, school hours Mon–Fri 07:30–16:30 blocked.

- **feat-005 details**: PIN hashing runs in `Isolate.run` (10k SHA-256 rounds froze the UI for seconds in debug builds); widget tests inject `runInline`. Dart SDK constraint raised to ^3.9 (wildcard `_` params; newer formatter style). Parent-area links to Reminders and Progress are hidden until feat-007 / feat-008 add those screens.
- **feat-006 details**:
  - Own swipe card widget (drag + fling, rotation, hint label) instead of a package — small and keeps the buttons and swipes on one animation.
  - Swipe up = Almost; right = Knew it unless the parent flips it. On-screen buttons (Not yet / Almost / Knew it) follow the same left-to-right order.
  - Each first answer is saved straight away, so quitting mid-session keeps progress; the session log is written once, at the end or on quit (none if nothing was answered).
  - Stars: ≥80% → 3, ≥50% → 2, otherwise 1 (never 0 for trying). Almost counts as correct.
  - Word is spoken when each card appears (flutter_tts, en-US, rate 0.4); TTS failures are ignored.
  - Device checks run as `integration_test` + `flutter drive` with screenshots (`integration_test/session_on_device_test.dart`).
- **feat-010 details**:
  - Everything visual is drawn in code or bundled with a known license (`assets/LICENSES.md`); no network fonts (google_fonts would fetch at runtime).
  - Tablets: `KidScale` lays the child screen out at a phone-like size and scales it up, rather than a second layout.
  - Looping idle motion (clouds, mascot bob/blink) is off in widget tests via `ambientMotionProvider` and off when the OS asks for reduced motion; one-shot flourishes (confetti, star pop, card entrance) also respect reduced motion.
  - Sounds mix with other audio (no audio focus) so they never cut off the spoken word.
  - Parent area only picks up the new fonts/theme; kept calm on purpose.
- **feat-007 details**:
  - A local notification can't query the DB when it fires, so `ReminderPlanner` (pure Dart, `lib/core/reminders/`) plans 7 days ahead, assuming no study in between; `ReminderService` re-plans after anything that changes due dates or settings, so studying cancels the nudge.
  - Android uses inexact alarms (`inexactAllowWhileIdle`): no exact-alarm permission; a few minutes late is fine for a daily nudge. Boot receiver re-arms after reboot. Core-library desugaring enabled (plugin requirement).
  - Permission is asked only when a parent turns reminders on; if denied the parent is told to enable it in Settings.
  - Scheduled as absolute UTC instants (local wall time resolved by the planner), so no timezone database/`flutter_timezone` is needed.
  - Weekly "word of the week" recap and resurfacing mastered words (SPEC) are not in feat-007's done-when; noted for later.
- **feat-008 details**: `ProgressStats` (pure Dart, `lib/core/progress/`) computes the numbers from WordProgress states and SessionLogs; accuracy is Σ(accuracy × answers) / Σanswers so long sessions weigh more; daily minutes round to the nearest minute with any practice shown as ≥ 1, and the weekly total is the sum of the bars so the two always agree.

## Evidence of Completion

- [x] `./init.sh` — 2026-11-04: pub get OK, format 0 changed, analyze no issues, 1/1 test passed

## Log

### 2026-11-05 — feat-011 Session budget

- Owner chose option A. Each session is capped by the profile's minutes per day (10 min ≈ 25 cards); the most overdue reviews go first, the rest wait; new words only fill the room left, so they pause on catch-up days.
- Simulated 8 weeks of daily use at 10 min: never over 25 cards, 171 new words (vs 280 uncapped, at ~60-card sessions). After a 3-week break: 7 review-only days, then new words resume.
- Parent form explains it under "Minutes per day". `./init.sh` green, 148/148. Device check on iPhone + iPad simulators.

### 2026-11-05 — Phase 2 plan, emulator fixed

- Owner confirmed word-list licensing; will run the feat-009 trial and the Vietnamese review in parallel.
- Simulated review load with the real SM-2 + session builder: backlog grows quickly (see Risks) → feat-011 proposed, owner to decide.
- Phase 2 planned as feat-012..020 in `feature_list.json`; noted that the bank has 392 of the ~1,000 Pre-A1/A1 words the SPEC targets (top-up folded into feat-014).
- Android emulator recovered with a wiped cold boot; reminder device test made Android-aware (adb-granted permission, inexact alarm wait).
- Android device runs: reminder delivered (80s after the planned time); full session test passed with screenshots.
- Bug found on Android and fixed: audioplayers' position updater asked for a new frame on every frame after a sound effect (low-latency mode never reports the end), so the app redrew forever — a battery drain on every platform. Fixed with `positionUpdater = null` in `lib/ui/sfx.dart`. `./init.sh` green, 136/136.

### 2026-11-05 — feat-008 Progress screen

- `ProgressStats` (pure Dart, test-first), repository query for session stats, kid-styled "My words" screen; entry from the child home and a per-profile button in the parent area.
- `./init.sh` green, 136/136. Device run on iPhone + iPad simulators passed. All buildable Phase 1 features are done; feat-009 is the owner's trial.

### 2026-11-05 — feat-007 Daily reminder

- Added flutter_local_notifications 22.3.3 + timezone 0.11.2. Planner (pure Dart, test-first), notifier, service, refresher (start/resume), parent Reminders screen with next-reminder preview. Parent screens now keep a readable width on tablets.
- `./init.sh` green, 126/126. On iPhone + iPad simulators the scheduled reminder was really delivered by iOS; nothing scheduled when no reviews are due. Android APK builds.

### 2026-11-05 — feat-010 Kid-friendly visual design (owner accepted)

- Added audioplayers 6.8.1; bundled Baloo 2 + Nunito (OFL); synthesized 6 sound effects. New `lib/ui/` kit; profile picker, child home, session and summary redesigned; age-banded looks; tablet scaling; parent "Sound effects" toggle (AppMeta).
- Device screenshots drove three fixes: greeting text lost against clouds, sun behind top-bar controls, bubble text wrapping.
- `./init.sh` green, 110/110. On-device run passed on iPhone 18 Pro and iPad Pro 13 simulators.

### 2026-11-05 — Plan: UI/UX enhancement

- Owner: UI is too plain and not attractive. Added feat-010 (kid-friendly visual design + delight pass) to Phase 1, before the feat-009 gate, which now depends on it. Rationale and scope in SPEC Decisions ("UI/UX polish timing").

### 2026-11-05 — feat-006 Swipe flashcard session

- Added flutter_tts 4.2.5 and integration_test. Session controller, swipe card, flash card, session screen, summary; child home shows today's count.
- Widget tests caught a swipe card that kept its off-screen offset for the next card (fixed). On-device test first hung closing the DB under live queries (same cause as the earlier slow tests) — now unmounts first.
- Device screenshots showed the card stretched into a tall strip on the iPad: the card now keeps a 0.72 aspect ratio, back content is centred, the swipe hint sits mid-card.
- `./init.sh` green, 99/99 (format check now also covers `integration_test/` and `test_driver/`). On-device session passed on iPhone 18 Pro and iPad Pro 13 simulators.

### 2026-11-04 — feat-005 Parent account + child profiles

- Screens: setup, PIN gate, parent area, profile form, change PIN, profile picker, child home stub. Widget tests found two real bugs (setup replaced the nav stack so saving the first profile popped the last page; locking from a pop callback modified a provider mid-build) — both fixed.
- Device walkthrough on Android emulator passed. `./init.sh` green, 78/78.
- Owner asked to stop after this task and wait for a decision.

### 2026-11-04 — feat-004 Local database + word bank

- Added flutter_riverpod 3.4, go_router 18.1, drift 2.35 (+drift_flutter, drift_dev, build_runner), path_provider, crypto.
- Content pipeline + 392-word bank, Drift schema, repositories, importer, PIN hasher. `./init.sh` green, 74/74. Verified on Android emulator.

### 2026-11-04 — feat-003 Session builder

- Tests first (red), then `session_builder.dart` + `study_session.dart`. `./init.sh` green, 43/43 tests.

### 2026-11-04 — feat-002 SM-2 scheduler

- Tests written first (red: missing files), then `word_schedule.dart` + `sm2_scheduler.dart`. `./init.sh` green, 25/25 tests.
- Added `core_purity_test.dart` to enforce the pure-Dart rule for `lib/core`.

### 2026-11-04 — Android licenses

- Owner approved; all Android SDK licenses accepted. `flutter doctor`: no issues found.

### 2026-11-04 — iOS toolchain, feat-001 done

- Installed CocoaPods via Homebrew. `flutter build ios --simulator --debug` OK; app boots on iPhone 18 Pro simulator. `flutter doctor`: all green except Android licenses.

### 2026-11-04 — Android toolchain

- Installed Android cmdline-tools (checksum verified). `flutter build apk --debug` OK (Gradle pulled NDK r28c + SDK Platform 36); app installed and boots to home screen on API 37 emulator.

### 2026-11-04 — Flutter install

- Installed Flutter 3.47.9 via Homebrew, ran `flutter create --org com.vocaswiper --platforms=android,ios --project-name voca_swiper .` (existing lib/, test/, pubspec kept).
- Bumped flutter_lints to ^6.0.0. `./init.sh` green.

### 2026-11-04 — Scaffold + harness

- Scaffolded Flutter project structure by hand (SDK unavailable) and applied harness-creator templates.
- feature_list.json seeded with Phase 1 MVP features from docs/SPEC.md.
