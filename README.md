# Voca Swiper

Kids English vocabulary app (Flutter, Android + iOS): swipeable flashcards, SM-2 spaced repetition, multiple child profiles, offline-first. Product and technical spec: [`docs/SPEC.md`](docs/SPEC.md).

## Getting started

```bash
# one-time: install the Flutter SDK, then generate platform folders
flutter create --org com.vocaswiper --platforms=android,ios .
./init.sh          # pub get, format check, analyze, test
flutter run
```

## Layout

```
lib/
  app/              root widget, routing, theme
  core/srs/         pure-Dart SM-2 scheduler, session builder (unit-tested)
  data/             Drift (SQLite) database + repositories
  features/         profiles, session, parent, progress (UI + Riverpod providers)
content_pipeline/   script that builds the bundled word-bank SQLite file
assets/             bundled db, images
docs/               SPEC.md, adr/
```

Agent workflow: see [`AGENTS.md`](AGENTS.md), `feature_list.json`, `progress.md`.
