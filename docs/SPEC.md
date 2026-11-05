# Kids English Vocabulary App — Product & Technical Spec

Nov 3, 2026 · @Son Ng

## Overview

A Flutter app for Android and iOS phones and tablets that helps children learn English as a second language through swipeable flashcards, spaced-repetition reminders and short games, with a separate learning profile for each child.

**Target learners:** children aged roughly 4 to 15 whose first language is not English. Parents set up and supervise the profiles.

**Goals**

- Build a solid core vocabulary, starting from the most common and most useful English words for each age.
- Make daily practice short (5 to 15 minutes) and fun enough that the child returns on their own.
- Give parents a clear view of progress and control over content and screen time.

**Design principles**

- Content is matched to the child's level, not only their age.
- Every word has a picture and native audio, so young children can learn before they can read well.
- The native language supports early learning, then fades out.
- Kid-safe by default: no ads, no open chat, minimal data collection.
- Works offline.

## Learner profiles

One parent account holds several child profiles, and each profile has its own word list, progress and settings.

**Age and level are separate settings.** Age controls visuals, tone and content safety. Level (CEFR Pre-A1 to B2) controls which words appear. A 10-year-old beginner gets A1 words with age-appropriate design, not toddler content.

| Setting | Purpose | Set by |
| --- | --- | --- |
| Name and avatar | Profile picker on the home screen | Parent or child |
| Age | Card style, UI complexity, content filter | Parent |
| Native language | Translations and pronunciation hints | Parent |
| Current level | Which word pool is active | Placement test, then auto or parent override |
| Interests | Themes prioritized within the level | Child |
| Daily goal | New words per day (5 to 15) and minutes per day | Parent |
| Translation visibility | Always shown, tap to show, or hidden | Auto by level, parent override |
| Swipe direction | Which swipe means "knew it" | Parent |

## Core learning loop

Each daily session mixes due reviews with a small batch of new words, shown as swipeable flashcards with active-recall checks.

**Card gestures**

| Gesture | Meaning | Effect |
| --- | --- | --- |
| Swipe right | Knew the word | Word moves forward in the review schedule |
| Swipe left | Didn't know the word | Word returns later in the same session and soon after |
| Swipe up (optional) | Almost knew it | Shorter review interval than "knew it" |
| Tap | Flip the card | Shows meaning, picture, audio, example and translation |

Swipe right means "knew it", matching popular apps. Parents can flip it in settings.

**Session flow**

1. Due reviews first, oldest first.
2. New words next, up to the profile's daily goal (default 5 to 10).
3. Words marked "didn't know" come back at the end of the session.
4. A short active-recall round: pick the picture, choose the meaning from four options, or spell the word with letter tiles.
5. A session summary with stars earned and words learned.

**Why active recall:** swiping depends on the child's honesty. Mixed-in quiz cards check real knowledge, and a wrong quiz answer overrides a "knew it" swipe.

## Spaced repetition and reminders

The app schedules each word to return just before the child is likely to forget it, using the SM-2 algorithm at launch and FSRS as a later upgrade.

**Word states:** New → Learning → Review → Mastered. A word moves to Mastered after an interval of 21 days or more; a miss at any stage sends it back to Learning.

