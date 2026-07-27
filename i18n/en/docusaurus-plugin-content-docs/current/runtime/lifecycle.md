---
sidebar_position: 3
title: Lifecycle & speed
description: "Layero's serverless model: warm responses in ~0.2 s, cold starts of 4–12 s depending on the stack, freeze on idle. Real measurements and what they mean for your app."
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
| **Cold** | container stopped, image kept on the node | **~4–12 s** — fresh process start, depends on the stack |
| **Archived** | no visits for 30+ days (free tier) | like cold, slightly longer |

These are medians of real platform measurements, not marketing: we
continuously probe every app with a synthetic monitor. Fourteen days of data
(July 2026), user applications only:

| State | Median | 90th percentile |
|---|---|---|
| Hot | 0.13 s | 0.53 s |
| Warm | 0.20 s | 0.70 s |
| Cold | **10.9 s** | **20.7 s** |

A cold start depends heavily on the stack — it is your process's boot time
plus bringing the container up:

| Kind of app | Median cold start |
|---|---|
| Python (Flask, FastAPI) | 4.5 s |
| Node (Express, Fastify) | 6.1 s |
| SSR Next.js | 9.3 s |
| Streamlit | 11.8 s |

Cold starts are rare: over those same fourteen days there were 8,800 hot
responses against 335 cold ones. But when one happens the visitor waits
seconds, not fractions of a second — plan against that number.

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
30–60 seconds to wake; ours: the warm state answers in 0.2 s, and the
vast majority of requests land in it).
