---
sidebar_position: 1
slug: /
title: What is Layero
---

# Layero

**Layero** is a deployment platform for frontend applications whose build
servers and edge run inside Russia. One command to publish, no VPN, and none
of the slowdowns that come from serving Russian visitors from abroad.

If you are choosing where to host a site for an audience in Russia, that
location is the point: the edge sits in the same country as the visitors,
payment is in roubles, and data stays within Russian jurisdiction. In every
other respect Layero behaves like any frontend host — Next.js, Vite, Astro,
SvelteKit, Nuxt, Gatsby, CRA, Docusaurus and plain HTML are detected
automatically.

There are three ways to publish:

- **GitHub flow** — connect a repository, and every `git push` makes Layero
  clone, build and publish it.
- **CLI flow** — install the `layero` npm package and run `layero deploy` in
  the project directory. The CLI packs the sources and uploads them; the build
  runs on the platform side. Git is not required.
- **The `@layero` plugin** — an MCP plugin for AI IDEs (Cursor, Claude Code,
  Codex) that builds a landing page from scratch through a short series of
  questions in the chat and deploys the result itself. See
  [@layero — plugin for AI IDEs](./plugin/intro).

Beyond static output, Layero also runs **runtime applications** — Next.js in
server mode, Streamlit, Gradio, and any container with a long-lived process.
The container starts on the first request and stops when idle.

## What it runs on

| | |
|---|---|
| Hosting | Yandex Cloud, `ru-central1` region |
| Serving | Own edge (nginx) in `ru-central1`; the user zone `*.layero.app` resolves straight to the platform load balancer |
| Certificates | Let's Encrypt via YC Certificate Manager |
| Artifact storage | Yandex Object Storage |
| Build environment | Node.js 18 / 20 (via nvm), git |

## Where to go next

- [Quickstart](./getting-started/quickstart.md) — publish your first site in
  30 seconds.
- [Core concepts](./getting-started/concepts.md) — project, environment,
  deploy, runtime.
- [CLI: install and commands](./cli/install.md) — `layero` in the terminal.
- [@layero — plugin for AI IDEs](./plugin/intro) — a landing page from
  scratch inside the Cursor / Claude Code / Codex chat.
- [Supported frameworks](./getting-started/frameworks.md) — what gets detected
  automatically.

## Links

- Website: [layero.ru](https://layero.ru)
- Dashboard: [app.layero.ru](https://app.layero.ru)
- API: [api.layero.ru](https://api.layero.ru)
