# Changelog

## [0.8.3] - 2026-08-11

### Fixed

- mod.card was still describing the pre-STRENGTH behaviour: it called the
  encounter one-time, and its known-issues list carried placeholder-era
  caveats about unverified map keys and script verbs that stopped being true
  several versions ago. Rewritten to match what the mod actually does.

## [0.8.2] - 2026-08-10

### Added

- Four screenshots in the README, under `docs/`.

## [0.8.1] - 2026-08-10

### Changed

- Pinned the HM Anywhere id to `hm_anywhere`, confirmed from that mod's own
  manifest, and dropped the list of guessed spellings.

## [0.8.0] - 2026-08-10

### Added

- Interoperates with the "HM Anywhere" mod. When it is active and HM_STRENGTH is
  in the bag, the truck no longer asks that a party member knows the move --
  under that mod the bag is the honest test. The RAINBOWBADGE is still required
  either way, and without the mod nothing changes.
- Detection uses `mod.find`, called at interaction time rather than at load, so
  mod load order cannot matter. It tries several likely spellings of the id
  because the real one is whatever the mod's folder is named; if none match, the
  mod falls back to the party check rather than failing.

## [0.7.1] - 2026-08-10

### Changed

- The prompt now runs the full description first -- "It's an old truck. / It
  won't budge. / It'd take real STRENGTH to shift." -- before offering
  USE STRENGTH / LEAVE IT, so the same line reads whether or not the player can
  act on it.

## [0.7.0] - 2026-08-10

### Changed

- Collapsed to a single path. Anyone who can use STRENGTH now gets the prompt at
  the truck; the auto-fire on an already-active STRENGTH is gone. Fewer branches,
  fewer ways to be silently unreachable. `ow.strengthActive` still satisfies the
  capability check alongside badge-plus-move, so an unexpected move-storage shape
  cannot lock anyone out.

## [0.6.0] - 2026-08-10

### Fixed

- The STRENGTH gate was unreachable on engine 0.1.75, whose party submenu is
  STATS / MOVES / SWITCH rather than the dev build's field-moves-then-STATS
  list, so `ow.strengthActive` could not be set from there. The truck now takes
  either route:
  - STRENGTH already active from the party menu (unchanged, faithful path), or
  - a "USE STRENGTH / LEAVE IT" prompt at the truck, offered only to a player
    holding the RAINBOWBADGE with a party member that knows the move.
  The requirement is the same either way; only where it is asked for differs.
- The party scan compared move entries as bare strings, but moves are stored as
  tables with an `id`, so the 0.5.1 nudge never matched. Handles both shapes.

## [0.5.0] - 2026-08-10

### Changed

- Mew now requires STRENGTH, matching the dominant form of the legend. The gate
  is `ow.strengthActive`, set only by the party-menu STRENGTH action on the
  current map and cleared on every map load -- the same single flag the vanilla
  boulder push reads. So the ritual is literal: activate STRENGTH on the dock,
  then face the truck.
- Interacting without STRENGTH active prints a message hinting at what is
  needed, instead of nothing.
- The truck object is never moved. Only the text says it shifts.

### Fixed

- `play_cry` was followed by `start_battle`, but it arms the *next* `show_text`
  and nothing consumed it, so Mew's cry never played. The cry row now sits
  between the two messages, matching how the vanilla static encounters do it.
- Text pages are capped at two lines. The engine treats `\n` as the second
  line and `\v` as a scrolled continuation, so a third `\n` line in one page
  scrolled past without waiting for A. That was the fast-scrolling gate message
  in 0.3.0; it was already corrected in 0.4.0.

## [0.4.0] - 2026-08-10

### Changed

- Reworded the gate dialogue: the sailor now says the ship has already sailed
  and that the dock is still open, then offers the look around.
- The sailor's own `talk` script says the same thing once the ship has gone,
  instead of only reporting it gone. His ticket branch is reproduced verbatim
  and still runs while the ship is docked.
- Mew is only retired once it is actually caught. Replaced `static_battle`
  (whose `beatFlag` fires on any non-blackout end, retiring the encounter on a
  faint or a flee) with `start_battle` plus `check_battle_result "caught"`.

### Note

- The completion flag was renamed to `MOD_MEW_UNDER_TRUCK_CAUGHT`, so a save
  carrying the old `..._TAKEN` flag gets the truck back.

## [0.3.0] - 2026-08-10

### Changed

- Rewritten against the real mod API. The previous versions invented a script
  context (`ctx:text`, `ctx:choice`, `ctx:wildBattle`, a `step` handler taking
  `ctx`); none of that exists. Real shape: `map_scripts:register` with
  `onStep(game, ow, x, y)` / `onInteract(game, ow, fx, fy)` returning a
  boolean, and command rows queued through `ow:queueScript`.
- The sailor is hooked on `onStep` at cell (18, 30) facing down, matching the
  engine's own per-frame coordinate gate.
- The truck uses `static_battle`, the verb behind the vanilla static
  legendaries, so catch/flee/win all behave like Snorlax or the birds.
- `game_version` widened to `>=0.0.0-0 <2.0.0` so prerelease engine builds
  satisfy it.

### Fixed

- Dropped the private `require` of `src.script.Flags`, which tripped MK006
  without the `engine_internals` permission. Flags now read off `game.save`.

## [0.2.1] - 2026-08-10

### Fixed

- `game_version` rejected engine 0.1.75.

## [0.2.0] - 2026-08-10

### Changed

- Real map coordinates and flag names from the Gen 1 map data.

## [0.1.0] - 2026-08-10

### Added

- First cut.
