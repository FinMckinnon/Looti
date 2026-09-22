# Looti 2.0 — defects found and fixed

Twenty defects are recorded here — eighteen found in Looti 1.x, and two more
(19 and 20) found by reviewing this rebuild. Each has its symptom, its root
cause, the fix, and the test that now guards it.

Two test suites run against this addon, from `C:\code\wow-addon-test`:

```
tools/elune/bin/lua.exe tests/smoke.lua ./Looti_2-0      35 checks
tools/elune/bin/lua.exe tests/settings.lua               34 checks
```

Both load the real `.toc`, including AceGUI, and fire real client events whose
payloads are taken from `Blizzard_APIDocumentationGenerated`.

---

## 1 — Nil `SetPoint` offset crashed every loot

**Symptom.** With Show Icon on and Show Text off, every single loot raised a Lua
error and no notification appeared.

**Cause.** `iconMarginX` was declared but only assigned inside the `if text then`
branch, then used in the `else` branch. Fixing that exposed a second instance:
`setNotificationData` indexed `text` unconditionally, so it threw as soon as the
text region did not exist.

**Fix.** Notification rows now build their text, icon and upgrade regions once
and show or hide them per setting, so no region is ever absent
(`Notifications/Looti_Row.lua`). The state was unreachable from the UI anyway —
see defect 12.

**Guard.** *display settings combinations* in `smoke.lua` loots under icon+text,
text only and icon only. The harness also asserts on a nil `SetPoint` offset
rather than ignoring it.

## 2 — Whitelist was dead below the rarity threshold

**Symptom.** An item on the whitelist still did not notify if its rarity was
under the minimum.

**Cause.** `ShouldShowNotification` correctly let the whitelist override the
threshold, then `Looti_ShowNotification` applied the same threshold again with no
knowledge of the whitelist.

**Fix.** The threshold lives in one place, `L.Filter.ShouldShow`
(`Notifications/Looti_Filter.lua`). Nothing downstream re-checks it.

**Guard.** *whitelist beats the threshold* in `smoke.lua`.

## 3 — `addToBlacklist` wrote the wrong table level

**Cause.** It set `LootiFilters.blacklist[itemID]`, but `isItemInList` reads
`blacklist.items[itemID]`.

**Fix.** `L.Db.AddFilterItem` and `L.Db.RemoveFilterItem` own both sides
(`Core/Looti_Db.lua`).

## 4 — Frame position reset on relog

**Symptom.** Some players lost their notification position every time they logged
out; others never did.

**Cause.** `SaveFramePosition` had exactly one call site — the tick button on the
mover. Dragging the frame and logging out without clicking it never wrote the
position. `StopMovingOrSizing` can also leave the frame anchored to a different
point than the load path restores from.

**Fix.** `L.Anchor.SavePosition` runs on every drag end, and normalises the anchor
to `CENTER`/`UIParent` before saving so the round trip is stable
(`Notifications/Looti_Anchor.lua`).

**Guard.** *frame position across a relog* in `smoke.lua` drags, relogs and
re-checks, twice.

## 5 — Loot lost to a race with other addons

**Symptom.** With certain other addons installed, Looti notified for only some
items, or none at all.

**Cause.** The old code enumerated the live loot window on `LOOT_READY`. A
fast-loot addon registered on the same event empties the window from its own
handler; if it ran first, every slot read back `nil` and nothing was captured. It
also wiped its cache on every `LOOT_READY`, which can fire again mid-session.

**Fix.** Three rules in `Notifications/Looti_Events.lua`: capture the whole window
into our own array at the earliest event and iterate that; never wipe mid-session
or overwrite a good entry, clearing only on `LOOT_CLOSED`; and treat
`CHAT_MSG_LOOT` as a backstop, since nothing can race the server's own statement
of what was received. A `LOOT_SLOT_CLEARED` for an uncaptured slot triggers a
salvage pass so the remaining slots survive.

The slot path and the chat path cover each other without double-reporting. Each
loot raises a balance from the slot side and lowers it from the chat side, and a
notification goes out whenever the balance moves away from zero. That gives one
notification per pickup whichever event arrives first, and — unlike a scheme that
pairs events off — it still gives one when another addon takes the item and only
the chat line reaches us.

**Guard.** *interaction with other addons* runs a rival auto-looter in both
registration orders; *no double-reporting between the slot and chat paths*
covers the dedup in both directions.

## 6 — Bulk loot took about ten seconds to notify

**Cause.** The queue released exactly one notification per `notificationDelay`
tick. A 25-item loot put the last notification 9.6 s behind the pickup.

**Fix.** The backlog drains over at most five ticks, holding the rate for the
whole drain rather than recomputing it from the shrinking backlog — which decays
geometrically and leaves a long one-per-tick tail (`Notifications/Looti_Queue.lua`).

