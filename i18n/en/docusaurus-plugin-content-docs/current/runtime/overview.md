---
sidebar_position: 1
title: When you need a runtime
description: SSR Next.js, any Node server (Express, NestJS, Fastify), any Python WSGI/ASGI app (Django, FastAPI, Flask), Streamlit and Gradio — for applications with a long-lived process.
---

# When you need a runtime

Most frontend projects are static: `npm run build` produces a folder of
HTML/JS/CSS and putting that in storage is enough. This is Layero's fastest
and cheapest mode.

But some applications cannot be turned into an SPA — they need a **process on
the server**:

- **SSR Next.js** without `output: 'export'`;
- **a Node server** — Express, NestJS, Fastify or any other that listens on a port;
- **a Python application** — Django, FastAPI, Flask, any WSGI/ASGI app;
- **Streamlit / Gradio** — Python applications with a web interface.

For those Layero runs a user **container**.

## Supported presets

| `project_type` | What it is |
|---|---|
| `spa` | Static output (the default). |
| `ssr_next` | Next.js with SSR or API routes. |
| `node_web` | **Any Node server** that listens on HTTP: Express, Fastify, NestJS, Koa, Hono and others. |
| `python_web` | **Any WSGI/ASGI application**: Django, FastAPI, Flask, Starlette, Litestar and others. |
| `streamlit` | A Streamlit application (needs `app.py`). |
| `gradio` | A Gradio application (needs `app.py`). |

`flask` is a legacy name kept for compatibility — it is an alias of
`python_web`. New projects get `python_web`.

The preset is chosen in the project dashboard (**Project → Runtime type**).
Each preset uses a ready-made Dockerfile template — you do not build your own
image.

### What is detected automatically

The type is inferred from your dependencies, so you rarely need to pick it by
hand.

**Python → `python_web`.** Frameworks: Django, FastAPI, Flask, Starlette,
Litestar, Quart, Sanic, BlackSheep, Falcon, Bottle, Pyramid, CherryPy,
aiohttp, Tornado. Servers: Uvicorn, Gunicorn, Hypercorn, Daphne. The entry
point is looked up in `app.py`, `main.py` or `manage.py`.

**Node → `node_web`.** Express, Fastify, Koa, NestJS, Hapi, Hono, AdonisJS,
Restify, Polka, Feathers, Sails, h3, Elysia, json-server.

If your framework is not on the list but the app listens on an HTTP port, it
still runs: pick `node_web` or `python_web` by hand in the project settings.
The list drives auto-detection; it is not a restriction.

## Cold start

The container **starts on the first request**, serves traffic and **goes to
sleep when idle**. Which means:

- Woken from a warm state, an application answers in **~0.2 s**; a fully cold
  start takes **4–12 s** depending on the stack (Python is faster, Streamlit
  slower). These are medians of real measurements; the per-stack table and all
  the states are in [Lifecycle](./lifecycle).
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
