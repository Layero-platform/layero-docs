---
sidebar_position: 6
title: Rollback
description: How to bring the production apex back to the previous working deploy. What the rollback command actually does, and why you roll back through promote.
---

# Rollback

:::danger `layero rollback` does not bring the apex back
Verified on a live project on 27 July 2026: a deliberately broken build was
deployed, then rolled back.

The command prints `rolled back to <sha>` and `CDN cache purged`, but it only
moves `environments.active_deploy_id`. After it runs,
`production_deploy_id` still points at the broken deploy — **the apex keeps
serving the broken version**.

This is the worst kind of defect: the recovery tool reports success without
recovering, and it fires exactly when production is already down.
:::

## The working way to bring the apex back

The same `promote`, pointed at the earlier sha:

```bash
layero deploys list                 # find the commit_sha of a working build
layero promote ff0d1b86 --yes       # point the apex back at it
```

The argument is **positional**. There is no `--deploy=` flag, and
`layero promote --rollback` does not exist either — the CLI answers
`unknown option`.

`promote` looks the deploy up by `commit_sha`, not by deploy id:
`promote <deploy-id>` returns `no deploy matching …`.

## Why not just rebuild the older commit

Rebuilding a previous commit from git history is not idempotent: `npm install`
against today's registry can produce a different `node_modules` — lockfile
drift, transitive republishes. `promote` reuses **the same** artifact that
worked before: it is already in S3 and is not rebuilt.

## What happens when you promote an older deploy

1. The CLI shows the plan and asks for confirmation:
   ```
   promote plan:
     from: ce70191  2026-05-19 07:09  feature: new pricing page (current production)
     to:   1743a29  2026-05-08 20:30  v2.4.0 — stable release
   proceed? [y/N]
   ```
2. The backend atomically updates `projects.production_deploy_id`, capturing
   the old value into `previous_production_deploy_id`; writes to
   `promote_events` (who, when, source); and invalidates the resolver cache
   through a Postgres NOTIFY.
3. Within a few seconds the apex serves the version you picked — the only delay
   is a short edge cache, up to a minute.

## The two pointers on a project

```
projects.production_deploy_id           ── what the apex serves right now
projects.previous_production_deploy_id  ── what it served before the last promote
```

`previous_production_deploy_id` is updated on every promote (UI / CLI /
auto-promote), so the previous working deploy is always visible in the promote
history: Project → Deploys → "Promote history".

## Limits

- You can only promote a `ready` deploy that has an artifact in storage (or a
  registered runtime container).
- It moves the project's **production apex**; branch preview URLs are
  untouched — each branch has its own independent deploy history.
- For **runtime** projects (SSR Next, Streamlit, Gradio, Flask) the pointer
  switches instantly, but a running instance of the old build keeps answering
  until it is cycled: the next cold start already picks up the right artifact.
- If auto-promote of the default branch is **on**, the next push to it will
  overwrite your manual promote. Turn it off in the project settings if you
  want manual control over production.

## Alternatives

- In the dashboard: the project page → the Production card → the "Roll back"
  button. It works on the backend and does move the production pointer, unlike
  the CLI's `rollback` command.
- If you want an actual **rebuild** of the older commit rather than reusing the
  artifact, run an ordinary `layero deploy` with that code, or Redeploy from
  the dashboard.

## Where the discrepancy comes from

Each branch used to have its own canonical hostname, and `layero rollback`
changed `environments.active_deploy_id` — that is, it worked per branch. With
the move to one-apex-per-project (V071) a rollback has to move the project's
**production pointer**. The CLI command did not follow that change: it stayed
on the old per-branch path. Hence the success report with an unchanged apex.

Related: [`layero promote`](./promote),
[Environments, previews and production](../deploys/environments).
