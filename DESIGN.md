---
name: GymTracker
description: Personal workout tracker in the Turbo pack, a flat high-contrast print sheet of charcoal ink on milk paper with one electric blue for the thing to act on.
colors:
  milk-paper: "#E9E6DF"
  grill-charcoal: "#2E2B28"
  turbo-blue: "#1F4BFF"
  turbo-light: "#8FA5FF"
  turbo-deep: "#1638C8"
  turbo-tint: "#E3E8FF"
  turbo-tint-dark: "#23284A"
  paper-card: "#F4F2ED"
  paper-sub: "#DEDAD1"
  paper-rule: "#CFCAC0"
  ink-secondary: "#5C5751"
  ink-tertiary: "#69635C"
  charcoal-sub: "#3A3633"
  charcoal-rule: "#45403B"
  charcoal-ground: "#211F1D"
  charcoal-deep: "#1B1917"
  ash-secondary: "#B4AEA5"
  ash-tertiary: "#9A948B"
  success-light: "#0E7040"
  success-dark: "#3DD68C"
  danger-light: "#B8202A"
  danger-dark: "#FF7A70"
typography:
  display-large:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "46px"
    fontWeight: 900
    lineHeight: 1.0
    letterSpacing: "-1.8px"
  display:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "36px"
    fontWeight: 900
    lineHeight: 1.05
    letterSpacing: "-1.3px"
    fontFeature: "tnum"
  headline-large:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "30px"
    fontWeight: 800
    lineHeight: 1.08
    letterSpacing: "-0.9px"
  headline-medium:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "26px"
    fontWeight: 800
    lineHeight: 1.12
    letterSpacing: "-0.7px"
  headline-small:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.15
    letterSpacing: "-0.5px"
  title-large:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "20px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.4px"
  title-medium:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "17px"
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: "-0.2px"
  title-small:
    fontFamily: "Inter Tight, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "-0.1px"
  body-large:
    fontFamily: "Inter, sans-serif"
    fontSize: "16px"
    fontWeight: 500
    lineHeight: 1.45
    letterSpacing: "-0.1px"
  body-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "14.5px"
    fontWeight: 500
    lineHeight: 1.45
    letterSpacing: "-0.05px"
  body-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: "0px"
  label-large:
    fontFamily: "Inter, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.1px"
  label-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "13px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0px"
  label-small:
    fontFamily: "Inter, sans-serif"
    fontSize: "11px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0.2px"
rounded:
  s: "6px"
  m: "8px"
  l: "12px"
  xl: "14px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "20px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.turbo-blue}"
    textColor: "#FFFFFF"
    typography: "{typography.label-large}"
    rounded: "{rounded.m}"
    height: "50px"
  button-outlined:
    backgroundColor: "transparent"
    textColor: "{colors.grill-charcoal}"
    typography: "{typography.label-large}"
    rounded: "{rounded.m}"
    height: "50px"
  button-text:
    backgroundColor: "transparent"
    textColor: "{colors.turbo-blue}"
    typography: "{typography.label-large}"
    rounded: "{rounded.m}"
    height: "44px"
  input:
    backgroundColor: "{colors.paper-sub}"
    textColor: "{colors.grill-charcoal}"
    typography: "{typography.body-large}"
    rounded: "{rounded.m}"
    padding: "14px 16px"
  card:
    backgroundColor: "{colors.paper-card}"
    textColor: "{colors.grill-charcoal}"
    rounded: "{rounded.l}"
    padding: "16px"
  hero-slab:
    backgroundColor: "{colors.grill-charcoal}"
    textColor: "{colors.milk-paper}"
    typography: "{typography.display}"
    rounded: "{rounded.l}"
    padding: "20px"
  nav-bar:
    backgroundColor: "{colors.grill-charcoal}"
    textColor: "{colors.ash-secondary}"
    typography: "{typography.label-small}"
    rounded: "{rounded.l}"
    height: "64px"
    padding: "6px"
  nav-tab-active:
    backgroundColor: "{colors.turbo-blue}"
    textColor: "#FFFFFF"
    rounded: "{rounded.m}"
  dialog:
    backgroundColor: "{colors.paper-card}"
    textColor: "{colors.grill-charcoal}"
    typography: "{typography.title-medium}"
    rounded: "{rounded.l}"
  bottom-sheet:
    backgroundColor: "{colors.paper-card}"
    textColor: "{colors.grill-charcoal}"
    rounded: "{rounded.xl}"
  snackbar:
    backgroundColor: "{colors.grill-charcoal}"
    textColor: "{colors.milk-paper}"
    typography: "{typography.body-medium}"
    rounded: "{rounded.m}"
