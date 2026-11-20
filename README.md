# AETHER X — Blox Fruits Hub

A modular Luau client-side hub project with a mobile-first interface.

## Project status
**Early foundation / v0.2.0-dev.** The responsive interface, navigation, diagnostics, and conservative fruit-ESP module are in the repository. Gameplay automation is not included until each feature has a clear implementation and test plan.

## Structure
- `src/init.client.luau` — entry point
- `src/Modules/Theme.luau` — shared palette and dimensions
- `src/Modules/UI.luau` — responsive draggable hub interface
- `src/Modules/FruitScanner.luau` — opt-in fruit model highlighting
- `src/Modules/Diagnostics.luau` — runtime status snapshot
- `default.project.json` — Rojo project mapping

## Build
Install Rojo, then run:

```sh
rojo build -o AetherX.rbxlx
```

## Validation
The repository is the source of truth. A successful GitHub commit does not mean the code has been compiled in Roblox Studio or tested in an executor. Those checks must be performed separately.

## Compatibility
Designed with touch and mouse input in mind. Executor compatibility is not guaranteed; the project avoids depending on executor-specific APIs.
