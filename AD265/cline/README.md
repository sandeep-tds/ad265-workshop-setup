# Cline config for AD265

This folder holds the ready-made Cline configuration for the workshop. The
one-click setup script [`../setup-ad265.bat`](../setup-ad265.bat) installs it
into `%USERPROFILE%\.cline\data` (after cloning MDKApp and before reopening VS
Code) — there is no separate installer to run here.

## What `data/` sets up

- **`mdk-mcp` MCP server** – exposes the `mdk-gen-*` commands used in Exercise 4
  (runs `mdk-mcp --schema-version 26.6`, the package is pre-installed on the
  machine).
- **SAP AI Core provider** (`sapaicore`) – the LLM backend Cline uses.
- **Credentials** (`secrets.json`) – shared workshop SAP AI Core client id/secret.
- Minor global settings (telemetry opt-out, auto-update).
- **`globalState.json`** – marks onboarding as done and pins the active
  provider/model + SAP AI Core endpoints, so Cline opens ready to use instead of
  the "How will you use Cline?" welcome screen.

Anything else Cline needs (chat history, workspace state, logs) is created
automatically on first launch – it is intentionally **not** shipped here.

## Why the setup restarts VS Code

Cline keeps its config in memory while running and writes it back on exit, so
copying files into a **running** VS Code gets clobbered on the next reload. The
setup script sidesteps this by force-closing VS Code first (no write-back),
copying the config (the last write), then relaunching. It backs up any existing
config to `%USERPROFILE%\.cline\data.bak` first, so re-running is safe.

## Note on credentials

`data/secrets.json` contains shared workshop credentials on purpose, so
participants don't have to type anything. These are rotated after the session.