**Guard.** *bulk loot latency* loots 25 items and requires them all within 3 s.

## 7 — Roll wins never notified

**Symptom.** Winning a roll produced no notification, ever.

**Cause.** `LOOT_ITEM_ROLL_WON` carries five arguments — `itemLink`,
`rollQuantity`, `rollType`, `roll`, `isUpgraded`. The old code read a sixth
`rollerId` and compared it to `UnitGUID("player")`. That argument does not exist,
so the comparison never passed and the branch was dead.

**Fix.** The handler reads the real payload. The event only fires for the
player's own win, so there is nothing to filter on.

**Guard.** *own roll win notifies*. The harness previously encoded the same
phantom argument, so it had been validating dead code; its payload is now taken
from the client documentation.

## 8 — Money notifications dead on every non-English client

**Cause.** `HandleMoneyMessage` matched `"(%d+) Gold"` and friends literally.

**Fix.** `Notifications/Looti_Chat.lua` builds patterns from the client's own
`GOLD_AMOUNT`, `SILVER_AMOUNT` and `COPPER_AMOUNT`. Grammar selectors are expanded
into real alternatives rather than wildcards, because `ruRU` distinguishes gold,
silver and copper only by their plural forms — collapsing those to `.-` would make
the three indistinguishable.

**Guard.** *money in other locales* in `settings.lua` parses `deDE`, `ruRU` and
`koKR`.

## 9 — Classic Era crash in the upgrade check

**Cause.** `C_Item.GetCurrentItemLevel` and `ItemLocation` are 8.0+ and were
called unguarded, so they threw on clients without them and killed the whole
notification.

**Fix.** `L.Compat.EquippedItemLevel` feature-detects both and falls back to the
static level from `GetItemInfo` (`Core/Looti_Compat.lua`). No version checks
anywhere in the addon.

**Guard.** *classic era fallback* in `settings.lua` nils both and loots gear.

## 10 — Uncached items were silently dropped

**Cause.** `GetItemInfo` returns nil for an item the client has not cached, and
the code simply returned.

**Fix.** `Core/Looti_ItemCache.lua` resolves on `GET_ITEM_INFO_RECEIVED` and
replays the notification. Entries for items the client never answers are dropped
when the next item is resolved, so no timer is involved. `GET_ITEM_INFO_RECEIVED` is used rather than
`Item:CreateFromItemID` because it exists on every flavour and needs no mixin.

**Guard.** *uncached items* loots an undefined item, confirms nothing shows, then
caches it and confirms it does.

## 11 — A checkbox wrote the wrong setting

**Cause.** The Show Item Level Upgrade Icon checkbox called
`HandleShowItemLevelChange`, so it toggled `showItemLevel`. The correct handler
existed and was never called. One of seventeen near-identical handlers.

**Fix.** There is now one setter. A control's callback reads the key from the
schema entry that built it, so writing another setting's key is not expressible
(`Settings/Looti_Render.lua`).

**Guard.** *every schema key has a default* and *no setting appears twice in the
schema* in `settings.lua`.

## 12 — Two settings had no control at all

**Symptom.** `showText` and `iconSize` could only be changed by hand-editing the
saved variables file.

**Cause.** The staging table was hand-written from seventeen named keys while the
defaults held twenty-one. Nobody noticed the gap. `showText = false` is exactly
the state that triggered defect 1, which is why that crash went unseen for so
long.

**Fix.** Staging is driven by the schema, so a setting without a control cannot
exist. Note the obvious repair — copying the whole config — would have been
wrong: it would stage the frame position too, so saving after a drag would write
back a stale position. Position is state, not a setting, and is excluded by
`L.Db.POSITION_KEYS`.

**Guard.** *every configurable default has a control* and *position is not
staged* in `settings.lua`.

## 13 — Reset was not undoable and there was no Cancel

**Cause.** Reset wrote `LootiConfig` immediately, bypassing the staging buffer,
and left stale values on screen. Closing the window discarded edits only as a
side effect of the buffer being rebuilt on the next open. The filter editor wrote
`LootiFilters` directly, so the Save button silently did not cover it.

**Fix.** Save, Cancel and Reset all act on the staged copy, and Reset redraws the
open tab. The filter editor stages a copy too and applies it on Save
(`Settings/Looti_Panel.lua`, `Settings/Looti_FilterEditor.lua`).

**Guard.** *settings panel staging* and *filter editor staging* in `settings.lua`.

## 14 — Upgrade arrow compared base against effective item level

**Cause.** `GetItemInfo` position 4 is the item's base level, while
`C_Item.GetCurrentItemLevel` returns the effective, scaled level. The two were
compared directly. Invisible on Classic, where they coincide.

