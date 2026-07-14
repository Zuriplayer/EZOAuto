# EZOAuto

EZOAuto is a small beta addon for **The Elder Scrolls Online** that adds optional, conservative automations for common UI chores.

¿Prefieres español? Lee el [README en español](README.es.md).
Support, feedback, bug reports and suggestions: https://discord.gg/ekw8zUAcRm

The addon is intentionally narrow in scope:

- one LibAddonMenu settings panel;
- settings grouped by purpose, with contextual help on each section header and field;
- English and Spanish localization;
- no side menu;
- no overlay;
- no keybindings;
- no global input interception.

## Beta Status

EZOAuto is currently in beta. Features are designed to be opt-in and reversible, but they should still be tested with your own game setup, especially if you use other UI or inventory addons.

## Version Metadata

- Addon version: `0.1.20`
- AddOnVersion: `10020`
- APIVersion: `101049 101050`
- Status: early beta

## Requirements

- The Elder Scrolls Online
- LibAddonMenu-2.0

Optional:

- LibChatMessage
- LibDebugLogger / DebugLogViewer

## Features

All automations are disabled by default and can be enabled independently. Settings are stored per character.

### Merchant Automation

- Sell non-stolen Ornate equipment, Treasure items, and Trash items through independent options.
- Repair equipped gear only, or equipped gear plus repairable gear in the backpack.
- Skip combat, fences, stolen items, locked or protected items, Armory items, companion items, and items without vendor value.

### Group Chat

- Optionally switch the active chat channel to group when joining a group.
- Also applies after `/reloadui` when the character is already grouped.
- Does not open the chat box, send a message, or restore the previous channel when leaving the group.

### Group Invitations

- Optionally accept ordinary invitations to join a player group from any player.
- Revalidate that the same invitation is still pending before accepting it.
- This option is separate from Activity Finder and does not accept group ready checks, duel, trade, Tales of Tribute, vote, or kick prompts.

### Safe Deconstruction

EZOAuto can preview safe deconstruction candidates in Debug Viewer and prepare ESO's own deconstruction list at the universal deconstructor and normal blacksmithing, clothing, woodworking, jewelry, and enchanting stations.

- Choose inventory and, when exposed by ESO, bank and ESO Plus bank sources.
- Choose weapons, armor, jewelry, and glyphs/runes independently.
- Reject stolen, locked, protected, Legendary, Ornate, companion, and non-deconstructable items.
- Reject player-crafted equipment; crafted glyphs remain eligible for the normal extraction workflow.
- Respect the active category filter at the universal deconstructor.

It **does not press the final deconstruction confirmation** and does not destroy items by itself. The final destructive action stays manual.

### Activity Finder

- Independent auto-accept options for normal dungeons, veteran dungeons, Battlegrounds, casual and competitive Tales of Tribute, trials, arenas, Endless Archive, Home Tours, and Exploration when ESO exposes the matching activity type.
- Optional repeated sound while an Activity Finder ready check is pending, with a configurable delay from 2 to 15 seconds.
- A single local sound loop avoids duplicate alerts without modifying or reopening ESO dialogs.
- The Activity Finder options do not accept generic group ready checks, votes, ordinary group invitations, or kick prompts.

### Group Visibility

- Optionally hide ESO's native group member names and health bars while grouped, or only during combat.
- Optional healer role behavior that shows injured group member health bars in PvE even when the combat hiding option is active.
- Managed native values are restored when the condition ends or the option is disabled; PvP areas are left alone.
- No custom HUD or overlay is created.

### Environment Automation

- Optional vanity pet dismiss in known trial zones.
- Optional delayed auto-close for books, with the same book left open when reopened within a few seconds so it can be read.

### Language And Diagnostics

- Automatic client-language selection, or forced English/Spanish addon text.
- Optional technical logging through LibDebugLogger and DebugLogViewer; normal chat is kept for functional messages.

## Safety Boundaries

EZOAuto avoids broad automation and does not:

- create keybindings;
- intercept input;
- add a side menu or persistent overlay;
- accept duel, trade, Tales of Tribute, vote, kick, or other social prompts;
- accept ordinary group invitations unless their separate option is enabled;
- confirm destructive deconstruction actions;
- sell or repair outside the configured cases.

Every automation is opt-in and can be disabled independently from LibAddonMenu.

## Installation

1. Install the required dependency, LibAddonMenu-2.0.
2. Copy the `EZOAuto` folder into your ESO AddOns directory.
3. Enable EZOAuto from the ESO Add-Ons screen.
4. Configure options from the in-game addon settings panel.

The panel groups settings into General, Merchant Automation, Group Automation, Activity Finder, Group Visibility, Environment Automation, Deconstruction, and Debug sections. Hover a purple information icon for section-level context, or an individual field for its specific help.

## Testing Notes

Before relying on a feature, test it in your own setup:

- addon load without Lua errors;
- `/reloadui`;
- settings panel opens correctly;
- language setting persists;
- checkboxes persist;
- ordinary group invitations remain manual when disabled and are accepted when enabled;
- duel, trade, Tales of Tribute, vote, kick, and group ready-check prompts remain untouched;
- keyboard and gamepad modes remain usable.

## Development Notes

This repository intentionally keeps the addon small and focused. New automation should be backed by verified ESO APIs and should stay opt-in from the settings panel.

## License

MIT. See [LICENSE](LICENSE).
