# Session Progress Log

Append a new dated entry at the top of **Log** each session. Keep **Current State** accurate.

## Current State

**Last Updated:** 2026-11-05
**Active Feature:** feat-019 weekly recap (owner granted a batch run 2026-11-05 for feat-017..019). feat-009 (owner trial) runs alongside
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
- [x] feat-014: word bank v2 — 1,497 words (Pre-A1 364, A1 611, A2 255, B1 267), grammar forms, all four levels selectable, translation fades by level
- [x] feat-015: placement test + favourite themes — word check on first open (24 words, staircase, picture/meaning checks against guessing), up to 3 favourite topics preferred for new words, first 5-word mini-session; parent can start now / later / skip, redo; DB schema v3
- [x] feat-018: custom word lists — per child, matched to the bank or parent's own (meaning, Vietnamese, emoji), first among new words; DB schema v5
- [x] feat-017: parent dashboard — level + override, last-7-days vs goal, retention, 8-week trend, struggling words
- [x] feat-016: level progression — level-up at 80% mastered with a celebration, every 5th new word a next-level preview, step-back suggestion for the parent (<50% right over a week), "Keep this level" lock; DB schema v4
- [x] feat-006: swipe flashcard session (`lib/features/session/`), device TTS, session summary with stars; progress saved per answer

### What's In Progress

- (none)

### What's Next

1. Owner runs feat-009: the child uses the app 5 days a week for 2 weeks without being pushed (install on a real phone/tablet; turn on the daily reminder). Only the owner can mark it done.
2. Before/while trialling: native-speaker review of the Vietnamese drafts (owner, alongside the trial).
3. Trial note: at 10 min/day the cap slows new words to ~3/day after week 3 (reviews take the room). If the child wants more new words, raise "Minutes per day" to 15.
4. Phase 2 started 2026-11-05; feat-012–018 done. Next: 019 level progression → 017 dashboard → 018 custom lists → 019 weekly recap → 020 gate. Trial feedback may reorder.

## Blockers / Risks

- [x] Repo is public at https://github.com/nhson/voca-swiper; owner confirmed word-list licensing 2026-11-05.

- [ ] Vietnamese translations in `content_pipeline/source/words/*.psv` are drafts — owner/native speaker review needed (1,497 words; 1,105 new in feat-014).
- [ ] Six v1 pictures are newer emoji that may show as boxes on Android 10 and older: pink 🩷, grey 🩶, window 🪟, doll 🪆, rock 🪨, brush 🪥 (A2/B1 are guarded by a test; Pre-A1/A1 left as shipped).
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
- **Defaults**: daily new words 5, daily minutes 10, level by age (4–6 Pre-A1, 7–9 A1, 10–12 A2, 13+ B1 — all four selectable since feat-014), quiet hours 21:00–07:00, school hours Mon–Fri 07:30–16:30 blocked.

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

### 2026-11-05 — feat-018 custom word lists

- `lib/core/custom_words.dart` (ids, normalising, validation); `CustomWords` table (schema v5) + `CustomWordRepository`; `WordRepository.cards` builds cards for `custom:<n>` ids.
- Session loader puts unseen custom words first among new words.
- Parent UI: "Word list" in the child's edit form → list (remove with confirm) → add/edit form with live bank match.
- Device test first failed because "dinosaur" is in the real bank (the match card showed, as designed); switched to "triceratops".

### 2026-11-05 — feat-017 parent dashboard

- Owner: "go with yolo mode … pick any task" — running feat-017..019 without stopping (feat-020 stays an owner gate).
- `lib/core/progress/dashboard.dart` (struggling, weekly trend, goal) test-first; `lib/features/parent/dashboard_screen.dart` at `/parent/profiles/:id/dashboard`, opened from the progress icon in the parent area.
- Widget tests check the numbers against seeded data on phone and tablet sizes; device check on iPhone + iPad simulators.

### 2026-11-05 — feat-016 level progression

- Domain: `lib/core/progress/level_progression.dart` (level-up, preview mix, step-back suggestion), test-first.
- Data: schema v4 adds `levelLocked`, `levelChangedAt`, `stepBackDismissedAt`; `levelCounts`, `masteredAt`, exact-level candidates; `changeLevel` / `dismissStepBack`; form saves date real level changes.
- `lib/features/levels/level_service.dart` applies the rules; session loader mixes preview words; session end checks level-up → "Level up!" banner on the summary. Parent area: step-back card per child (Step back / Not now). Profile form: "Keep this level".
- Caught by the new v3→v4 migration test: the v4 `onUpgrade` step had silently not been written (formatter reflowed the anchor line). Fixed before commit.
- Device check on iPhone + iPad simulators (`integration_test/level_progression_on_device_test.dart`); fixed the suggestion card's buttons overflowing on phones.
- Note for the trial: an A1 level has ~600 words, so a real level-up is months away at 5 new words/day; the preview words show up from the next session.

