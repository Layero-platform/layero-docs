---
sidebar_position: 2
title: Environments, previews and production
description: One stable apex per project, preview-only branches for 24 hours and an explicit promote — the Vercel-like domain model in Layero.
---

# Environments, previews and production

## The core idea

A project has **one stable production address** — the apex. What the apex
serves is decided by the **production pointer**, which moves either
automatically (a push to the default branch, **or** a direct `layero deploy`
upload into a project with no repository — that auto-promotes to the apex) or
by hand (promote from the UI or CLI). Named branches get **temporary preview links** valid for 24
hours and never touch the apex — but they are created by pushing to the
repository, not by a CLI flag: `layero deploy --branch` is ignored and archive
uploads always go to the `cli` environment (see [`layero deploy`](../cli/deploy)).

This is the Vercel-style model: one production, many previews. Every branch is
a full environment with its own deploy history, its own preview URL and its
own settings — but **only one of them at a time** is served at the apex.

## Environment = branch

A push to any branch creates an **environment** with its own build history. An
environment has:

- `branch_name` — the git branch name (or `cli` for archive uploads);
- its own preview URL (24 h TTL);
- `active_deploy_id` — the branch's latest successful build.

CLI deploys always land in the pseudo-branch `cli`, regardless of `--branch`.

## Addresses

### The `layero.app` zone

User sites live in a **separate domain zone**, `layero.app`. Everyone does
this (`vercel.app`, `netlify.app`, `pages.dev`) and for the same reason: user
sites should not live on the platform's brand domain.

The move finished on 26 July 2026 — there are no user sites left on
`layero.ru`.

| | Production address | Branch address |
|---|---|---|
| Project created after the move | `<project>.layero.app` | `<project>-<branch>.layero.app` |
| Project created before the move | `<org>-<project>.layero.app` | `<org>-<project>-<branch>.layero.app` |

The label was **preserved** during the move — only the zone changed. So
projects that existed before 26 July still carry the organization prefix,
while new ones get a short address from the project slug alone.

:::tip Do not guess the address from a template
The real address is shown on the project card in the dashboard and printed by
`layero deploy` (the `url` field in JSON mode). Take it from there.
:::

:::note Old addresses work until 31 August 2026
Everything that used to be at `<...>.layero.ru`, branch addresses and preview
forms included, returns a `301` to the new address, preserving path and query.
Links you have shared keep working. **On 31 August the redirect goes away** —
replace the address wherever it is published: in emails, in profiles, in other
people's articles.
:::

Worth knowing about this zone:

- **Project names are globally unique.** A slug already taken by another
  project on the platform is not available — the address is built from it
  alone.
- **There is no separate preview zone.** A branch address is a flat label in
  the same zone under the same wildcard certificate. Per-deploy addresses with
  a `-<sha7>` suffix are no longer issued — the branch address is what gets
  shared.
- **Custom domains were not affected by the move** — they are attached to an
  environment rather than to the platform zone, and work as they did.

### Three kinds of URL

| URL | When it works | Lifetime | What for |
|---|---|---|---|
| Project production address | right after the first successful deploy | as long as the project lives | **The production apex** — what you show users |
| Branch preview address | right after a successful build of the branch | **24 hours** | Branch preview — for checking and sharing |

The per-deploy URL with a `-<sha7>` suffix existed in the old zone and is no
longer issued: it was needed while the branch address warmed up on the CDN,
and there is no CDN in front of user zones any more.

### The production apex

The canonical address of the project. **One** per project. Covered by the
wildcard certificate of its zone and live right after the first successful
deploy — no waiting for host registration. After that it never goes down:
switching between deploys happens through the `production_deploy_id` pointer,
with no hostname re-registration.

:::note There is no longer a CDN in front of sites
`*.layero.ru` used to sit behind YC CDN, and the first deploy of a new host
waited 5–15 minutes to warm up. Since July 2026 the user zone resolves
**straight to the platform load balancer** (NLB → edge). Three practical
consequences: the address is live immediately; `POST`/`PUT`/`DELETE` work on
the production address itself; so do WebSockets. Routing around the apex via a
preview host, as people used to, is no longer necessary.
:::

