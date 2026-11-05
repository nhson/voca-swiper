# Session Progress Log

Append a new dated entry at the top of **Log** each session. Keep **Current State** accurate.

## Current State

**Last Updated:** 2026-11-05
**Active Feature:** feat-008 (progress screen); owner asked to build all remaining features, pushing after each
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
- [x] feat-007: daily reminder — planned a week ahead, re-planned on changes; parent Reminders screen
- [x] feat-010: kid-friendly visual design (owner accepted 2026-11-05)
- [x] feat-006: swipe flashcard session (`lib/features/session/`), device TTS, session summary with stars; progress saved per answer

### What's In Progress

- feat-008 progress screen

### What's Next

1. ~~First git commit~~ done
2. Owner decides how to proceed: feat-010 (visual design pass, recommended next so feat-008 is built in the new style), feat-007 (daily reminder) or feat-008 (progress screen)

## Blockers / Risks

- [ ] Repo is public at https://github.com/nhson/voca-swiper — confirm word-list licensing before wider sharing.

- [ ] Vietnamese translations in `content_pipeline/source/words.psv` are drafts — owner/native speaker review needed.
- [ ] Review backlog: reviews are uncapped, so a child back after a long break could face a very long session. Revisit with a review cap once real usage data exists.
- [ ] System Java is 1.8; sdkmanager needs `JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` (Flutter/Gradle already use Android Studio's JDK).
- [ ] Daily reminder not yet seen firing on a real Android device (APK builds; emulator unhealthy).
- [ ] Android emulator `Medium_Phone_API_37.0` hangs on a systemui "Updating..." screen after reinstalls and adb stops responding; feat-006 device check was done on iOS simulators instead. A cold boot / wipe of the AVD may be needed.
- [ ] Word-list licensing (Cambridge YLE, Oxford 3000) unconfirmed — fine for family use, check before store release.

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

## Evidence of Completion

- [x] `./init.sh` — 2026-11-04: pub get OK, format 0 changed, analyze no issues, 1/1 test passed

## Log

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