**Fix.** Both sides of the comparison go through `L.Compat.EquippedItemLevel`,
which prefers the live level and falls back to the static one consistently.

## 15 — Malformed `.toc` and duplicate workflows

**Cause.** The interface line read
`120007, 50504, 50504, 20506, 38002, 50504, 20506` — `50504` three times, `20506`
twice, `38002` matching no shipped build, and Classic Era missing entirely. Two
GitHub workflows ran on the same cron and overwrote each other's result; one
pushed straight to `main` and failed daily when there was nothing to commit.
`release.yml` also copied the repository into itself.

**Fix.** The interface line is `120007, 50504, 20506, 11507` — retail, Mists
Classic, TBC and Classic Era, deduplicated. The workflow cleanup is not carried
into this folder; it belongs to the repository, not the addon.

## 16 — LibStub was never bundled

**Symptom.** The addon worked for most people and failed completely for some.

**Cause.** `AceGUI-3.0.lua` and twenty-two widget files call
`LibStub:NewLibrary(...)` at load, and no `LibStub.lua` existed anywhere in the
repository. Looti started only when some other installed addon happened to
provide LibStub first. For a player whose only addon was Looti, `LibStub` was nil,
AceGUI threw at load, and the entire addon failed to start.

**Fix.** `Libs/LibStub/LibStub.lua` is bundled and listed first in the `.toc`.

**Guard.** Both suites load the addon with nothing else present. Against the old
addon the harness now fails with
`AceGUI-3.0.lua:29: attempt to index global 'LibStub' (a nil value)`, which is
this defect reproducing.

## 17 — Defaults were aliased, and copies were shallow

**Symptom.** Reset appeared to do nothing, and filter lists came back after being
cleared.

**Cause.** Two faults in one line of setup. `LootiConfig = LootiConfig or
LootiConfigDefault` makes the two the *same table* on a fresh profile, so Reset's
`copyTable(LootiConfig, LootiConfigDefault)` was a self-copy and did nothing for
the whole first session. Worse and not session-bound: `copyTable` was shallow, so
`copyTable(LootiFilters, LootiFiltersDefault)` made `LootiFilters.blacklist` *the
same table* as the default. After any Reset, every filter edit mutated the
defaults, and the next Reset restored the polluted copy — so Reset could never
clear the lists again.

**Fix.** `L.Util.DeepCopy`, `L.Util.ApplyDefaults` and `L.Util.ReplaceContents`
copy at every level, and defaults are never handed out by reference
(`Core/Looti_Util.lua`, `Core/Looti_Db.lua`).

**Guard.** *defaults are copied, not aliased* in `settings.lua` resets twice and
requires the list to be empty both times.

## 18 — A dead saved variable

**Cause.** `LootiNotificationSettings` held three constants, nothing ever wrote
them, and it was declared in `## SavedVariables` — a per-character disk write for
nothing.

**Fix.** The constants live in `L.Const.FRAME` and the saved variable is gone.

## 19 — Another player's money notified as your own

**Symptom.** In a party or raid, Looti announced money every time anyone else
picked some up.

**Cause.** `CHAT_MSG_MONEY` carries other players' money as well — `LOOT_MONEY`
is `"%s loots %s."` — and the money parser searched the whole message for gold,
silver and copper amounts without first checking who the message was about.

**Fix.** Both chat parsers now gate on the literal opening of the client's own
self-directed strings — `YOU_LOOT_MONEY`, `LOOT_MONEY_SPLIT` and their guild
variants for money, `LOOT_ITEM_SELF` for loot. That is one plain-text compare,
so everyone else's messages are rejected before any pattern runs, which also
removes the per-message matching cost in a raid.

**Guard.** *other players' loot and money in a group* in `settings.lua`.

## 20 — A timer ran every ten seconds for the whole session

**Cause.** `Looti_ItemCache` started a ticker at load to drop callbacks for items
the client never answered. It ran every ten seconds for the entire session,
almost always over an empty table.

**Fix.** Pruning happens when the next item is resolved, so nothing of Looti's
runs while the player is not looting. The queue also polled every 0.05 s while
the screen was full; the pacing ticker already calls back, so that poll is gone,
and rows are repositioned directly instead of on a timer.

The only timers left are the two that are features: how long a notification
stays on screen, and the configurable delay between them.

---

## Known limitation

On **itIT** and **koKR** clients, `LOOT_ITEM_PUSHED_SELF` and `LOOT_ITEM_SELF` are
the same string, so a crafted or mailed item cannot be told apart from looted one
and will also notify. The information is not in the message; no addon can do
better from chat alone. Every other locale separates them and item pushes are
ignored. The locale test reports this rather than asserting the wrong behaviour.