The apex serves **whichever deploy `production_deploy_id` points at**. That
pointer is moved by:

- **Auto-promote**: a successful push to the default branch switches the apex
  to the new build automatically (on by default, switched off in the project's
  Settings).
- **Manual promote**: the "Promote" button in the UI or
  [`layero promote`](../cli/promote) from the CLI — onto any ready deploy of
  any branch.
- **Rollback**: one "Roll back" button returns the apex to the previous
  production deploy (an atomic pointer swap, see below).

### Branch preview URLs

Every branch (and CLI uploads) gets a stable URL of the form
`<project-label>-<branch>.layero.app`. It is covered by the wildcard
certificate at the edge and works right after a successful build.

Preview hosts are served with `X-Robots-Tag: noindex` — search engines get the
production address, not every branch.

**24 hours** after the branch's first successful deploy the preview URL
**stops working** (returns 404). This is deliberate, so as to:

- not leave old demo links alive forever (legal and staleness reasons);
- free platform resources from long-abandoned feature branches.

If 24 hours is not enough, pin the preview through the UI ("Pin preview" on
the environment page) — the TTL then lasts until an explicit unpin.

### Per-deploy URLs are gone

A sha suffix used to be appended to the branch address
(`<label>-<branch>-<sha7>.preview.layero.ru`) so a specific commit could be
shared. It existed for the sake of the old zone, where the branch address
warmed up on the CDN and a separate unique host was needed.

In the `layero.app` zone no such address is issued. To show a specific build,
use the branch address — it always serves that branch's current deploy — or
deploy the commit you want into a separate branch.

## The production pointer (V071)

This is the domain logic in one picture. Each branch used to get its own
canonical domain, which scaled badly and matched the production flow badly —
nobody wanted every feature branch to become production automatically. Today:

```
projects.production_deploy_id ──→ deploys (a specific build)
                                       │
                                       ▼
                              environments (any branch)
```

The project's production address always serves **exactly** that `deploy_id`,
regardless of which branch it was built on.

### Auto-promote (on by default)

On a successful push to the default branch (usually `main`) the pointer
switches automatically. This preserves the "push to main = ship to prod" flow
for solo projects.

As the team grows, switch auto-promote off in the project Settings. Every
promote then becomes an explicit click, which prevents accidental production
releases.

### Manual promote

From the UI: the "Promote to production" button on any ready deploy page.

From the CLI:

```bash
# promote the default branch's latest ready deploy
layero promote

# promote a specific deploy by SHA or ID
layero promote a3f9c2b

# ship straight from a dev branch to production in one command
layero deploy --branch=staging --promote
```

Every promote is logged in `promote_events` — who, when, which deploy, through
which channel (UI / CLI / auto). The history is available in the dashboard.

### One-click rollback

On every promote Layero stores the **previous** production deploy in
`previous_production_deploy_id`. The "Roll back production" button performs an
atomic swap of the two fields — the apex returns to the last working build
almost immediately; the only delay is a short edge cache (up to a minute).

```bash
layero deploys list            # find the commit_sha you want
layero promote <commit-sha>   # point the apex back at it
```

⚠️ `layero promote --rollback` does not exist, and `layero rollback` only
moves the environment without bringing the apex back — details and the
verification in [Rollback](../cli/rollback).

Rollback is stable: call it twice and you are back where you started
(ping-pong).

## What the UI shows

On the project page the **Production card** shows what the apex serves right
now:

- Host: the project's production address (always the same one).
- Content: a screenshot of the current production deploy.
- Branch badge: `production` next to the branch whose deploy is pinned.

The branch list below shows all the others with their preview URLs and their
own status.

### Coming Soon

When a project has **never** had a successful production deploy (just created,
the default branch did not build, nothing pushed yet), the apex shows a
"Site coming soon" page instead of a 404 — so a shared link looks like it is
waiting rather than broken.

The same goes for a branch preview URL whose build is still in flight (no
ready deploy for that branch yet).

## Handing links to teammates

A branch preview link is a **public** URL (unless site auth is on). Share it
in any chat or PR comment.

The canonical apex is public too, but it is **production**: it is what you
show users, not QA. Promote is a release action — do it deliberately.
