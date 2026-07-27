---
sidebar_position: 6
title: JSON events schema
description: The full list of events and error codes the Layero CLI emits on stdout in JSON mode. The canonical reference for AI agents and CI.
---

# JSON events schema

The CLI switches to JSON-lines mode automatically when it runs inside an AI
agent (Cursor, Claude Code) or when stdout is not a TTY. You can also turn it
on explicitly with the `--json` flag or `LAYERO_JSON=1`.

In this mode the CLI:

- **asks no questions** — every interactive confirmation is skipped (`--prod`
  still needs `--yes`);
- prints one `{"event":"…", …}` line per action on stdout;
- reports errors with a stable `code` and a `next_action`;
- adds a `ts` field (ISO-8601 timestamp) to every event.

## Events

Each line is a standalone JSON object. Route on the `event` field.

### `auth_required`

The CLI has started the device-flow login. Show the URL to the user as a
clickable link.

| field | type | note |
|---|---|---|
| `url` | string | e.g. `https://app.layero.ru/cli?code=ABCD-1234` |
| `user_code` | string | e.g. `ABCD-1234` — also shown on the confirmation page |

The CLI keeps polling every 2 seconds. Once the user confirms, `authorized`
follows. On expiry you get `error{code: "auth_expired" | "auth_timeout"}`.

### `authorized`

Login succeeded.

| field | type |
|---|---|
| `user` | string — username, email or user id |

### `detected`

Framework auto-detection finished.

| field | type |
|---|---|
| `framework` | string — `next`/`vite`/`astro`/`sveltekit`/`nuxt`/`gatsby`/`cra`/`docusaurus`/`static` |
| `build_cmd` | string |
| `output_dir` | string |
| `confident` | boolean — `false` for the static fallback |

### `project_created`

First deploy in this directory. A new project was created.

| field | type |
|---|---|
| `project_id` | string |
| `slug` | string |
| `organization` | string — organization slug |

### `project_linked`

Deploy into an existing project (cwd is linked via `.layero/project.json`).

| field | type |
|---|---|
| `project_id` | string |
| `slug` | string |

### `packing`

The CLI packed the directory into a tar.gz.

| field | type |
|---|---|
| `files` | number |
| `bytes` | number |
| `sha256` | string |

### `uploading`

Archive upload to S3 started. No extra fields.

### `uploaded`

Upload succeeded.

| field | type |
|---|---|
| `archive_key` | string |

### `prebuilt`

The deploy ships a ready-made build (`--prebuilt <dir>`) — installing
dependencies and building on the platform side are skipped.

| field | type |
|---|---|
| `dir` | string — the directory holding the artifact |

### `runtime_type_applied`

The project was recognised as a runtime application and its type was set
automatically.

| field | type |
|---|---|
| `project_type` | `ssr_next` · `node_web` · `python_web` · `streamlit` · `gradio` · `flask` |

### `runtime_type_apply_failed`

The type was detected but could not be applied. The deploy continues with the
project's previous type.

| field | type |
|---|---|
| `error` | string |

### `setup_applied`

Project settings (`framework_hint` / `build_cmd` / `output_dir`) were applied
on the first deploy. No fields.

### `deploy_started`

The backend accepted the job.

| field | type |
|---|---|
| `deploy_id` | string |

### `stage`

The build moved to a new stage.

| field | type |
|---|---|
| `name` | `clone`/`install`/`build`/`upload`/`activate` |

### `build_log`

One line of build output. Only worth forwarding to the user when it contains
an error — successful builds produce a lot of noise.

| field | type |
|---|---|
| `line` | string |
| `stream` | `stdout`/`stderr` |

### `ready`

**The final event.** The deploy is live. Show `url` to the user and stop.

| field | type | note |
|---|---|---|
| `url` | string | **The live public address of the site** — not the dashboard. For a plain `layero deploy` of a CLI project this is the project's production address (CLI uploads auto-promote to the apex). For a deploy into a named branch (`--branch`) it is that branch's preview address. It is reachable straight away; this is the link to open and to show the user. |
| `dashboard_url` | string? | The project management page (`https://app.layero.ru/projects/<id>`). This is **not** the site — never hand it over as the link to the finished site. |
| `preview_url` | string? | **Legacy, no longer emitted.** A separate per-deploy preview host in the `*.preview.layero.ru` zone. It existed to give out a link while the apex warmed up on the CDN. `layero.app` has no separate preview zone and no user sites remain on `layero.ru`, so the field is never populated. |
| `edge_ready` | bool? | Whether the address answers at the moment the deploy finishes. The field used to mean "the apex warmed up on the CDN" and stayed `false` forever for new hosts; it now comes from a real probe. You still should not gate on it — the address is live immediately. |
| `edge_eta_seconds` | number? | **Legacy, no longer emitted.** An estimate of the remaining CDN warm-up. There is nothing to propagate — user sites do not sit behind a CDN. |
| `deploy_id` | string | |

### `promoted`

The apex now points at the given deploy. Emitted by `layero promote` and by
`layero deploy --promote`.

| field | type |
|---|---|
| `url` | string — the public address |
| `deploy_id` | string |

### `error`

| field | type |
|---|---|
| `code` | string — see the table below |
| `next_action` | string — the concrete command or URL that resolves it |
| `message` | string — human-readable description |

## Error codes

| `code` | When it happens | What to do (`next_action`) |
|---|---|---|
| `not_logged_in` | No token in `~/.layero/config.json` | `run: layero login` |
| `auth_required` | CI only: no credentials and no browser to obtain them | Create a token at app.layero.ru/settings/cli and pass it as `LAYERO_TOKEN` |
| `auth_expired` | The `user_code` expired (15 min TTL) without confirmation | Run `layero login` again |
| `auth_timeout` | The CLI polled for 15 minutes and the user never confirmed | Run `layero login` again |
| `invalid_type` | `--type` with an unknown value | Drop the flag (rely on auto-detection) or pass a valid preset |
| `invalid_choice` | An interactive prompt got an invalid choice in non-TTY mode | Pass the value as an explicit flag (`--org`, `--project`) |
| `project_not_found` | `--project` points at a project that does not exist | `run: layero projects list` |
| `project_unlinked` | The linked project was deleted on the server | Delete `.layero/project.json` and run deploy again |
| `username_missing` | OAuth succeeded but no username was chosen | Open `https://app.layero.ru/onboarding` |
| `org_membership_missing` | `--org` points at an organization that is not yours | Pass a correct slug or drop the flag |
| `no_organization` | The account has no organizations at all | Finish onboarding in the dashboard |
| `cli_deploys_disabled` | An admin turned CLI deploys off for the project | Enable it in Project Settings → CLI deploys |
| `deploy_failed` | The build failed | Open the deploy URL from `message` and read the logs |
| `deploy_error` / `deploy_canceled` / `deploy_timed_out` | The build never reached `ready`, for various reasons | See the message |
| `internal` | An unexpected CLI error | Re-run with `--debug` and open an issue |

## Cold-start template for an agent

A minimal behavioural block to drop into a system prompt:

```text
If user asks to deploy via Layero:
  1. Run: npx layero@latest deploy --json
  2. Parse each stdout line as JSON, route on .event:
     - "auth_required" → render .url as clickable link, keep waiting
     - "ready" → show .url (the live site) to user. It is reachable right
                 away — do NOT gate on .edge_ready. Then stop.
     - "error" → follow .next_action verbatim
  3. Never run `git init`. Never run `npm install -g layero`.
```

A fuller example is in [Deploying from AI agents](./agents).
