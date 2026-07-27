---
sidebar_position: 2
title: Installing
description: One click in Cursor through a deeplink, copy-paste commands in Claude Code and Codex. What happens after the click and which IDE settings are needed.
---

# Installing `@layero`

## Cursor (one click)

Open [land.layero.ru](https://land.layero.ru) and press **Add to Cursor**. The
browser fires a deeplink, the IDE opens and shows a dialog:

```
Install MCP Server
  Name:      layero
  Transport: http
  URL:       https://mcp.layero.ru/mcp

  [Cancel]   [Install]
```

After **Install**, Cursor writes the entry into `~/.cursor/mcp.json` itself —
you never edit the file. `@layero` becomes available in the chat.

### What the deeplink contains

If you are curious, the button builds:

```
cursor://anysphere.cursor-deeplink/mcp/install
  ?name=layero
  &config=<base64({"url":"https://mcp.layero.ru/mcp","type":"http"})>
```

Cursor decodes the base64, validates it and applies it.

## Claude Code

Claude Code has no URL protocol, so installing takes two slash commands inside
the IDE:

```
/plugin marketplace add LayeroInfra/layero-claude
/plugin install layero@layero-claude
```

After that, `@layero` is available in the chat.

The same thing from a terminal, if you prefer:

```bash
claude plugin marketplace add LayeroInfra/layero-claude
claude plugin install layero@layero-claude
```

## Codex

Codex has neither a URL protocol nor a built-in marketplace. Installing is one
terminal command:

```bash
codex mcp add layero --url https://mcp.layero.ru/mcp --transport http
```

Restart Codex so that it re-reads `~/.codex/config.toml`.

## The manual path (Cursor)

If you would rather add it by hand — to point at a local server while debugging,
for example — open `~/.cursor/mcp.json` and add:

```json
{
  "mcpServers": {
    "layero": {
      "url": "https://mcp.layero.ru/mcp",
      "transport": "http"
    }
  }
}
```

Restart Cursor. That is all.

## Checking the installation

In the IDE chat, write:

```
@layero hello
```

The plugin should answer with a greeting and offer to start. If nothing happens,
check:

1. **Cursor**: the gear icon at the bottom left → MCP → is `layero` in the list
   of servers, and does it say "connected"?
2. **Claude Code**: `/plugin list` — is `layero@layero-claude` there?
3. **Codex**: `/mcp` in the TUI — does it show `layero` among the connected
   servers?

## Uninstalling

| IDE | Command |
|---|---|
| Cursor | remove the `layero` entry from `~/.cursor/mcp.json` |
| Claude Code | `/plugin uninstall layero` |
| Codex | remove the `[mcp_servers.layero]` block from `~/.codex/config.toml` |
