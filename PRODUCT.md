# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
A small group of lifters (the owner plus friends or clients), each with their own Firebase account. They log sets on a phone in the gym between sets, and review progress and history afterwards.

## Product Purpose
GymTracker (README name: PulseFit) is a personal workout tracker: plan training splits, log sets live during a workout, and see daily volume, streaks, body weight and progress over time. Success means logging a set takes seconds in the gym and the progress views show whether training is moving forward.

## Positioning
A three-tier split catalogue (Split Group → Body Part → Exercise) drives everything: the calendar abbreviations, the guided "today's workout" flow, and per-split progress comparison against the last workout.

## Operating Context
- Mainly used as an installed PWA on a phone (gymtrack-2026.web.app, Firebase Hosting), one-handed, mid-session, often in a bright or dim gym.
- Tabs: Daily (progress dashboard), Splits, a centre + quick-entry action, Analytics, and Workout (current workout: resume, live logging, finish).
- The profile drawer holds settings, including the Theme Pack selector and light/dark mode.

## Capabilities and Constraints
- Flutter (Dart 3), Provider state, Firebase Auth and Cloud Firestore, shared_preferences, Google Fonts.
- Theme packs: `classic` (`lib/screens`, `lib/widgets`, `lib/theme`), `studio` (`lib/packs/studio`) and `turbo` (`lib/packs/turbo`, documented in DESIGN.md). Each pack is a parallel screen tree with the same structure and behaviour and its own visual language; the user picks one in the profile drawer. Every pack supports light and dark mode.
- The layout must hold at 360px phone width, and the bottom nav must leave room for the floating centre button.

## Brand Commitments
- App logo asset: `logo.png` / `assets/` (existing; keep).
- The visual language belongs to each pack; product structure, copy and behaviour are shared across packs.

## Evidence on Hand
- Real user data lives only in Firestore; there are no testimonials, metrics or marketing claims, so don't fabricate any.

## Product Principles
1. Logging in the gym comes first: big tap targets, few steps, readable at arm's length.
2. Progress should be visible at a glance: today's numbers before history.
3. One structure, many skins: packs change the look, never the behaviour.
4. The split catalogue is the backbone, so its naming and abbreviations stay consistent everywhere.

## Accessibility & Inclusion
No formal standard is set. The working floor is WCAG AA contrast for text in both light and dark mode, and touch targets of about 40px or more on phones.
