# voca-swiper — agent harness

Kids English vocabulary app (Flutter · Dart · Riverpod · Drift/SQLite · go_router). Android + iOS, phones and tablets, offline-first. Current target: Phase 1 MVP from `docs/SPEC.md`.

## Startup Workflow

Before writing code:

1. **Confirm working directory** with `pwd`
2. **Read this file** completely
3. **Read project docs**: `docs/SPEC.md` (product + technical spec, MVP scope, decisions), `docs/adr/`
4. **Run `./init.sh`** — pub get, format check, analyze, test. If the baseline fails, fix that first before adding new scope.
5. **Read `feature_list.json`** and **`progress.md`** (and `session-handoff.md` if present) to find the active feature
6. **Review recent commits** with `git log --oneline -5`

## Working Rules

- **One feature at a time**: work only on the `in-progress` feature in `feature_list.json`; respect `dependencies`
- **Stay in scope**: Phase 1 only. Games, placement test, speaking, AI and cloud sync are later phases — note ideas in `progress.md` instead
- **Domain is pure Dart and test-first**: `lib/core/` imports nothing from Flutter, `lib/data/` or `lib/features/`; write the test before the code
- **Feature-first layout**: `lib/features/<feature>/` holds UI + Riverpod providers; repositories live in `lib/data/`
- **Word content is shared and read-only**; all progress is per profile (`WordProgress` = profile × word)
- **Kid-safe by default**: no ads, trackers, network calls or analytics; child profiles store only nickname, age and progress
- **Packages**: check the current version on pub.dev before adding one; add it only in the feature that needs it
- **Human gates**: the Phase 1 gate (child uses it 5 days/week for 2 weeks) needs owner confirmation — never mark it done yourself
- **Record decisions**: product decisions go in the SPEC "Decisions" table; architectural ones get an ADR in `docs/adr/`

## Required Artifacts

- `feature_list.json` — feature state tracker (source of truth; schema in `feature_list.schema.json`)
- `progress.md` — current state + dated session log
- `init.sh` — standard startup and verification path
- `session-handoff.md` — next-session pickup notes when work is mid-flight

## Definition of Done

A feature is done only when ALL of the following are true:

- [ ] The feature's "Done when" in `feature_list.json` is demonstrably met
- [ ] `./init.sh` passes (format, analyze, tests)
- [ ] UI changes checked on a simulator/emulator (phone and tablet size)
- [ ] Evidence (command and result) recorded in `feature_list.json` `evidence`
- [ ] Repository remains restartable from `./init.sh`

## End of Session

Before ending a session:

1. Update `progress.md` (Current State + new Log entry)
2. Update `feature_list.json` status/evidence
3. Record unresolved risks or blockers; overwrite `session-handoff.md` if work is mid-flight
4. Commit with a descriptive message once the work is in a safe state
5. Leave the repo clean so the next session can run `./init.sh` immediately

## Verification Commands

```bash
./init.sh                                              # full gate
flutter pub get
dart format --output=none --set-exit-if-changed lib test content_pipeline integration_test test_driver
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after Drift is added
```

Harness audit: `node .claude/skills/harness-creator/scripts/validate-harness.mjs --target .`

## Escalation

- **Architecture decisions**: check `docs/SPEC.md` "Technical architecture" and `docs/adr/`, otherwise ask the owner
- **Unclear requirements**: check `docs/SPEC.md`, otherwise ask the owner
- **Content licensing**: never bundle a word list, image set or dataset whose license is unconfirmed — flag it
- **Repeated test failures**: record in `progress.md`, flag for human review
