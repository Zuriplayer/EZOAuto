# EZOAuto

EZOAuto is a small beta addon for **The Elder Scrolls Online** that adds optional, conservative automations for common UI chores.

The addon is intentionally narrow in scope:

- one LibAddonMenu settings panel;
- English and Spanish localization;
- no side menu;
- no overlay;
- no keybindings;
- no global input interception.

## Beta Status

EZOAuto is currently in beta. Features are designed to be opt-in and reversible, but they should still be tested with your own game setup, especially if you use other UI or inventory addons.

## Requirements

- The Elder Scrolls Online
- LibAddonMenu-2.0

Optional:

- LibChatMessage
- LibDebugLogger / DebugLogViewer

## Features

### Merchant Automation

- Repair equipped gear.
- Sell ornate items when configured.

### Safe Deconstruction

EZOAuto can preview safe deconstruction candidates and prepare ESO's own deconstruction list.

It **does not press the final deconstruction confirmation** and does not destroy items by itself. The final destructive action stays manual.

### Activity Finder

- Optional auto-accept for selected Activity Finder ready checks.
- Optional repeated sound while an Activity Finder ready check is pending.
- No generic group ready checks, votes, invitations, or kick prompts are accepted.

### Group Visibility

- Optional PvE-only management of ESO's native group member nameplates and health bars.
- Optional healer role behavior that can show injured group member health bars using ESO's native health bar setting.
- No custom HUD or overlay is created.

### Environment Automation

- Optional vanity pet dismiss in known trial zones.
- Optional auto-close books, with a second opening of the same book left open so it can be read.

## Safety Boundaries

EZOAuto avoids broad automation and does not:

- create keybindings;
- intercept input;
- add a side menu or persistent overlay;
- accept PvP, vote, kick, or social prompts;
- confirm destructive deconstruction actions;
- sell or repair outside the configured cases.

## Installation

1. Install the required dependency, LibAddonMenu-2.0.
2. Copy the `EZOAuto` folder into your ESO AddOns directory.
3. Enable EZOAuto from the ESO Add-Ons screen.
4. Configure options from the in-game addon settings panel.

## Testing Notes

Before relying on a feature, test it in your own setup:

- addon load without Lua errors;
- `/reloadui`;
- settings panel opens correctly;
- language setting persists;
- checkboxes persist;
- keyboard and gamepad modes remain usable.

## Development Notes

This repository intentionally keeps the addon small and focused. New automation should be backed by verified ESO APIs and should stay opt-in from the settings panel.