---

# Design System: GymTracker

This file documents the **Turbo** pack (`lib/packs/turbo/`). Tokens live in `lib/packs/turbo/theme/app_theme.dart` (`AppTheme`, semantic roles in `Pal`, tabular figures in `tabularFigures`) and motion in `lib/packs/turbo/theme/motion.dart`.

## Overview

**Creative North Star: "Gym Ink on Milk Paper"**

A flat, high-contrast print sheet. Warm milk paper carries the ground, grill charcoal carries the structure (type, the hero slab, the tab bar), and one electric Turbo blue marks the thing to act on right now: the primary button, the active tab, links, the live figure's action (the solid Turbo Splits button on the hero slab), and the live set (the next undone set's kg × reps, in heavy `accentText`). It refuses the category defaults of the dark neon dashboard and the soft pastel card stack.

Density is phone-first and arm's-length readable: heavy, tight-tracked Inter Tight figures, big 50px buttons, cards separated by thin warm rules instead of shadows. The one moment of depth is floating chrome, the charcoal tab bar, which sits on a single soft offset shadow. Motion is critically damped springs with press-down scaling; nothing glows.

**Key Characteristics:**
- 60-30-10 split of milk, charcoal and Turbo on every screen.
- One live number per screen, set in heavy tabular Inter Tight.
- Charcoal hero slab that renders its contents in the dark palette in both modes.
- Square-ish corners (6-14px), thin warm rules (1.5px on themed controls), sharp-cornered Material icons.
- Floating charcoal tab bar with a solid Turbo block for the active tab.

## Colors

Warm, papery neutrals with one saturated cobalt; every text pairing is AA or better (ratios noted in `app_theme.dart`).

