---
sidebar_position: 6
title: Rollback
description: Return the production apex to the previous working deploy with one command. An atomic pointer swap, no rebuild.
---

# Rollback

Return a project's production apex to the **previous** production deploy. No
rebuild, no picking a commit — Layero remembers the old pointer value on every
promote, and rollback simply swaps the two.

## What it is for

You have just promoted a new build and it turns out to have broken production.
You need the working version back immediately.

Rebuilding the previous commit from git history is not idempotent: `npm
install` against today's registry can produce a different `node_modules`
(lockfile drift, transitive republishes). Rollback takes **the same** artifact
that worked before — it is already in S3.

## Usage

```bash
# rollback: return the apex to the previous production
layero promote --rollback

# CI: no confirmation
layero promote --rollback --yes
```

This is equivalent to the "Roll back production" button on the project page in
the UI.

## How it works

Under the hood Layero keeps **two** pointers on the project:

```
projects.production_deploy_id           ── what the apex serves right now
projects.previous_production_deploy_id  ── what it served before the last promote
```

Rollback is an **atomic swap** of those two fields in a single SQL update. The
apex returns to the last working build almost immediately — the only delay is
a short edge cache (up to a minute).

`previous_production_deploy_id` is updated automatically on every promote (UI /
CLI / auto-promote), so there is always somewhere to roll back to.

**Ping-pong stability**: run `layero promote --rollback` twice in a row and you
are back where you started. Handy when you want to roll back, check the old
version and put the new one back.

## What happens

1. The CLI shows the plan:
   ```
   rollback plan:
     from: ce70191  2026-05-19 07:09  feature: new pricing page (current production)
     to:   1743a29  2026-05-08 20:30  v2.4.0 — stable release   (previous production)
   proceed? [y/N]
   ```
2. After you confirm, the backend:
   - atomically swaps `production_deploy_id ↔ previous_production_deploy_id`;
   - writes to `promote_events` (action='promote', source='cli', noting that
     this was a rollback);
   - invalidates the resolver cache through a Postgres NOTIFY.
3. Within a few seconds (the edge cache is up to a minute) the apex serves the
   previous version.

## Limits

- The project needs **at least one** previous promote — otherwise there is
  nowhere to roll back to, and the CLI returns a clear error.
- Rollback moves the project's **production apex**; branch preview URLs are
  untouched — each branch has its own independent deploy history.
- For **runtime** projects (SSR Next, Streamlit, Gradio, Flask) rollback
  switches the pointer instantly, but a running instance of the old build keeps
  answering until it is cycled (the next cold start already uses the older
  artifact).

## Alternatives

- In the UI: Project page → Production card → the "Roll back" button.
- To roll back to a **specific** deploy rather than the previous one:
  `layero promote --deploy=<sha>`. See [`layero promote`](./promote).
- If you want a **rebuild** of the older commit rather than reusing the
  artifact, run an ordinary `layero deploy` with that code, or Redeploy from
  the dashboard.

## How it used to work (before V071)

In the previous model every branch had **its own** canonical hostname, and
`layero rollback` changed `environments.active_deploy_id` per branch. With the
move to "one apex per project" rollback became a project-level operation
rather than an environment-level one. The `layero rollback` command was
removed; use `layero promote --rollback`.
