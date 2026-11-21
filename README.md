# AETHER X — Blox Fruits Hub

A modular Luau client-side hub project with a mobile-first interface.

## Project status

**Early foundation / v0.2.0-dev.** The repository currently contains the responsive interface, navigation, diagnostics, and an opt-in fruit ESP scanner. Gameplay automation is intentionally not included until each feature has a clear implementation and test plan.

## Structure

- `src/init.client.luau` — entry point and module wiring
- `src/Modules/Theme.luau` — shared palette and dimensions
- `src/Modules/UI.luau` — responsive draggable hub interface
- `src/Modules/FruitScanner.luau` — opt-in fruit allowlist, streaming-aware detection, marker cleanup
- `src/Modules/Diagnostics.luau` — runtime status snapshot

## Interface behavior

- Navigation includes hover feedback and a short slide-in transition when switching pages.
- The main window can be dragged with touch or mouse and is clamped to the visible viewport.
- The header status reports `UI ONLINE`; it does not imply that gameplay automation modules are complete.
- `default.project.json` — Rojo project mapping
- `rokit.toml` — pinned Rojo toolchain

## Build

Install the project tools with Rokit, then run:

```sh
rojo build default.project.json -o AetherX.rbxlx
```

## Automated validation

GitHub Actions runs on pushes and pull requests to `main`. It:

1. Installs the pinned Luau compiler (0.747).
2. Compiles every `.luau` source file to catch syntax errors.
3. Builds the Rojo project.
4. Verifies that the build artifact is non-empty.

A successful workflow confirms syntax and project packaging only. It does not simulate Roblox services or prove executor compatibility.

## Required in-game validation before closing the foundation stage

- Launch the project in a live Roblox client and confirm the UI mounts without errors.
- Test every navigation tab, close/reopen launcher, and touch/mouse dragging.
- Check layout scaling on a narrow mobile viewport and a desktop viewport.
- Enable Fruit ESP near a known dropped fruit and confirm exactly one marker appears.
- Disable Fruit ESP and confirm all markers and scanner connections are cleaned up.
- Confirm ordinary map objects and NPCs do not receive fruit markers.
- Test fruit replication after the initial scan and verify detection still occurs.
- Respawn the character and confirm the UI/scanner lifecycle remains stable.
- Run Diagnostics and verify the displayed client state is accurate.

## Compatibility

The source is structured as a Rojo client project. It is not yet a standalone executor `loadstring` bundle. Executor packaging and direct testing on Delta Android / Arceus X are separate validation tasks; compatibility is not claimed until those tests are performed.
