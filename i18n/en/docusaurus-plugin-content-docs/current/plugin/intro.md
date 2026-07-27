---
sidebar_position: 1
title: What @layero is
description: An MCP plugin for Cursor, Claude Code and Codex that builds a landing page from two or three short quizzes inside the IDE chat and deploys the result to Layero.
---

# @layero

**`@layero`** is an [MCP](https://modelcontextprotocol.io/) plugin for AI IDEs
that lets you build a finished landing page right in the Cursor / Claude Code /
Codex chat. No editor, no terminal: one install button → an `@layero ...`
conversation → a deployed page.

Unlike the [CLI flow](/en/cli/install), which deploys an **existing** project,
`@layero` creates a landing page **from scratch** off a short brief.

## What is inside

- **5 design systems** — minimal, editorial, terminal, warm, bold. Each one is a
  palette plus typography plus a set of ready components in vanilla HTML and CSS.
- **6 structures** — masterclass, portfolio-dev, portfolio-designer,
  portfolio-mentor, event, saas. Semantic HTML with no inline styles.
- **Composition** — any structure × any design system = a finished landing page.
  Eleven artefacts yield up to 30 distinct pages.
- **A series of quizzes** — the IDE renders native forms (through MCP
  elicitation); the plugin asks about motivation, vibe and integration, then
  picks the three closest design candidates itself.
- **Deploying to Layero** is part of the flow: once the files are generated the
  plugin runs `npx layero deploy --json` through the agent's bash tool.

## Quick start

1. Open [land.layero.ru](https://land.layero.ru) (the install page)
2. Press **Add to Cursor** — the IDE opens and offers to install the MCP server
3. In the IDE chat, write:
   ```
   @layero I want a landing page for a pottery workshop, warm vintage style
   ```
4. Fill in three short forms (taste, tone, where submissions go)
5. Done — the files are in your workspace and the landing page is deployed

## How it works technically

The plugin is a remote MCP server at `https://mcp.layero.ru/mcp`, speaking the
[Streamable HTTP](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#streamable-http)
transport.

```
[ Cursor / Claude Code ]
         │ JSON-RPC over HTTPS
         ▼
[ mcp.layero.ru ]   ← MCP server in Python (FastMCP)
         │
         ├── tools: compose_landing, add_integration, deploy, list_design_systems, list_structures
         ├── prompts: welcome, make_premium, make_friendly, integrate_telegram, ...
         └── resources: layero://soul, layero://playbook/deploy, layero://catalogue
```

## SOUL — the plugin's philosophy

The plugin follows a fixed set of behavioural rules, written down in
[SOUL.md](https://github.com/LayeroInfra/layero-claude/blob/main/SOUL.md):

- **Beautiful landings should take zero effort.** The user thinks about what;
  the plugin thinks about everything else.
- **Asking is a tax. Acting is a gift.** Every question costs the user
  attention. If it can be decided without them, decide it.
- **Confidence over options.** A confident default beats five choices.
- **Static is a feature.** HTML and CSS by default. React plus Vite only when
  real interactivity is needed. No SSR.

## Where to go next

- [Installing the plugin](./install) — buttons for three IDEs plus the manual path
- [Catalogue of designs and structures](./catalogue) — what is available right now
- [Form integrations](./integrations) — Telegram, Google Sheets, custom webhook
