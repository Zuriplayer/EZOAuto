# EZOAuto tools

## bump-version.ps1

Updates and checks the visible addon version in:

- `EZOAuto.txt` -> `## Version`
- `EZOAuto.txt` -> `## AddOnVersion`
- `modules/core.lua` -> `EZOAuto.ADDON_VERSION`

Usage:

```powershell
.\tools\bump-version.ps1 -Check
.\tools\bump-version.ps1 -Patch
.\tools\bump-version.ps1 -Version 0.2.0
```
