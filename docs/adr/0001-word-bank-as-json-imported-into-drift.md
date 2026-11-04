# ADR 0001 — Word bank ships as versioned JSON, imported into the app's Drift database

**Date:** 2026-11-04 · **Status:** accepted

## Context

docs/SPEC.md says the word bank ships as "a bundled SQLite database" built by a content pipeline, and that progress is stored locally. Two SQLite files (a read-only bank attached to a writable progress DB) means managing two schemas, copying an asset DB to a writable path, and cross-database joins for "words the profile has not seen yet".

## Decision

- `content_pipeline/build_word_bank.dart` builds `assets/word_bank/word_bank.json` from `content_pipeline/source/words.psv` (+ `version.txt`, `blocklist.txt`). It validates every row and fails on errors or blocked words.
- On startup the app imports the JSON into the single Drift database when the bundled `version` is newer than the imported one (`WordBankImporter`).
- Import is upsert-only. Words dropped from a newer bank stay, and `word_progress` has no foreign key to `words`, so a child's progress is never orphaned or deleted by a content update.
- A test fails when the asset is out of date with the source.

## Consequences

- One database, one schema, simple joins; still fully offline.
- First launch parses ~400 words (fast). At 10,000 words, revisit: import in an isolate or ship a prebuilt SQLite asset.
- Downloadable content packs (SPEC) can reuse the same JSON format and importer.