### Primary
- **Turbo Blue** (`turbo-blue`, `AppTheme.turbo` / `t500`): the only fill for the primary action, the active tab block, switch tracks, focus borders, the cursor and progress bars. Always carries white type (6.0:1). Used as text or icon colour on light grounds only (4.8:1 on milk).
- **Turbo Light** (`turbo-light`, `t300`): Turbo as text or icon colour on dark grounds (charcoal, the hero slab, dark mode, snackbar actions in light mode). 6.0:1 on charcoal.
- **Turbo ramp** (`t050`-`t900`): `t050` (via `accentTint` / `tealBg`) for progress-bar tracks, icon tiles and selected grounds in light mode, `t800` for the same in dark mode; `t600` (`turbo-deep`) for small Turbo ink on light grounds (the body-weight check-in caption, today's calendar cell) and the Turbo ink muscle swatch; `t200` its dark-mode counterpart and the light calendar workout-day mark; `t100`/`t400`/`t900` are defined steps with little or no screen use.

### Neutral
- **Milk Paper** (`milk-paper`, `n100`): light-mode scaffold ground; primary text on dark grounds and on chrome (11.3:1 on charcoal).
- **Grill Charcoal** (`grill-charcoal`, `n800`): primary text in light mode (11.3:1 on milk), the hero slab, the tab bar, the date-picker header, the light-mode snackbar, outlined-button stroke; card surface in dark mode.
- **Paper Card** (`paper-card`, `n050`): light-mode cards, dialogs and sheets.
- **Paper Sub** (`paper-sub`, `n150`): light-mode secondary surface, input fill.
- **Paper Rule** (`paper-rule`, `n200`): light-mode borders and dividers.
- **Ink Secondary / Tertiary** (`n600` 5.6:1, `n550` 4.8:1): light-mode secondary and hint text.
- **Charcoal Ground** (`charcoal-ground`, `n900`): dark-mode scaffold. **Charcoal Sub** (`n750`) dark secondary surface; **Charcoal Rule** (`n700`) dark borders; **Charcoal Deep** (`n950`) shadow colour and ink on `t300`. The hero slab and tab bar stay charcoal in both modes.
- **Ash Secondary / Tertiary** (`n300` 6.4:1, `n400` 4.7:1): dark-mode secondary and hint text; `n300` is also inactive-tab ink on chrome.
- The full warm ramp runs `n050`-`n950` (`F4F2ED` to `1B1917`); stay on it rather than mixing in grey or pure black.

### Functional data colours
- **Success** (`0E7040` light / `3DD68C` dark, tints `D9E8DC` / `1C3426`): completed sets and completion states; mapped to `colorScheme.secondary`.
- **Danger** (`B8202A` light / `FF7A70` dark, tints `F3DCD7` / `41241F`): destructive actions and errors.
- **Muscle-group ink swatches** (`AppTheme.pastelStyles`, via `Pal.plate(i)`): five printed inks (Turbo, charcoal, ochre, green, red, in that order, so red only appears from the fifth group), each with light and dark background, border and text, cycled by index. They colour chips, legend dots and hero ring segments. They are data, not brand.

### Semantic roles (`Pal`)
`bg`, `surface`, `surface2`, `separator`, `text`, `text2`, `text3` resolve per mode. `accent` is the Turbo fill in both modes with `onAccent` white; `accentText` is Turbo in light and `t300` in dark; `accentTint` is `t050` / `t800`. `chrome` is charcoal at 97% (light) or 98% (dark) with a hairline `chromeEdge`; `onChrome` is milk and `onChrome2` is `n300`. Widgets call `Pal.of(context)` rather than branching on brightness.

### Dark mode
Dark mode inverts the paper and keeps the ink. Ground goes to `n900`, cards to charcoal, sub-surfaces to `n750`, rules to `n700`; text becomes milk / `n300` / `n400`. Turbo fills stay exact `#1F4BFF` with white; Turbo-as-ink switches to `t300`, accent tints to `t800`. Success and danger swap to their bright variants. The hero slab and tab bar stay charcoal and separate from the `n900` ground by tone and their rule. The snackbar inverts to milk with charcoal text and a Turbo action.

### Named Rules
**The 60-30-10 Rule.** Milk paper about 60% of a screen, charcoal about 30%, Turbo about 10%. If two things on a screen are blue fills, one of them is wrong.

**The Fill vs Ink Rule.** Turbo fills are always exact `#1F4BFF` with white on top, in both modes. Turbo as text or icon colour on any dark ground is `t300`, never `#1F4BFF`.

## Typography

**Display Font:** Inter Tight (Google Fonts), weights 800-900
**Body Font:** Inter (Google Fonts), weights 500-700

**Character:** A heavy grotesque for figures and headings, tracked tight like poster type, over a plain, slightly weighted Inter for everything you read.

### Hierarchy
- **Display** (900, 46px / 36px, 1.0-1.05, -1.8 / -1.3px): the live figure, such as today's volume on the hero slab (36px, tabular).
- **Headline** (800, 30 / 26 / 22px, 1.08-1.15): screen and section headlines.
- **Title** (800, 20 / 17px; 700, 15px): card titles, app bar title (`titleLarge`), dialog titles (`titleMedium`), set counts.
- **Body** (500, 16 / 14.5 / 13px, 1.4-1.45): body and supporting copy; `bodyLarge` is primary text, medium and small take secondary text colour.
- **Label** (700, 15px; 600, 13px; 600, 11px +0.2px): button labels (`labelLarge`), stat captions, tab labels (`labelSmall`). 11px is the floor.

`AppTheme.heading()` gives ad-hoc Inter Tight at 800 with tracking of -3% of size at 20px and above, -0.2px below.

### Named Rules
**The Tabular Figure Rule.** Every number that can change (volume, sets, weight × reps, streaks, timers) uses `fontFeatures: tabularFigures` so digits never jitter.

**The 11px Floor Rule.** Nothing on screen is set below 11px.

## Layout

Single-column phone layout that must hold at 360px. Screen content sits on 16px side gutters with bottom padding of 104px plus the safe-area inset to clear the tab bar; cards pad 14-16px, the hero slab 20px. Spacing steps are 4, 8, 16, 20 and 24px. Stat cards sit two-up in a row. The tab bar floats above content: max width 420px, 24px side inset, 8px above the safe-area bottom, 64px tall, so scroll content needs bottom clearance for it. Tap targets are 44px minimum, 50px for primary and outlined buttons.

## Elevation & Depth

Flat by default. Depth comes from tone (charcoal slab on milk, `surface` on `bg`) and thin rules, not shadows. The one structural shadow is on floating chrome.

### Shadow Vocabulary
- **Chrome lift** (`n950` at 22% light / 50% dark, blur 18, offset 0 6): the floating tab bar only.
Every other surface is flat: the Studio-era card shadows and Turbo-tinted tile glows were removed.

### Named Rules
**The No-Glow Rule.** No coloured shadows or glows around Turbo elements; Turbo is a flat ink block.

## Shapes

Square-ish, printed-sheet corners: `radiusS` 6px for progress-bar tracks and small icon tiles (applied as a literal), `radiusM` 8px for buttons, inputs, snackbars and the active-tab block, `radiusL` 12px for cards, dialogs, the hero slab, the tab bar and date picker, `radiusXL` 14px for the top corners of bottom sheets and larger panels. In the screen code most radii are literals rather than token references, and 10px is the most frequent literal (icon tiles, list rows, inner controls); it sits between `m` and `l` and is accepted in-world, but new code should reference the tokens. The hero's streak and exercise pills are 12px on a short height, which reads as a capsule. Borders split in two: the ThemeData-driven controls (inputs, dialogs, outlined buttons) and the hero slab use 1.5px (`AppTheme.borderWidth`), while screen-level cards, rows and tiles mostly use a bare `Border.all(color: separator)`, which is 1px. Both read as thin warm rules; new code should prefer `borderWidth`. The focused input border is 2px Turbo. The drawer is square-edged. Icons are sharp-cornered Material (`Icons.*_sharp`); inactive tab icons use the `_outlined` variant.

## Components

### Buttons
Firm, flat, full-strength.
- **Shape:** gently squared (8px), minimum height 50px, label in `labelLarge`.
- **Primary (Filled / Elevated):** Turbo fill, white label, elevation 0, in both modes.
- **Outlined:** transparent with a 1.5px stroke in primary text colour (charcoal in light, milk in dark).
- **Text:** `accentText` label (Turbo in light, `t300` in dark), 44px minimum.
- **Press:** `Pressable` scales to 0.96 on pointer down and springs back (`AppSpring.press`); Material ink ripple elsewhere.

### Inputs / Fields
- **Style:** filled with `surface2`, 1.5px `separator` border, 8px radius, 14×16px padding, hint in `text3`.
- **Focus:** border goes 2px Turbo; cursor and selection handles Turbo, selection at 28% Turbo.

### Cards / Containers
- **Corner Style:** 12px.
- **Background:** `surface` (`n050` light, charcoal dark), sub-areas on `surface2`.
- **Border:** `separator` rule, 1px in most screen cards as built (1.5px `borderWidth` is the token).
- **Internal Padding:** 14-16px.

### Hero Slab (signature)
The Daily tab's top card is a charcoal slab in both modes (charcoal in light, `n950` with an `n700` rule in dark), 12px radius, 20px padding. Its subtree is wrapped in `AppTheme.darkTheme`, so everything inside reads in the dark palette: milk type, `t300` accent text, dark tints. It holds the set-progress ring (segments in muscle-group inks), the day's volume in 36px 900 tabular Inter Tight with a `kg` suffix, streak and exercise pills, and the muscle legend.

### Navigation
- **Tab bar:** floating charcoal slab (`Pal.chrome`), 12px radius, hairline `chromeEdge`, the chrome lift shadow, 6px inner padding, four tabs: Today, Workout, Splits, Progress.
- **Active tab:** a solid Turbo block (8px radius) behind white icon and 800-weight label; it glides between tabs on `AppSpring.standard` and can be redirected mid-flight.
- **Inactive tab:** outlined icon and 600-weight label in `n300`.
- **No centre button in the bar:** tabs only navigate. Quick entry (`QuickEntrySheet`) opens as a bottom sheet from actions on the Workout tab (start, quick setup, add).
- **App bar:** scaffold ground, no elevation or scroll tint, left-aligned `titleLarge`.

### Dialogs and Sheets
- **Dialog:** `surface` ground, 12px radius, 1.5px `separator` border, no surface tint, `titleMedium` title, `bodyMedium` content.
- **Bottom sheet:** `surface` ground, 14px top corners, drag handle in `text3`.
- **Snackbar:** floating, inverted (charcoal with milk text in light, milk with charcoal text in dark), 8px radius, action in `t300` (light) or Turbo (dark).
- **Date picker:** charcoal header with milk text, Turbo today ring, 12px radius.
- **Switch:** Turbo track with white thumb when on.

### Motion
Critically damped springs (`AppSpring.standard`, response 0.35s), a quick press spring (0.18s), and a bouncy spring (0.4s, damping 0.75) only after momentum gestures or a completed set. Reduced motion is honoured via `reduceMotion(context)`. Haptics fire only on commit, completion and removal. Page transitions use the Cupertino slide on Android, iOS and macOS.

## Do's and Don'ts

### Do:
- **Do** resolve colours through `Pal.of(context)`; use `accent` for fills and `accentText` for Turbo-coloured text and icons.
- **Do** keep Turbo to one primary action or active state per view, roughly 10% of the screen.
- **Do** set every changing number in Inter Tight with `tabularFigures`.
- **Do** use `separator` rules (prefer `AppTheme.borderWidth`, 1.5px) and tone for separation, and token radii (6/8/12/14px).
- **Do** wrap any charcoal slab's contents in `AppTheme.darkTheme` so they read in the dark palette.
- **Do** use `_sharp` Material icons.

### Don't:
- **Don't** put `#1F4BFF` text or icons on charcoal or any dark ground; use `t300`.
- **Don't** add glows, coloured shadows or gradients-as-decoration; the only real shadow is on floating chrome.
- **Don't** use muscle-group inks, success or danger as brand accents.
- **Don't** go below 11px type or below 44px tap targets.
- **Don't** introduce pure grey or pure black; stay on the warm `n050`-`n950` ramp.
- **Don't** round corners past 14px; buttons stay 8px.

## Alternative packs

Turbo is the documented system. Two other packs ship as user-selectable alternatives in the profile drawer, with identical structure and behaviour but their own visual language: **Classic** (`lib/theme/app_theme.dart`, screens in `lib/screens`, `lib/widgets`) and **Studio** (`lib/packs/studio/theme/app_theme.dart`). They are not covered by this file.

## Known deviations from the brief

- **Milk Paper hex is approximate.** `#E9E6DF` is the brief's stated value; no source swatch was supplied.
- **Accent ink on dark grounds is `t300` (`#8FA5FF`).** `#1F4BFF` fails text contrast on charcoal, so Turbo used as text or icon colour on dark grounds takes the lighter tint. Fills stay exact Turbo.
- **Success, danger and muscle-group swatches are kept.** They sit outside the three-colour brief as functional data colours, not brand colours.
