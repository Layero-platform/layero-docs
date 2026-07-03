---
sidebar_position: 3
title: Lifecycle & speed
description: "Layero's serverless model: warm responses in ~0.25 s, cold starts in 2–4 s, freeze on idle. Real measurements and what they mean for your app."
---

# Lifecycle & speed

A runtime app on Layero is **serverless**: it doesn't run (or cost
anything) while nobody visits it, and it wakes up on the first request.
Here are the honest numbers.

## Four states

| State | What's happening | Response to a request |
|---|---|---|
| **Hot** | the process is serving traffic | your app's normal speed (~0.1–0.2 s) |
| **Warm** | process frozen in memory (after ~20 s idle) | **~0.2–0.3 s** — instant thaw |
| **Cold** | container stopped, image kept on the node | **~2–4 s** — fresh process start |
| **Archived** | no visits for 30+ days (free tier) | like cold, slightly longer |

These are medians of real platform measurements (July 2026), not
marketing: we continuously probe every app with a synthetic monitor.
Heavy SSR apps can pay more on cold start — that's *your* process's
boot time.

## Why visitors usually don't wait

- **A request is never lost.** While the app wakes up, the request is
  parked on the platform and gets a real response — not an error.
- **GET pages are served from cache instantly.** If a page was opened
  in the last hours, the visitor gets it in ~0.2 s from the edge cache
  while the app wakes in the background.
- **Popular apps are pre-warmed.** The platform automatically keeps
  apps with regular traffic warm.

## What this means for your code

- **Background work outside requests doesn't run.** After ~20 s without
  incoming requests the process is frozen: timers, schedulers
  (`node-cron`, APScheduler), bot long-polling — all pause until the
  next HTTP request. Bots and workers need an always-on process — this
  model doesn't fit them.
- **Long-lived connections** (WebSocket) stay alive while open —
  freezing won't cut them. Once closed, the app goes to sleep as usual.
- **Per-request limit is 60 seconds.** Longer than that gets cut off;
  move heavy work to async processing with polling.
- **The disk is ephemeral** — see [Stateless invariant](./stateless.md).

## Resources

| Tier | RAM | CPU |
|---|---|---|
| Free | 256 MB | 0.25 vCPU |
| Pro | 512 MB | 1 vCPU |

If your app dies with an out-of-memory error (visible in the project
logs as "killed by the OOM killer"), heavy Next.js apps with rich SSR
rendering usually fit in the Pro tier.

## Why not "always on"

An always-running container costs money even when nobody opens the
site. The serverless model lets Layero host your app **cheaply or for
free**: a sleeping project consumes almost nothing, and wakes faster
than alternatives in this class (some competitors' free projects take
30–60 seconds to wake; ours: warm — 0.2–0.3 s, cold — 2–4 s).
