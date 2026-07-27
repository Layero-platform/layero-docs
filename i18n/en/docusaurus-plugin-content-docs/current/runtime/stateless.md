---
sidebar_position: 2
title: The stateless invariant
description: A runtime container's filesystem is ephemeral. What does NOT work (writing to SQLite, file-based sessions) and how to do it properly.
---

# The stateless invariant

The filesystem of a runtime container on Layero is **ephemeral**. This is a
product boundary of the platform rather than temporary technical debt — Vercel,
Netlify and Cloudflare Workers have the same constraints.

## What "ephemeral" means

- On a **cold start** the container comes up from a clean image. Everything the
  previous instance wrote to the local filesystem is gone.
- The platform may stop the container at any point of idleness (see the
  [Lifecycle](./lifecycle)) — you cannot count on "the file will survive until
  tomorrow" even with regular traffic.
- For fast temporary files there is **`/tmp`** (in-memory, **64 MB**). Its
  contents live only as long as the current instance.

## What does NOT work

- **SQLite with writes** — the database only survives as long as the instance.
- **`node-persist`, `lowdb`, `nedb`** and any other "file databases".
- **File-based sessions** — `express-session` with FileStore, file sessions in
  Flask, Streamlit with a local `~/.streamlit/session.json`, and so on.
- **Writing user uploads to disk** — the file disappears on the next request.
- **An in-process cache shared between requests** for multi-pod deploys — each
  pod cannot see the others' cache.

## What DOES work

- **Read-only SQLite** with content baked into the image.
- **An in-process cache within a single pod** — while the pod lives, the cache
  lives.
- **Temporary files in `/tmp`** within a single request.

## How to do it properly

| Task | Solution |
|---|---|
| Persistent data | An external managed Postgres (YC Managed PostgreSQL, for example). |
| Cache | External Redis (YC Managed Redis). |
| Uploaded files | External S3-compatible storage (Yandex Object Storage). |
| Sessions | A JWT in a cookie, or a Redis store. |

If your application **must** have a local disk, Layero is probably not for
you. The platform does not offer persistent volumes, now or on the roadmap.
