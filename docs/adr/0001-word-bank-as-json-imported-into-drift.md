# ADR 0001 — Word bank ships as versioned JSON, imported into the app's Drift database

**Date:** 2026-11-04 · **Status:** accepted

## Context

docs/SPEC.md says the word bank ships as "a bundled SQLite database" built by a content pipeline, and that progress is stored locally. Two SQLite files (a read-only bank attached to a writable progress DB) means managing two schemas, copying an asset DB to a writable path, and cross-database joins for "words the profile has not seen yet".

## Decision

- `content_pipeline/build_word_bank.dart` builds `assets/word_bank/word_bank.json` from `content_pipeline/source/words/*.psv`, one file per level read in name order (`01-preA1`, `02-A1`, `03-A2`, `04-B1`; changed in feat-014), plus `version.txt` and `blocklist.txt`. The blocklist is checked against each word's text, definition and example. It validates every row and fails on errors or blocked words.
- On startup the app imports the JSON into the single Drift database when the bundled `version` is newer than the imported one (`WordBankImporter`).
- Import is upsert-only. Words dropped from a newer bank stay, and `word_progress` has no foreign key to `words`, so a child's progress is never orphaned or deleted by a content update.
- A test fails when the asset is out of date with the source.
- Word ids are slugs; a text with two parts of speech gets `slug-pos` ids. Adding the second part of speech would rename a shipped id, so `shipped_ids.txt` lists the v1 ids and a test fails if any of them changes or disappears (feat-014).
- Content is written in-house from topic areas, not copied from a published list. Vietnamese translations are drafts until reviewed.

## Consequences

- One database, one schema, simple joins; still fully offline.
- First launch parses ~1,500 words (v2, feat-014; fast). At 10,000 words, revisit: import in an isolate or ship a prebuilt SQLite asset.
- Downloadable content packs (SPEC) can reuse the same JSON format and importer.
