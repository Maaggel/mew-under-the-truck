-- Mew Under the Truck
--
-- 1. Once the S.S. Anne has sailed, the Vermilion sailor points the player
--    at the still-open dock instead of just turning them away. Both the
--    step gate and his own dialogue say so, and neither ever expires.
-- 2. Activating STRENGTH and facing the truck on the dock turns up a MEW.
--    Only catching it retires the encounter -- faint it or let it flee
--    and it is there again.
--
-- onStep / onInteract are "first truthy return consumes"; mods rank ahead
-- of the engine's contribution, so returning false falls through to
-- vanilla untouched. talk is single-winner, so the rows below replace the
-- sailor's base script outright and reproduce its ticket branch verbatim.

-- Vermilion City: the unguarded cell west of the sailor that leads onto
-- the dock warp. Vanilla runs its ticket gate here.
local GATE_X, GATE_Y = 18, 30

-- Vermilion Dock: the truck is block $03 at block (10,0), covering cells
-- (20,0) and (21,0). Stand at (20,1) or (21,1) facing up.
local TRUCK = { ["20,0"] = true, ["21,0"] = true }

-- mod flags are MOD_-prefixed by convention so they never collide with
-- the pokered event namespace
local MEW_CAUGHT = "MOD_MEW_UNDER_TRUCK_CAUGHT"

local SAILED_LINES =
  "The ship has\nalready sailed."
  .. "\fBut the DOCK's\nstill open."

return function(mod)

  mod.content.map_scripts:register("VERMILION_CITY", {

    onStep = function(game, ow, x, y)
      if x ~= GATE_X or y ~= GATE_Y then return false end
      if ow.player.facing ~= "down" then return false end
      -- Ship still docked: leave the vanilla ticket check completely alone.
      local flags = (game.save and game.save.flags) or {}
      if not flags.EVENT_SS_ANNE_LEFT then return false end

      ow:queueScript({
        { "show_text", SAILED_LINES .. "\fWant a look\naround down there?" },
        { "choice", { "GO", "STAY" } },
        { "jump_if_true", "go" },
        { "show_text", "Aye. Suit\nyourself." },
        { "move_player", "up", 1 },
        { "jump", "done" },
        { "label", "go" },
        { "label", "done" },
      })
      -- Consume the step. Nothing is latched and no flag is set, so the
      -- offer comes back every single time.
      return true
    end,

    talk = {
      TEXT_VERMILIONCITY_SAILOR1 = {
        { "face_player" },
        { "check_flag", "EVENT_SS_ANNE_LEFT" },
        { "jump_if_true", "sailed" },
        -- vanilla ticket branch, unchanged
        { "show_text", "_VermilionCitySailor1DoYouHaveATicketText" },
        { "check_item", "S_S_TICKET" },
        { "jump_if_false", "no_ticket" },
        { "show_text", "_VermilionCitySailor1FlashedTicketText" },
        { "jump", "done" },
        { "label", "no_ticket" },
        { "show_text", "_VermilionCitySailor1YouNeedATicketText" },
        { "jump", "done" },
        { "label", "sailed" },
        { "show_text", SAILED_LINES .. "\fTake a look around\nif you like." },
        { "label", "done" },
      },
    },
  })

  -- moves may be stored as tables with an id, or as bare strings
  local function knowsStrength(game)
    for _, mon in ipairs((game.save and game.save.party) or {}) do
      for _, mv in ipairs(mon.moves or {}) do
        local id = (type(mv) == "table") and mv.id or mv
        if id == "STRENGTH" then return true end
      end
    end
    return false
  end

  -- "HM Anywhere" (id: hm_anywhere) lets a player use an owned HM without
  -- teaching it -- it still requires the badge -- so when it is active the
  -- bag is the honest test and the party is not. Checked lazily at
  -- interaction time: mod.find returns nil for a mod that has not run yet,
  -- and load order is not ours to control. It exposes no exports table, so
  -- presence is the only signal available.
  local function hmAnywhereActive()
    return mod.find("hm_anywhere") ~= nil
  end

  -- The truck object is never moved -- only the text says it shifts.
  -- play_cry arms the NEXT show_text (the box closes when the cry
  -- finishes), so the cry row sits between the two messages.
  local function revealRows()
    return {
      { "show_text", "You heave the\ntruck aside!" },
      { "play_cry", "MEW" },
      { "show_text", "Something stirred\nunderneath!" },
      { "start_battle", "wild", "MEW", 5 },
      { "check_battle_result", "caught" },
      { "jump_if_false", "escaped" },
      { "set_flag", MEW_CAUGHT },
      { "jump", "done" },
      { "label", "escaped" },
      { "show_text", "Whatever it was,\nit's gone quiet." },
      { "label", "done" },
    }
  end

  mod.content.map_scripts:register("VERMILION_DOCK", {
    onInteract = function(game, ow, fx, fy)
      if ow.player.facing ~= "up" then return false end
      if not TRUCK[fx .. "," .. fy] then return false end

      local flags = (game.save and game.save.flags) or {}
      if flags[MEW_CAUGHT] then
        ow:queueScript({ { "show_text", "Just an old truck." } })
        return true
      end

      -- One path only: if the player can use STRENGTH, ask at the truck.
      -- ow.strengthActive also qualifies (it means the party menu let them
      -- use the field move), so an odd move-storage shape cannot lock
      -- anyone out.
      local inv = (game.save and game.save.inventory) or {}
      local viaHmAnywhere = (inv.HM_STRENGTH or 0) > 0 and hmAnywhereActive()
      local canUse = ow.strengthActive
        or (inv.RAINBOWBADGE and (knowsStrength(game) or viaHmAnywhere))

      if canUse then
        local rows = {
          { "show_text", "It's an old truck."
            .. "\fIt won't budge."
            .. "\fIt'd take real\nSTRENGTH to shift." },
          { "choice", { "USE STRENGTH", "LEAVE IT" } },
          { "jump_if_false", "leave" },
        }
        for _, row in ipairs(revealRows()) do rows[#rows + 1] = row end
        rows[#rows + 1] = { "jump", "out" }
        rows[#rows + 1] = { "label", "leave" }
        rows[#rows + 1] = { "show_text", "Some things are\nbest left alone." }
        rows[#rows + 1] = { "label", "out" }
        ow:queueScript(rows)
        return true
      end

      -- No badge, or nothing in the party knows it.
      ow:queueScript({
        { "show_text", "It's an old truck."
          .. "\fIt won't budge."
          .. "\fIt'd take real\nSTRENGTH to shift." },
      })
      return true
    end,
  })
end
