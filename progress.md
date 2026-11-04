# Session Progress Log

Append a new dated entry at the top of **Log** each session. Keep **Current State** accurate.

## Current State

**Last Updated:** 2026-11-04
**Active Feature:** none — next up feat-003 (Session builder) or feat-004 (Local database)
**Branch:** main

### What's Done

- [x] Project skeleton written by hand: `pubspec.yaml`, `analysis_options.yaml`, `lib/` (feature-first), `test/widget_test.dart`
- [x] Spec moved to `docs/SPEC.md`
- [x] Agent harness from harness-creator: `AGENTS.md` (+ `CLAUDE.md` import), `feature_list.json`, `progress.md`, `session-handoff.md`, `init.sh`; skill vendored at `.claude/skills/harness-creator`
- [x] Flutter 3.47.9 (Dart 3.13.7) installed via `brew install --cask flutter`; `flutter create` generated `android/` + `ios/`
- [x] Android: Android Studio + SDK installed; cmdline-tools added at `~/Library/Android/sdk/cmdline-tools/latest`; debug APK built and app boots on emulator `Medium_Phone_API_37.0` (API 37)
- [x] iOS: Xcode 27.2 + CocoaPods 1.17.0; app boots on iPhone 18 Pro simulator (iOS 27.2) → feat-001 done
- [x] feat-002: SM-2 scheduler in `lib/core/srs/` (`Sm2Scheduler`, `WordSchedule`, `resolveAnswer`), 25 tests green

### What's In Progress

- (none)

### What's Next

1. ~~First git commit~~ done
2. feat-003 (Session builder, test-first) — depends on feat-002 only
3. feat-004 (Drift DB + word bank) — can run independently

## Blockers / Risks

- [ ] System Java is 1.8; sdkmanager needs `JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` (Flutter/Gradle already use Android Studio's JDK).
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

## Evidence of Completion

- [x] `./init.sh` — 2026-11-04: pub get OK, format 0 changed, analyze no issues, 1/1 test passed

## Log

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
