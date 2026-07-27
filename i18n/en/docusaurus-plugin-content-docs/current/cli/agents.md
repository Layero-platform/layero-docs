---
sidebar_position: 5
title: Deploying from AI agents
description: How Cursor, Claude Code, Aider and other AI agents deploy a site through Layero — no git repository, no browser wizard.
---

# Deploying from AI agents

The Layero CLI is built so that an AI agent (Cursor, Claude Code, Aider,
Continue and the like) can deploy a site **within a single conversation** — no
`git init`, no push to GitHub, no wizard in the dashboard. The only thing the
user does is click one login link.

:::tip Want a landing page built from scratch inside the IDE chat?

The CLI deploys an **existing** project. If the task is the opposite — build a
landing page from a description — see the [`@layero` MCP plugin](../plugin/intro):
one click to install, a short series of questions in the chat, a finished page
on Layero.

:::

## The target scenario

```
User:  deploy this landing page with layero
Agent: On it. Open https://app.layero.ru/cli?code=ABCD-1234 and confirm.
       (user opens the link, clicks "Authorize", returns to the chat)
Agent: ✓ Live at https://my-landing-abc123.layero.app
```

No `git init`, no `gh repo create`, no trip to the dashboard. Afterwards the
user can say "make the button red" and "deploy" again — the site updates at
the same address.

## Teaching the agent what to do

### Option 1 — a project file (the main one)

Run this once in the project directory:

```bash
npx layero init
```

The command appends a block to an existing `AGENTS.md` / `CLAUDE.md` /
`.cursorrules` (or creates `AGENTS.md`). The block contains the device-flow
login recipe (`auth_required` → click → poll), a table of JSON events with
explanations (`detected` / `project_created` / `build_log` / `ready` /
`error`), the list of error codes with remediation (`not_logged_in`,
`auth_expired`, `cli_deploys_disabled`, …) and the rules around `--prod`.

Any modern agent reads those files at the start of a session and knows what to
do without being told.

### Option 2 — cold start (the agent sees Layero for the first time)

With no `AGENTS.md` in the project, the agent works it out from the request.
When the user says "deploy with layero", the agent either:

1. Fetches `https://layero.ru/llms.txt` — the canonical page for AI agents,
   with the recipe ready to follow; or
2. Searches for "layero deploy" and lands on this documentation page.

Both paths lead to the same command: `npx layero deploy`.

## JSON mode

When the CLI runs inside an AI agent it switches to JSON-lines mode
**automatically**. The triggers:

- stdout is not a TTY (always the case in Cursor / Claude Code / any
  subprocess);
- environment variables `CURSOR_AGENT`, `CLAUDECODE`, `LAYERO_AGENT`,
  `LAYERO_JSON=1`;
- an explicit `--json` flag.

In this mode the CLI asks no questions, prints one `{"event":"…"}` line per
action on stdout, and reports errors with a stable `code` and `next_action` —
so the agent can react without parsing prose.

### The event stream

```jsonl
{"event":"auth_required","url":"https://app.layero.ru/cli?code=ABCD-1234","user_code":"ABCD-1234"}
{"event":"authorized","user":"alice"}
{"event":"detected","framework":"vite","build_cmd":"npm run build","output_dir":"dist","confident":true}
{"event":"project_created","project_id":"...","slug":"my-site","organization":"alice"}
{"event":"packing","files":124,"bytes":2401234,"sha256":"abc123..."}
{"event":"uploading"}
{"event":"uploaded","archive_key":"..."}
{"event":"setup_applied"}
{"event":"deploy_started","deploy_id":"..."}
{"event":"stage","name":"install"}
{"event":"build_log","line":"npm install ...","stream":"stdout"}
{"event":"stage","name":"build"}
{"event":"build_log","line":"vite v5.0.0 building...","stream":"stdout"}
{"event":"ready","url":"https://my-site.layero.app/","dashboard_url":"https://app.layero.ru/projects/...","deploy_id":"..."}
```

`url` is the live public site and is reachable straight away — show that one
to the user. `dashboard_url` is the management page, not the site.
`preview_url` and `edge_ready` are legacy fields from the CDN era; do not gate
showing the link on them (see the [JSON events schema](./json-events)).

### Error codes

The full canonical list is in the [JSON events schema](./json-events). In
short:

| `code` | `next_action` | When |
|---|---|---|
| `not_logged_in` | run: layero login | No token in `~/.layero/config.json` |
| `auth_expired` / `auth_timeout` | run: layero login | The user did not confirm the code within 15 minutes |
| `invalid_type` | valid types: vite, next, … | `--type` with an unknown value |
| `project_not_found` | run `layero projects list` | `--project` points at a project that does not exist |
| `project_unlinked` | delete .layero/project.json and re-run | The linked project was deleted on the server |
| `username_missing` | open https://app.layero.ru/onboarding | OAuth succeeded but no username was chosen |
| `no_organization` / `org_membership_missing` | available: foo, bar, … | The account has no such organization |
| `cli_deploys_disabled` | enable in project settings | An admin turned CLI deploys off |
| `deploy_failed` / `deploy_error` / `deploy_timed_out` | inspect logs at … | The build never reached `ready` |
| `auth_required` (`next_action: set_layero_token`) | create a token | CI only: no credentials and no browser to get them from |

## Cold start: what your agent should do

If you are writing a system prompt for an agent (Cursor rules, Claude Code
skills, `CLAUDE.md`), include something like this:

```markdown
## Deployment

If the user asks to deploy a site to Layero:

1. Do NOT create a git repository or push to GitHub. Layero deploys local
   files directly.
2. Run `npx layero deploy --json` from the project root.
3. If output contains `{"event":"auth_required","url":"..."}` — render the
   URL as a clickable link in chat and wait. The user will click it once.
4. Continue waiting for additional JSON events. When you see
   `{"event":"ready","url":"..."}` — show `url` (the live site) to the user.
   It is reachable right away; do not gate on `edge_ready`. Then stop.
5. If you see `{"event":"error","code":"...","next_action":"..."}` —
   follow next_action verbatim.
```

## What not to do

- ❌ `git init` + `gh repo create` before deploying — a detour agents often
  take by analogy with Vercel/Netlify.
- ❌ `npm install -g layero` — global installs frequently fail in an agent
  sandbox. Use `npx layero` or `npm install -D layero`.
- ❌ Opening the dashboard to "finish the setup" — `layero deploy` is fully
  inline; there is no manual browser step between upload and build.
- ❌ Asking the user to run `layero login` separately — `layero deploy`
  starts the device flow itself (`auth_required`) when there is no token.
- ❌ Adding `--prod` for a CLI project. A project created by `layero deploy`
  auto-promotes to its apex on **every** deploy, so the apex is already the
  destination and `--prod` changes nothing. The corollary matters more: a
  plain deploy is **not** a harmless preview — it replaces what visitors see.
  For a publish that leaves the live address alone, use `--branch <name>`.

## The full chain for an agent

A self-contained recipe that works from nothing configured:

```bash
# 1. Create .layero/project.json + AGENTS.md (optional, but handy for later sessions)
npx layero init

# 2. Authenticate (once per machine; the token lands in ~/.layero/config.json)
npx layero login

# 3. Deploy
npx layero deploy --json
```

After `ready`, show the user the URL and stop. Further edits → `npx layero
deploy` again → a new URL.
