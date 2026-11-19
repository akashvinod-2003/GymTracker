---
version: 1
slug: "lib-packs-turbo"
primary_target: "lib/packs/turbo"
related_targets: []
---

## Scope

Turbo theme pack (`lib/packs/turbo`): a third selectable visual pack for the whole app (Daily dashboard, Splits, Analytics, Workout, quick entry, auth, profile drawer, dialogs and sheets). Mode: Operate. Users: lifters logging sets on a phone mid-session and reviewing progress afterwards. Structure, information architecture, navigation, content order and behaviour all stay identical to the Studio pack.

## Direction contract

THESIS: Gym ink on milk paper. The category default is a dark neon dashboard or soft pastel cards; this refuses both. It's a flat, high-contrast print sheet where charcoal carries the structure and one electric blue marks the thing you act on now.

OWN-WORLD: Milk Paper #E9E6DF ground and surfaces (60%), Grill Charcoal #2E2B28 for text, the hero card, nav and dark slabs (30%), Turbo Blue #1F4BFF only for the primary action, the active state, links and the live number (10%). Inter Tight 800–900 tight-tracked headings, Inter body, tabular figures. Square-ish 6–12px radii, 1.5px charcoal-tinted borders, no glow, and one soft offset shadow on floating chrome only. Sharp-cornered Material icons.

STORY: You see today's lifted volume and what's next, tap the one blue thing, log a set, and see progress move.

FIRST VIEWPORT: The Daily tab as built. Header row, a charcoal hero slab with the day's volume in huge Inter Tight milk figures and the Turbo quick action, the stats row, then the split breakdown. A charcoal bottom bar with a Turbo centre button and a Turbo active tab marker.

FORM: seed: none (pinned) — "Main 60%: Milk Paper … Secondary 30%: Grill Charcoal … Accent 10%: Turbo Blue #1F4BFF", "bold, high-contrast, modern", "heavy grotesque sans for headings", "Keep the same layout grid and content order." Signature move: the Turbo number. The single live figure on each screen (today's volume, the active set's weight × reps) is set in heavy tabular Inter Tight; on the hero slab, the Turbo action sits beside it as the only blue block.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Unresolved

- The Milk Paper hex is the brief's approximate value (no source image was supplied).
- Accent used as text or icon colour on charcoal or dark grounds takes a lighter Turbo tint (#8FA5FF), because #1F4BFF fails contrast there.
