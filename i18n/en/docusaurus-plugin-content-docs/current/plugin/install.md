---
sidebar_position: 2
title: Installing
description: One click in Cursor through a deeplink, copy-paste commands in Claude Code and Codex. What happens after the click and which IDE settings are needed.
---

# Installing `@layero`

## Cursor (one click)

Open [land.layero.app](https://land.layero.app) and press **Add to Cursor**. The
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
codex mcp add layero --url https://mcp.layero.ru/mcp --bearer-token-env-var LAYERO_TOKEN
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

## If your IDE offers to authenticate

Some editors try OAuth first when connecting a remote server — speculatively,
before they know whether it is needed. Layero has none: the server is public
and never returns a 401. The authentication card is safe to dismiss with
**Skip**; the connection works either way.

The token, when you need one, travels in a header rather than through that
dialog. The next section shows how.

## Connecting your account

Installing is enough to build a landing page: picking a structure and a design
system works with no authentication at all. **Publishing needs a token** —
without one, `publish_landing` answers:

```
Layero-токен не передан. Выпустите токен на https://app.layero.ru/settings/cli
и добавьте его в конфиг MCP-сервера: "headers": {"Authorization": "Bearer <токен>"}.
```

Issue a token at [app.layero.ru/settings/cli](https://app.layero.ru/settings/cli)
and pass it as a header in the server config — once per IDE.

**Cursor** — in `~/.cursor/mcp.json`, next to `url`:

```json
{
  "mcpServers": {
    "layero": {
      "url": "https://mcp.layero.ru/mcp",
      "transport": "http",
      "headers": { "Authorization": "Bearer <your token>" }
    }
  }
}
```

**Claude Code** — if you installed the plugin from the marketplace (the way
shown above), set an environment variable: the plugin config already declares
the header as `Bearer ${LAYERO_TOKEN}`, and Claude Code substitutes the value.

```bash
export LAYERO_TOKEN="<your token>"
```

Keep it in your shell profile (`~/.zshrc`, `~/.bashrc`) or it disappears with
the session. If you added the server from the command line instead of
installing the plugin, the command takes a header flag:

```bash
claude mcp add --transport http layero https://mcp.layero.ru/mcp \
  --header "Authorization: Bearer <your token>"
```

**Codex** — the install command above already binds the server to a variable
(`--bearer-token-env-var LAYERO_TOKEN`), so setting it is enough:

```bash
export LAYERO_TOKEN="<your token>"
```

With the variable unset Codex connects without authentication: browsing works,
and publishing answers that no token was passed.

Restart the IDE afterwards so it re-reads the config.

:::tip Why there is no sign-in from the chat
An MCP server keeps no session between calls and cannot open a browser for you
— it only sees the HTTP request the IDE sent. So the account is wired once in
the config rather than by a command inside the conversation.
:::

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