**Scheduling inputs per word and profile:** ease factor, current interval, repetition count, last answer quality (knew / almost / didn't know / quiz wrong), next review date.

**Starting intervals (SM-2 style):** 1 day after the first correct answer, 3 days after the second, then the previous interval × ease factor (default 2.5, lowered by misses).

**Knowledge reminders**

- One daily local notification at a time the parent picks, only when reviews are due.
- Friendly wording for kids, such as "5 words are waiting to say hi!"
- No reminders during set quiet hours or school time.
- A weekly "word of the week" recap of words learned.
- Mastered words resurface occasionally so they don't fade.

## Word content

The word bank targets the 10,000 most common English words, curated into age bands and CEFR levels, with unsafe and overly abstract words filtered out.

**Age bands**

| Age band | Typical level | Word source | Focus | Card style |
| --- | --- | --- | --- | --- |
| 4–6 | Pre-A1 | Cambridge Pre A1 Starters list (\~500 words) | Concrete nouns: animals, colors, family, food | Big picture and audio, no reading needed |
| 7–9 | A1 | Cambridge Movers/Flyers lists, Fry first 300 | Everyday verbs, adjectives, school words | Picture, word, short sentence |
| 10–12 | A2–B1 | Oxford 3000 (A1–B1 portion) | Abstract words, phrasal verbs, topics | Word, definition, example, optional translation |
| 13+ | B1–B2 | Oxford 3000/5000, filtered frequency list | Academic words, collocations, idioms | Full card with usage notes |

**Filtering the frequency list**

- Remove profanity, sexual, violent and drug-related words with a blocklist plus manual review.
- Mark sensitive-but-useful words ("die", "war") as 10+ only.
- Drop proper nouns and abbreviations.
- Tag each word with level, part of speech and themes (animals, food, school, sports, space and so on).

**Card fields:** word, part of speech, CEFR level, themes, syllables with stress, IPA, audio, image, simple definition, 1 to 3 example sentences, translation per native language, grammar forms (plural, past tense, comparative), related words.

**Custom lists:** parents can add words from homework or books; the app fills in audio and definitions where it can.

## Onboarding and level progression

A new profile takes about 3 minutes to set up: the parent fills in basics, then the child takes a short placement test that sets the starting level.

**Onboarding steps**

1. Parent creates the profile: name, avatar, age, native language, daily goal.
2. Placement test: 20 to 30 words sampled across levels, starting at the age band's default level. The child taps "know" or "don't know"; every few words a quick picture quiz checks for guessing.
3. The app sets the starting level where the child knows roughly 70% or more of sampled words.
4. The child picks favorite themes.
5. First mini-session with 5 easy words, so the child ends on a win.

**Level progression**

- Move up a level automatically when 80% of the current level's words are mastered. The parent can override.
- Mix a few next-level words into daily batches as a preview.
- If accuracy stays below 50% for a week, suggest stepping back a level to the parent.

## ESL-specific features

Because learners already know most concepts in their native language, the app leans on translation and pictures early, then shifts to English-only meaning and pronunciation practice.

- **Fading translation.** Shown by default at Pre-A1 and A1, behind a tap at A2 and B1, hidden at B2. Parents can override.
- **Pronunciation hints per native language.** Flag sounds that are hard for that language's speakers. For Vietnamese speakers: final consonants (cat, cap, cab), consonant clusters (str, spl) and the "th" sounds.
- **Minimal-pair drills.** Listen and pick: ship / sheep, bat / bad, think / sink.
- **Word stress and syllables.** Show syllable breaks with the stressed one marked, such as ba-NA-na.
- **Speaking practice.** The child says the word aloud and speech recognition gives simple feedback (green / try again).
- **Grammar forms on the card.** Plural, past tense, comparative: child / children, go / went, good / better.
- **Collocations at higher levels.** Teach "make a decision" and "do homework" rather than "make" and "do" alone.
- **Word families.** Group related words (happy, glad, cheerful; teach, teacher) so they stick together.

## Games, stories and motivation

Games reuse words the child is already learning, and rewards favor steady habits over raw points.

**Mini-games**

| Game | Skill practiced | Best for ages |
| --- | --- | --- |
| Matching pairs (word ↔ picture) | Recognition | 4+ |
| Listen and pick | Listening | 4+ |
| Letter tiles spelling | Spelling | 7+ |
| Hangman / word search | Spelling, recognition | 7+ |
| Timed challenge | Fluency | 9+ |
| Fill the gap in a sentence | Usage in context | 10+ |

**AI features (later phase)**

- Story mode: generate a short story using this week's words, highlighted, at the child's level.
- Sentence practice: the child writes a sentence with a new word and gets gentle feedback.
- All AI output passes through a kid-safety filter and stays within the profile's level.

**Motivation**

- Streaks with one "freeze" day per week, so a missed day doesn't reset progress.
- A word garden or pet that grows as words are mastered (ages 4 to 9).
- Theme badges, such as "Animal Expert" for 50 animal words.
- Parent-set rewards, such as "100 words this month = zoo trip".

## Parent features

A PIN-protected parent area lets parents track each child's progress and control content and screen time.

- **Dashboard per profile:** words mastered, words learning, struggling words, accuracy, minutes per day, weekly trend.
- **Custom word lists:** add words from homework or books, or import a list.
- **Level and settings control:** override level, translation visibility, swipe direction, daily goal.
- **Screen-time limits:** daily cap and allowed hours.
- **Reminder time:** pick when the daily notification fires.
- **Weekly summary:** optional email or in-app report.
- **Profile management:** add, edit, reset or delete profiles.

## Data model

Word content is shared and read-only; all progress is stored per profile, so adding a child or a native language never duplicates the word bank.

| Entity | Scope | Key fields |
| --- | --- | --- |
| Word | Shared | id, text, cefrLevel, partOfSpeech, themes\[\], syllables, stressIndex, ipa, audioPath, imagePath, definition, examples\[\], forms{}, minAge |
| Translation | Shared | wordId, languageCode, text |
| PronunciationHint | Shared | languageCode, soundPattern, tip, examples\[\] |
| ParentAccount | Device / cloud | id, pinHash, email (optional), settings |
| Profile | Per child | id, parentId, name, avatar, age, nativeLanguage, currentLevel, interests\[\], dailyNewWords, dailyMinutes, translationMode, swipeKnownDirection |
| WordProgress | Per profile × word | profileId, wordId, state, easeFactor, intervalDays, repetitions, nextReviewAt, lastAnsweredAt, correctCount, wrongCount |
| CustomList | Per profile | id, profileId, name, wordIds\[\] |
| SessionLog | Per profile | id, profileId, startedAt, durationSec, reviewed, newLearned, accuracy |
| Achievement | Per profile | profileId, badgeId, earnedAt |

**Relationships:** a parent has many profiles; a profile has many WordProgress rows, one per word it has seen; a word has many translations, one per language.

## Technical architecture (Flutter)

The app is offline-first: the word bank ships as a bundled SQLite database, progress is stored locally, and optional cloud sync is added later.

**Layers**

1. **UI:** Flutter widgets per feature (profiles, session, games, parent area).
2. **State:** Riverpod providers per feature.
3. **Domain:** pure Dart services, including the SRS scheduler, session builder, placement test and level progression. Fully unit-tested.
4. **Data:** repositories over a local Drift (SQLite) database; a sync adapter added in a later phase.

**Candidate packages** (check current versions on pub.dev before starting)

| Need | Package |
| --- | --- |
| State management | flutter\_riverpod |
| Local database | drift (SQLite) |
| Navigation | go\_router |
| Swipe cards | flutter\_card\_swiper or appinio\_swiper |
| Text-to-speech | flutter\_tts |
| Audio playback | just\_audio |
| Speech recognition | speech\_to\_text |
| Reminders | flutter\_local\_notifications |
| Animations | lottie or rive |
| Cloud sync (later) | Firebase (Auth, Firestore) or Supabase |

**Folder structure:** feature-first, such as `lib/features/session/`, `lib/features/profiles/`, `lib/core/srs/`, `lib/data/`.

**Content pipeline:** a separate script (Python or Dart) builds the word database from source lists, applies filters and tags, attaches audio and images, and outputs a versioned SQLite file. New content versions ship with app updates or as downloadable packs.

## Privacy, safety and data sources

The app collects as little as possible about children, and every content source must have a license that allows use in the app.

**Privacy and safety**

- No ads, no third-party trackers, no open chat or social features.
- Child profiles store only a first name or nickname, age and progress.
- Voice recordings for speaking practice are processed on-device and never stored.
- Parent area behind a PIN or simple math gate.
- Before publishing, review children's privacy rules such as COPPA (US), GDPR-K (EU) and local law, and the App Store and Google Play family-app policies.

**Content sources to evaluate** (licenses stated from memory; confirm each before use)

| Content | Candidate source | License to confirm |
| --- | --- | --- |
| Definitions | Wiktionary, WordNet | CC BY-SA; WordNet license |
| Example sentences | Tatoeba project | CC BY |
| Images | OpenMoji, Twemoji; AI-generated with review as fallback | CC BY-SA, CC BY |
| UI/UX polish timing | Phase 1, before the real-use gate: the gate measures whether the child comes back unprompted, so a plain UI would fail it for the wrong reason. Rewards (streaks, badges, garden) stay in Phase 3 |
| Visual style (feat-010) | Code-drawn "sunny sticker book": sky + hills backdrop, mascot "Sunny" (original, drawn in code), Baloo 2 + Nunito fonts (OFL, bundled, Vietnamese-capable), chunky buttons; ages 4–6 bright "sunny", 7+ cooler "adventure"; tablets scale the phone layout up (×1–1.75) |
| Sound effects | Short tones synthesized in-house (`tool/make_sounds.dart`), mixed with TTS, never a "wrong" buzzer; parent can turn them off |
| Reminder rules (feat-007) | Off until a parent turns it on (default 18:00). Planned a week ahead and re-planned on app start/resume, after each session and on settings changes. Counts only reviews due by that time. School hours (Mon–Fri) move it to when school ends; quiet hours skip that day. One notification for all children ("Bi 3 · An 2") |
| Progress screen (feat-008) | One kid-styled "My words" screen per profile, opened from the child home and from the parent area: Mastered / Growing (Review) / Learning counts, right-answer % weighted by answers (first answers only), minutes per local day for the last 7 days. Fuller parent dashboard (struggling words, trends) stays in Phase 2 |
| Word lists | Cambridge YLE lists, Oxford 3000/5000 | Publisher terms, may restrict redistribution |
| Frequency data | Open subtitle or web-corpus frequency lists | Varies by list |
| Audio | Device TTS for MVP; Edge TTS or another neural TTS later | Own recordings |
| Translations | Wiktionary, then human review per language | CC BY-SA |

## MVP scope and roadmap

The MVP is flashcards with pictures and audio, spaced repetition, multiple profiles and a simple progress screen; games, speaking and AI features come after real use with your own child.

1. **Phase 1 — MVP**
   - Parent account with PIN, multiple child profiles (age, level, native language).
   - Bundled word bank for Pre-A1 and A1 (about 1,000 words) with free icon-set images, device TTS audio and Vietnamese translations; local storage only.
   - Swipe flashcards, tap to flip, daily session builder, SM-2 scheduling.
   - Daily reminder notification.
   - Simple progress screen per profile.
   - Kid-friendly visual design pass: playful palette and type, mascot, celebration animations, tablet scaling (no new reward mechanics).
   - Gate: your child uses it 5 days a week for 2 weeks without being pushed.
2. **Phase 2 — Learning depth**
   - Placement test and automatic level progression.
   - Active-recall cards (picture pick, four-option meaning, letter tiles).
   - A2 to B1 content, fading translation, grammar forms.
   - Parent dashboard and custom word lists.
   - Gate: quiz accuracy shows words are retained after 2 weeks.
3. **Phase 3 — Engagement**
   - Mini-games, streaks with freeze days, badges, word garden.
   - Pronunciation hints, minimal pairs and speaking practice.
4. **Phase 4 — Scale and AI**
   - B2 content and the full 10,000-word bank.
   - AI story mode and sentence feedback.
   - Cloud sync across devices, more native languages.
   - Store release after a privacy and family-policy review.

## Decisions

| Topic | Decision |
| --- | --- |
| Native language at launch | Vietnamese |
| Swipe direction | Right = knew it, left = didn't know (common convention); parent can flip |
| Distribution | Family use first; App Store and Google Play release later |
| Platforms | Android and iOS, phones and tablets |
| Cloud sync | Local only for MVP; sync in Phase 4 |
| Images | Free icon sets (OpenMoji, Twemoji); AI-generated with review where none fits |
| Audio | Device TTS for MVP; Edge TTS or another neural TTS later |
| Word lists | Cambridge YLE and Oxford 3000/5000 for MVP; check their usage terms before store release |
| Review backlog (feat-011, 2026-11-05) | Each session is capped by the profile's minutes per day (~2.5 cards/min, 10 min ≈ 25 cards, at least 5). Most overdue reviews first; the rest wait. New words only fill room the reviews leave, so they pause on catch-up days. Retries after a miss are extra practice, not counted |
| Parent PIN entry (2026-11-05) | Six separate boxes, digits shown as dots; new and changed PINs are exactly 6 digits; the gate unlocks on the 6th digit. PINs made earlier (4–5 digits) still unlock with the Unlock button |
| Quiz round (feat-012, 2026-11-05) | After the swipe cards, up to 5 questions on words swiped "knew it" / "almost" (missed words are already scheduled as misses). Ages 4–6: hear the word, pick the picture (no reading). Ages 7+: picture, meaning (4 native-language options) and letter-tile spelling (3–6 letters, 2 extra tiles) take turns; a kind that does not fit a word passes to the next. Wrong options come from the age/level word pool with a different picture/meaning. A wrong quiz answer reschedules the word from its pre-session state as "quiz wrong"; summary shows "Quiz: x of y right" and stars/accuracy use the overridden answers. Quiz questions are extra time on top of the feat-011 card budget |
| Retention metric (feat-013, 2026-11-05) | Every quiz answer is stored (QuizLogs: profile, word, kind, right/wrong, time; DB schema v2, upgrade keeps v1 data). "Remembered after 2 weeks" = share of quiz answers right on words first seen 14+ days before the quiz; every answer counts; words with no progress (after a reset) are ignored. Shown per child on the progress screen (child and parent); feeds feat-017 dashboard and the feat-020 gate. Reset progress and deleting a profile clear the quiz log |
| Word bank v2 (feat-014, 2026-11-05) | 1,497 words: Pre-A1 364, A1 611, A2 255, B1 267, written in-house from topic areas (no published list copied); source split into one file per level. A2/B1 are ages 7+, pictures optional (Emoji 12 only, no ZWJ sequences, so they show on older Android); verbs carry past / past participle, adjectives comparative / superlative, some nouns plural. All four levels can be picked in the profile; default by age (≤6 Pre-A1, 7–9 A1, 10–12 A2, 13+ B1). Translations fade by level: Pre-A1/A1 shown, A2/B1 tap to see. Blocklist extended (swearing, violence, alcohol/drugs/gambling, adult). Vietnamese is a draft for owner review; syllables/stress not added. v1 ids never change; v2 installs over v1 and keeps progress |
| Placement + favourite themes (feat-015, 2026-11-05) | A new profile takes a word check on the child's first open (the parent can start it right after adding the child, leave it, or skip it and keep the form's level; skip / redo in the edit form). 4 blocks of 6 words = 24 words, word shown and spoken, "I know it" / "Not yet". First block at the profile's level (age default unless the parent changed it); after each block, up one level if that level's score so far is ≥70%, down if not; at the top/bottom the same level again. Each block takes one word from each sixth of the unused words (easy → hard), preferring words that can be checked. Anti-guessing: the first checkable "I know it" is checked at once, then at most one every 4 words — pick the picture (or, ages 7+, the meaning when there is no picture); a failed check makes that word unknown, and unchecked "I know it" answers count as (checks passed + 1) / (checks + 1). Start level = highest tested level ≥70%, else the lowest. Then the child picks up to 3 favourite topics from a curated, kid-appeal-ordered list (themes with ≥8 words for their level and age, at most 12 shown; grammar-ish tags like actions/describing are not offered); within a level, favourite-topic words come first, then teaching order. Placing at a new level moves a default translation mode with it. First mini-session: 5 words the child said they knew (at or below the start level), topped up from the normal new-word order. Quitting midway saves nothing. Children created before this (DB schema v3) count as already placed |
