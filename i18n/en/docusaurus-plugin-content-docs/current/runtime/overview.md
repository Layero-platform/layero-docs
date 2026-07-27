---
sidebar_position: 1
title: When you need a runtime
description: SSR Next.js, Streamlit, Gradio, Flask — for applications with a long-lived process. Cold start, scale-up and presets.
---

# When you need a runtime

Most frontend projects are static: `npm run build` produces a folder of
HTML/JS/CSS and putting that in storage is enough. This is Layero's fastest
and cheapest mode.

But some applications cannot be turned into an SPA — they need a **process on
the server**:

- **SSR Next.js** without `output: 'export'`;
- **Streamlit / Gradio** — Python applications with a web interface;
- **Flask / FastAPI** with server-side rendering.

For those Layero runs a user **container**.

## Supported presets

| `project_type` | What it is |
|---|---|
| `spa` | Static output (the default). |
| `ssr_next` | Next.js with SSR / API routes. |
| `streamlit` | A Streamlit application. |
| `gradio` | A Gradio application. |
| `flask` | A Flask application. |

The preset is chosen in the project dashboard (**Project → Runtime type**).
Each preset uses a ready-made Dockerfile template — you do not build your own
image.

## Cold start

The container **starts on the first request**, serves traffic and **goes to
sleep when idle**. Which means:

- Woken from a warm state, an application answers in **~0.2–0.3 s**; a fully
  cold start takes **~2–4 s** (real platform medians; the details and all the
  states are in the [Lifecycle](./lifecycle)).
- Applications with regular traffic are **kept warm automatically** by the
  platform.
- While idle, a project costs nothing in compute — which is what people like
  serverless for.

Dedicated keep-warm (guaranteed no cold starts) is a paid setting in the
plans.

## The stateless invariant

The container's filesystem is **ephemeral** — an important constraint that is
easy to overlook. Read [The stateless invariant](./stateless) **before**
migrating an existing SSR application that uses SQLite, file-based sessions or
a local cache.
