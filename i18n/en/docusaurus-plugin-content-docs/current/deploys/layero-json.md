---
sidebar_position: 2
title: layero.json — configuration in the repository
description: Override the framework, the build command and the output folder through a file in the repository. Versioned in git, readable by agents (Claude, Cursor), and it beats any dashboard setting.
---

# `layero.json` — configuration in the repository

`layero.json` is an optional JSON file at the root of the repository (or in a
subfolder, for a monorepo). It overrides Layero's auto-detection for **this**
repository and **this** deploy. It is useful when:

- an AI agent (Claude Code, Cursor) sets up the deploy for you — it puts the
  right values into this file in a single PR;
- the configuration has to differ per branch (staging builds differently from
  production);
- the team wants to see in code review who changed the build settings and why.

## A minimal example

```json title="layero.json"
{
  "$schema": "https://layero.ru/schema/layero-v1.json",
  "framework": "nextjs",
  "build": "npm run build",
  "output": "out",
  "node": "20"
}
```

Every field is optional. You can include only what you need to override:

```json title="layero.json — output only"
{
  "$schema": "https://layero.ru/schema/layero-v1.json",
  "output": "bundle"
}
```

Adding `$schema` gives you autocompletion and error highlighting in any IDE that
supports JSON Schema (VS Code, JetBrains, Neovim).

## Fields

### `framework`

The framework name. It overrides Layero's auto-detection. The accepted values
and aliases are in the
[list of supported frameworks](../getting-started/frameworks).

### `build`

The shell command Layero runs to build. It overrides the framework's default.
For example: `"pnpm build:prod"`.

### `install`

The shell command for installing dependencies. The default is your package
manager's reproducible command (`npm ci`, `yarn install --frozen-lockfile`,
`pnpm install --frozen-lockfile`).

### `output`

The path to the folder with the built static files, relative to the project
root. Layero uploads its contents to storage and serves them from the platform
edge. Examples: `dist`, `build`, `out`, `.next`, `dist/app/browser`.

### `node`

The Node version to build with. It overrides `.nvmrc` and `engines.node` from
`package.json`. It accepts a major (`"20"`), a full version (`"20.11.1"`) or an
alias (`"lts"`).

### `runtime` (reserved)

For SSR and runtime apps only (`ssr_node`, `streamlit`, `gradio`, `flask`). Most
static projects do not need this field.

### `env`, `ignore` (reserved)

To be supported in later versions of the schema.

## The override order

On a deploy Layero resolves each field top to bottom, and the first one set
wins:

```
1. layero.json in the repository    (highest priority)
2. The project's dashboard settings
3. Auto-detection from repository signals
4. The framework default            (lowest priority)
```

The deploy log shows where every value came from:

```
[config] framework=nextjs (from layero.json)
[config] node=20.11.1 (from .nvmrc)
[config] build=`npm run build` (from layero.json)
[config] output=out (default for nextjs)
```

## Where the file belongs

- **An ordinary project:** at the repository root.
- **A monorepo:** in the same subfolder the project's `root_directory` points
  at. If the dashboard says `apps/web`, Layero reads `apps/web/layero.json`.

## What the dashboard shows

When `layero.json` is found and valid, Layero shows a blue banner in the setup
wizard and in the deploy log:

> ⓘ Found `layero.json` in the repository. The fields below were filled in from
> that file.

If the file has errors — invalid JSON, unknown fields, empty values — an amber
banner appears with the list of complaints. The deploy does not fail: invalid
fields are ignored and the correct ones are applied.

## The schema URL

```
https://layero.ru/schema/layero-v1.json
```

The URL is stable. Later versions of the schema will be named `v2`, `v3`, and so
on; the old ones keep working.