### 2026-11-05 — feat-015 placement test + favourite themes

- Domain: `lib/core/placement/placement.dart` (`PlacementTest`, `PlacementResult`) and `lib/core/themes.dart` (curated topics, `themeChoices`), test-first.
- Data: schema v3 adds `profiles.interests` and `profiles.onboardedAt`; upgrade marks existing children as placed so the trial child is not sent through it. `newWordCandidates` puts favourite-topic words first within a level.
- UI: `lib/features/placement/` (intro → word check → picture/meaning checks via `QuizView` → topic picker → first 5-word session). Kid home starts the word check when not placed. Profile form: post-create dialog (hand over now / later / skip), favourite topics chips and skip/redo in edit.
- Topic picker keeps a kid-appeal order instead of biggest-first (Sports was cut off by Food/Home/School on device). 👪 swapped for ❤️ (renders as a framed silhouette on iOS).
- Older device tests now mark their children placed. Device check on iPhone + iPad simulators (`integration_test/placement_on_device_test.dart`).
- Trial note: a new profile made during the trial will now get the word check; the existing child will not.

### 2026-11-05 — feat-014 word bank v2

- Source split per level (`content_pipeline/source/words/01-preA1..04-B1.psv`); Pre-A1/A1 topped up 392 → 975; new A2 (255) and B1 (267), ages 7+, with grammar forms; bank version 2 (1,497 words).
- `shipped_ids.txt` + test: v1 ids can never be renamed by a new part of speech. New-POS and form-name validation; blocklist extended and documented.
- Profile form offers Pre-A1/A1/A2/B1; default by age up to B1; translation default fades (A2/B1 = tap).
- Upgrade test: v1 → v2 import keeps schedules, first-seen and quiz log.
- Device check on iPhone + iPad simulators (`integration_test/levels_on_device_test.dart`). Card grammar-forms line now centred.
- Skipped: syllables/stress. Owner: review the Vietnamese drafts.

### 2026-11-05 — feat-013 Retention tracking

- Every quiz answer is logged (new QuizLogs table, DB schema v2 with an upgrade step). "Remembered after 2 weeks" (quiz accuracy on words learned 14+ days earlier) is computed in pure Dart and shown on each child's progress screen.
- Upgrade checked on the Android emulator: the Phase 1 app with a PIN and a child, then the new APK over it — data kept, old 4-digit PIN works.
- `./init.sh` green, 195/195. The metric needs 2+ weeks of real use before it shows a number.

### 2026-11-05 — APK on Google Drive

- `tool/upload_apk.sh` uploads the release APK to the owner's Drive (folder "voca-swiper", file `voca-swiper.apk`); re-running replaces the content so the link stays the same. Needs a one-time `gcloud auth login --enable-gdrive-access`. Uploaded build with feat-012; checksum matches.

### 2026-11-05 — feat-012 Quiz round (Phase 2 started)

- Owner started Phase 2. After the swipe cards, a quiz of up to 5 questions on words swiped knew/almost: ages 4–6 hear-and-pick-the-picture; 7+ rotate picture / meaning / letter-tile spelling. A wrong quiz answer reschedules the word as a miss; summary shows the quiz score.
- `./init.sh` green, 180/180. Device run on iPhone + iPad simulators with the real bank; screenshots checked (made the right/wrong marks bolder after the first look).
- Note: distractor pictures come from the whole age/level pool (numbers, people, animals mixed) — easy for young children; feat-015 themes could make them same-theme later.

### 2026-11-05 — 6-box PIN entry (owner request)

- Setup, unlock and change PIN now use six separate boxes (`lib/ui/pin_boxes.dart`): one hidden number field underneath, boxes draw dots. New/changed PINs are exactly 6 digits; the gate unlocks on the 6th digit; a PIN made earlier with 4–5 digits still unlocks via the Unlock button. "Wrong PIN" clears when typing resumes.
- `./init.sh` green, 154/154. Device check on iPhone + iPad simulators (`integration_test/pin_on_device_test.dart`).

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
