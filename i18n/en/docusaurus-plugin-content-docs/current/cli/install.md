---
sidebar_position: 1
title: Install and sign in
description: How to install the Layero CLI (npx, project-local or global), sign in through the device flow, and where the token is kept.
---

# Install and sign in

## Install

The Layero CLI ships as the npm package [`layero`](https://www.npmjs.com/package/layero). Prefer `npx` or a project-local install — **without `-g`**:

```bash
# No install, always the latest release (recommended):
npx layero@latest deploy

# Project-local:
npm install -D layero
npx layero deploy

# Global (if you insist; often fails in Cursor / Claude Code over permissions):
npm install -g layero
```

Requires **Node.js ≥ 20**.

:::tip Why not `-g`
Global installs fail inside AI-agent sandboxes (Cursor, Claude Code) because of permissions on `/usr/local`. `npx` and project-local installs work everywhere, and `npx layero@latest` always pulls the current release — no manual updates.
:::

## Sign in

```bash
npx layero login
```

The CLI:

1. Makes one HTTP request to `api.layero.ru` and receives a short code like `5NFW-K2NG`.
2. Prints the URL `https://app.layero.ru/cli?code=5NFW-K2NG` (and tries to open it in a browser when running in an interactive terminal).
3. Polls quietly every 2 seconds until you approve or the 15-minute TTL expires.

In the browser you pick a provider (**GitHub** or **Yandex ID**) — if you have no Layero account yet, it is created automatically on the first OAuth. After you allow access, the CLI receives a JWT and stores it in `~/.layero/config.json` (chmod 600).

:::info The browser and the CLI may be on different machines
This is a device flow (like `gh auth login`, `aws sso login`, AppleTV). The CLI opens no local server on 127.0.0.1 — the exchange goes **through the backend**. So signing in works even when the CLI runs on a remote machine (SSH, Docker, headless CI) while your browser is on a laptop.
:::

Check which account you are signed in as:

```bash
npx layero whoami
```

### If the code expired

Each `user_code` lives **15 minutes**. If you did not confirm in time, the CLI exits with `auth_expired` or `auth_timeout`. Just run `npx layero login` again.

### You have no Layero account

There is no separate sign-up. The first OAuth through GitHub or Yandex creates your Layero account and personal organisation automatically. After signing in you may be asked to pick a username once — it becomes the slug of your personal organisation. For projects created before the move to `layero.app` (26 July 2026) it also ended up in the site address — `<username>-<project>.layero.app`. New addresses consist of the project slug alone.

## Initialise a project

Inside the site directory, run:

```bash
npx layero init
```

The command:

- Auto-detects the framework (Next / Vite / Astro / SvelteKit / Nuxt / Gatsby / CRA / Docusaurus / static)
- Creates `.layero/project.json` scaffolding `framework_hint` / `build_cmd` / `output_dir`
- Appends a "Deploying with Layero" block to `AGENTS.md` / `CLAUDE.md` / `.cursorrules` (when they exist) — so that AI agents in later chat sessions know how to deploy without being told.

Idempotent: running it again updates the existing block rather than duplicating it.

## Where the config lives

| File | Purpose |
|---|---|
| `~/.layero/config.json` | Auth token and API URL. Created by `layero login`. |
| `./.layero/project.json` | Binds the cwd to a project, plus framework/build/output. Created by `layero init` or the first `layero deploy`. |

`~/.layero/config.json` looks roughly like this:

```json
{
  "apiUrl": "https://api.layero.ru",
  "token": "eyJhbGciOi...",
  "user": { "id": 42, "username": "alice", "email": "alice@example.com" }
}
```

`./.layero/project.json` after `init`:

```json
{
  "framework_hint": "vite",
  "build_cmd": "npm run build",
  "output_dir": "dist",
  "analytics_enabled": false,
  "env_vars": {}
}
```

After the first `deploy` it gains `project_id`, `slug`, `organization_slug` and `apex_hostname` — the CLI writes those itself, leave them alone.

## Clearing the token

```bash
npx layero logout
```

Removes the token from `~/.layero/config.json`. It revokes nothing server-side — the JWT stays valid until its TTL expires (7 days). To revoke the session on the server, use `Settings → Active sessions` in the dashboard.

## CI / non-interactive

CI usually has no browser. Get a JWT with `layero login` on a dev machine, copy it out of `~/.layero/config.json` and pass it to CI as a secret:

```bash
# In CI
npx layero token set "$LAYERO_TOKEN"
npx layero deploy --prod --yes --project alice-my-site
```

`layero token set` is the manual escape hatch for CI and dev scenarios. In normal use, sign in with `login`.

## Next

- [CLI commands](./commands.md)
- [`layero deploy`: auto-detection, flags, limits](./deploy.md)
- [Deploying from AI agents (Cursor, Claude Code, Aider)](./agents.md)
- [JSON events: the full event and error-code schema](./json-events.md)
