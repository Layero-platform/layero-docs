---
sidebar_position: 2
title: Commands
description: The full list of layero commands — init, login, projects, deploy, rollback, deploys list, link, token.
---

# CLI commands

| Command | What it does |
|---|---|
| `layero init` | Auto-detect the framework, scaffold `.layero/project.json` and add a block for AI agents to `AGENTS.md` / `CLAUDE.md` / `.cursorrules`. |
| `layero login` | Sign in through the browser (GitHub / Yandex ID) — a device flow. |
| `layero logout` | Remove the saved token. |
| `layero whoami` | Show the current account. |
| `layero orgs list` | List your Layero organizations (personal + teams). |
| `layero projects list` | List your projects. |
| `layero link <id_or_slug>` | Link the current directory to an existing project. |
| `layero deploy` | Auto-detect the framework, pack the current directory, deploy. |
| `layero deploy --prod` | Deploy to production (with confirmation). |
| `layero deploy --org <slug>` | Create the new project in the given team instead of your personal organization. |
| `layero deploy --json` | A machine-readable event stream — for agents and CI. |
| `layero deploys list` | Show recent deploys of the current project. |
| `layero promote` | Point the production apex at a specific ready deploy. |
| `layero promote --rollback` | Atomically roll the apex back to the previous production. |
| `layero token set <jwt>` | Set the token by hand (for CI). |

The full flag list for a command:

```bash
npx layero <cmd> --help
```

The global `--json` flag switches the CLI to JSON lines on stdout — that is for
AI agents (Cursor, Claude Code) and CI pipelines. More in
[Deploying from AI agents](./agents).

## `layero init`

Run it once inside the site directory:

```bash
cd my-site
npx layero init
```

What it does:

1. Reads `package.json` and the characteristic configs (`next.config.*`,
   `vite.config.*`, `astro.config.*` and so on) to determine the framework.
2. Creates `.layero/project.json` with `framework_hint` / `build_cmd` /
   `output_dir`. If the file already exists it is left alone.
3. Appends a "Deploying with Layero" block to `AGENTS.md`, `CLAUDE.md` and/or
   `.cursorrules` (whichever exist; if none do, it creates `AGENTS.md`).

The block is fenced with `<!-- layero:start -->` / `<!-- layero:end -->`
markers, so a repeat `init` updates it in place instead of duplicating it.

Flags:

- `--skip-agent-docs` — leave `AGENTS.md` / `CLAUDE.md` / `.cursorrules`
  untouched.
- `-y`, `--yes` — non-interactive (all defaults applied silently).

## `layero orgs list`

Shows the Layero organizations you belong to:

```
borisowvalia        personal  (admin)
acme-team           team      (admin)
client-x            team      (member)
```

* **personal** — your personal account, created at signup.
* **team** — a team, created by hand (in the dashboard or via
  `layero deploy --org=...`).

Under the older naming scheme the organization slug was a prefix of the
hostname (`<org>-<project>.layero.app`). For projects created after the move
the address consists of the project slug alone — see
[Environments, previews and production](../deploys/environments).

## `layero projects list`

Shows every project you have access to.

## `layero link`

Link the current directory to an existing project:

```bash
npx layero link 123          # by id
npx layero link alice-blog   # by slug
```

It creates `./.layero/project.json` pointing at the project. Useful when you
cloned somebody else's repository and want to deploy into your own project, or
moved from another folder.

## `layero deploy`

Pack the current directory and start a deploy. Details in
[`layero deploy`](./deploy).

## `layero deploys list`

Show the project's recent deploys (the default branch unless told otherwise):

```bash
npx layero deploys list                       # the current default branch
npx layero deploys list --branch=staging      # another branch
npx layero deploys list --limit 50            # more history
```

Each line carries the status (`ready`/`building`/`failed`), the commit SHA, a
timestamp and the deploy **source**:

| Badge | What it means |
|---|---|
| `(push)` | Came from a GitHub webhook after a push |
| `(cli)` | Uploaded through `layero deploy` |
| `(manual)` | Started by hand from the dashboard (Redeploy) |

## `layero promote`

Point the project's production apex at a specific ready deploy. Details in
[`layero promote`](./promote).

```bash
npx layero promote                        # default branch → latest ready
npx layero promote --branch=staging       # latest ready of the staging branch
npx layero promote --deploy=a3f9c2b       # a specific commit/deploy
npx layero promote --rollback             # return the apex to the previous production
npx layero promote --yes                  # no confirmation (CI)
```

`layero deploy --promote` is the short path — "build it and ship it to
production straight away", equivalent to
`layero deploy … && layero promote --deploy=<last>`.
