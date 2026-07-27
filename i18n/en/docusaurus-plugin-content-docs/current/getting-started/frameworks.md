---
sidebar_position: 3
title: Supported frameworks
description: Vite, Next.js, Astro, CRA, Nuxt, SvelteKit, Gatsby — what Layero detects automatically and how to set the preset by hand.
---

# Supported frameworks

Layero detects the framework automatically from the contents of
`package.json`, the config files in the root and the lockfile. When
auto-detection gets it wrong, override the choice through
[`layero.json`](../deploys/layero-json), the `layero deploy --type` flag, or
the project settings in the dashboard.

## Auto-detection (static)

The order of checks matters — the first match wins:

| Framework | Signal | Output dir |
|---|---|---|
| **Next.js** (export) | dep `next` | `out` |
| **Nuxt** | dep `nuxt` | `.output/public` |
| **Remix / React Router v7** | dep `@remix-run/*` / `@react-router/*` | `build/client` |
| **SvelteKit** | dep `@sveltejs/kit` + `svelte.config.*` | `build` |
| **Gatsby** | dep `gatsby` | `public` |
| **Astro** | dep `astro` | `dist` |
| **Docusaurus** | dep `@docusaurus/core` | `build` |
| **Storybook** | dep `@storybook/*` | `storybook-static` |
| **VitePress** | dep `vitepress` | `.vitepress/dist` |
| **Vite** | dep `vite` | `dist` (or `outDir` from `vite.config`, if set) |
| **Angular** | dep `@angular/core` or `angular.json` | `dist/{project}/browser` |
| **Create React App** | dep `react-scripts` | `build` |
| **Eleventy (11ty)** | dep `@11ty/eleventy` or `eleventy.config.*` | `_site` |
| **Hugo** | `hugo.toml` or `config.toml` | `public` |
| **Static** | only HTML in the root, no `package.json` | `.` |
| **Generic** | fallback (Manual Mode) | `dist` |

The default build command is `npm run build` (or `yarn build` / `pnpm build`,
depending on the lockfile). Hugo is built with `hugo --gc --minify`, Nuxt with
`nuxt generate`.

## Setting the preset explicitly

Through the CLI:

```bash
layero deploy --type vite
```

Accepted values: `nextjs`, `nuxt`, `remix`, `sveltekit`, `gatsby`, `astro`,
`docusaurus`, `storybook`, `vitepress`, `vite`, `angular`, `cra`, `eleventy`,
`hugo`, `static`, `generic`. Common aliases work too — `next`,
`react-router`, `rr7`, `ng`, `11ty`.

Through [`layero.json`](../deploys/layero-json) in the repository root:

```json
{
  "$schema": "https://layero.ru/schema/layero-v1.json",
  "framework": "vite",
  "build": "pnpm build:prod",
  "output": "bundle"
}
```

`static` means no build at all: whatever sits in the root goes to S3, minus
the ignore rules. Handy for ready-made HTML.

## Runtime applications

Next.js in server mode (without `output: 'export'`), Streamlit, Gradio, Flask
and the like run as containers — a separate mode, see
[Runtime](../runtime/overview).

## Node version

Sources, in priority order:

1. `.nvmrc`
2. `.node-version`
3. `package.json` → `engines.node`
4. Node 20 by default

## Package manager

Determined by the lockfile:

| Lockfile | Manager |
|---|---|
| `yarn.lock` | yarn |
| `pnpm-lock.yaml` | pnpm |
| `package-lock.json`, or none | npm |

:::caution npm and optional dependencies
If your `package-lock.json` was generated on macOS while the build environment
is Linux, `npm ci` can hang for a long time on platform-specific optional
dependencies. If you hit this, commit a lockfile generated on Linux, or switch
to pnpm or yarn.
:::
