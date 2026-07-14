# Changelog

## 0.1.21 - Beta

- Integrated the existing settings panel into `Settings > EZO` when EZOCore is available.
- Preserved the standalone LibAddonMenu panel as a compatibility fallback.
- Declared the runtime lifecycle stage as beta and added the permanent Discord feedback link to the panel header.
- Extended the version helper to validate and update `ezo-addon.json` and its package filename.

## 0.1.20 - Beta

- Reorganized the LibAddonMenu panel into focused functional sections without changing settings or behavior.
- Replaced permanent explanatory paragraphs with contextual section-header tooltips and purple information icons.
- Kept field-specific help available on every setting and synchronized the English and Spanish panel text.

## 0.1.19 - Beta

- Delayed automatic book closing until ESO has opened the lore reader scene.
- Limited the repeated-book reading exception to a short time window instead of keeping it indefinitely.
- Added lightweight Debug Viewer messages for event registration and close results.

## 0.1.18 - Beta

- Added an independent opt-in option to accept ordinary player group invitations.
- Revalidated pending group invitations before acceptance and kept the feature separate from Activity Finder and other social prompts.
- Updated English and Spanish documentation for the new automation.
- Marked the public testing phase as early beta.

## 0.1.17 - Beta

- Added a healer-oriented group visibility option for ESO native injured group health bars.
- Adjusted auto-close books to identify repeated books by ESO book data instead of only the camera interactable.
- Updated public project metadata for beta visibility.
- Updated future-work notes to reflect accepted decisions around deconstruction, finder behavior, chat, pets, and books.

## 0.1.16 and earlier

- Added Activity Finder automations and repeated ready-check sound support.
- Added environment automations for trial vanity pet dismissal and auto-close books.
- Added safe deconstruction preview and queue preparation.
- Added merchant automation foundation.
