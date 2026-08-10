# Mew Under the Truck

Once the S.S. Anne has sailed, the Vermilion sailor tells you the ship has
gone but the dock is still open, and offers to let you down there. He keeps
offering, and says the same thing if you talk to him directly. The truck on
the dock holds a level 5 Mew that stays available until you actually catch
it.

## Install

Drop the `mew_under_the_truck` folder into your `mods/` directory:

- Windows: `%APPDATA%\love\pokemon-love2d\mods\`
- Linux: `~/.local/share/love/pokemon-love2d\mods\`
- macOS: `~/Library/Application Support/pokemon-love2d/mods/`
- Android: the `mods/` folder next to your save data

The loader discovers mods one level below `mods/`, so the layout must be
`mods/mew_under_the_truck/manifest.json`. Restart fully afterwards - content
registries freeze at the boot merge.

Validates clean:

```
python3 tools/modkit.py validate mods/mew_under_the_truck
```

## How it works

Both halves use the compose store's step hooks, which are **first truthy
return consumes**. Mods rank ahead of the engine's own contribution, so
returning `false` drops straight through to vanilla.

### The sailor - `VERMILION_CITY.onStep`

Vanilla runs its gate from a per-frame coordinate check, not from dialogue:
standing on cell **(18, 30)** - the unguarded cell west of the sailor that
leads onto the dock warp - while facing **down**. If the ship has sailed it
prints the set-sail line and walks you back up; otherwise it runs the ticket
check.

This mod intercepts only the ship-has-sailed case and offers GO or STAY. The
ticket path is returned `false` and never touched.

Nothing is latched. No flag is set on GO, so the trigger fires again on every
approach - which is the point.

### The truck - `VERMILION_DOCK.onInteract`

`onInteract` receives the **faced** cell. The truck is block `$03` at block
(10, 0), covering cells **(20, 0)** and **(21, 0)**, and it is the only
occurrence of that block in the map. Stand at (20, 1) or (21, 1) facing up.

Vermilion Dock ships with no bg events and no object events at all, so there
has never been anything to interact with there. This is the first.

### Requiring STRENGTH

Mew needs STRENGTH, and there are two ways to satisfy that:

1. **Activate it first.** `ow.strengthActive` is set by the party-menu STRENGTH
   action (behind the Rainbow Badge) and cleared on every map load. Use it on
   the dock, face the truck, and Mew turns up with no prompt.
2. **Be asked at the truck.** If STRENGTH is not active but you hold the
   RAINBOWBADGE and a party member knows the move, facing the truck offers
   "USE STRENGTH / LEAVE IT".

The second path exists because not every engine build exposes field moves in
the party submenu -- 0.1.75 shows STATS / MOVES / SWITCH, with no STRENGTH row
to select. Without the fallback the encounter is simply unreachable there. The
requirement is identical in both paths.

### HM Anywhere

If the "HM Anywhere" mod is active and HM_STRENGTH is in the bag, the party
check is skipped -- that mod's whole point is that an owned HM is usable without
teaching it, so requiring a taught move would be the wrong test. The Rainbow
Badge is still required. Detection runs through `mod.find` at interaction time,
and tries several spellings of the id since it is whatever the mod's folder is
named; a miss falls back to the party check rather than breaking.

Without the badge or the move you get a message pointing at what is missing.
The truck sprite itself is never moved -- only the text says it shifts.

Strength is the dominant form of the schoolyard legend, though it was never one
fixed ritual -- rival versions used the Game Corner car keys, and some tellings
needed no move at all.

### Catching, not beating

The encounter deliberately does **not** use `static_battle`. That verb's
`beatFlag` fires on any non-blackout end, so fainting Mew or letting it flee
would retire it exactly like a fled legendary. Instead it runs `start_battle`
and branches on `check_battle_result "caught"`, setting
`MOD_MEW_UNDER_TRUCK_CAUGHT` only on an actual catch. Faint it, flee, or black
out, and the truck still stirs next time.

## Notes

- Mod flags are `MOD_`-prefixed by convention so they never collide with the
  pokered event namespace.
- Flags are read straight off `game.save.flags` rather than through a private
  `require`, which would need the `engine_internals` permission.
- The S.S. Anne interior is untouched. Re-boarding lands you in maps whose
  story scripts have already run. The point here is only that the dock stays
  reachable so you can Surf from it.
- When the ship departs, the vanilla dock script fills the lower part of the
  map with water. That is what makes Surf the route to the truck.

## Legal

No ROM-derived bytes. Lua and text only.
