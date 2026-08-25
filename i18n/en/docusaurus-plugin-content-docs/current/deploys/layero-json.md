---
sidebar_position: 2
title: layero.json — configuration in the repository
description: A file in the repository sets the framework, the install and build commands, the output folder and the Node version. Versioned in git, readable by agents (Claude, Cursor), stronger than any dashboard setting.
---

# `layero.json` — configuration in the repository

An optional file at the root of the repository. It sets what Layero would
otherwise detect on its own, and it lives next to your code — so it travels
with it and can differ per branch.

There is one rule:

> Whatever you set in the file, Layero must apply. Whatever you leave out,
> Layero decides for itself.

The file is useful when:

- an AI agent sets up the deploy for you — it puts the right values in with a
  single PR;
- the configuration has to differ per branch: staging builds differently from
  production;
- the team wants to see in code review who changed the build and why.

## A minimal example

```json title="layero.json"
{
  "$schema": "https://layero.ru/schema/layero-v2.json",
  "framework": "vite",
  "installCommand": "npm ci",
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "nodeVersion": "22"
}
```

Every field is optional, `$schema` included. An empty file is valid too:

```json title="layero.json"
{}
```

It means "decide everything yourself" and breaks nothing.

You can set only what you need to change:

```json title="layero.json — output folder only"
{
  "$schema": "https://layero.ru/schema/layero-v2.json",
  "outputDirectory": "bundle"
}
```

`$schema` enables autocomplete and error highlighting in any editor with JSON
Schema support — VS Code, JetBrains, Neovim. The field does not affect the
build.

## What you can set

### `framework`

Framework name. Wins over auto-detection. Accepted values are in the
[list of supported frameworks](../getting-started/frameworks).

### `installCommand`

The command that installs dependencies. By default Layero uses your package
manager's reproducible-install command: `npm ci`,
`yarn install --frozen-lockfile`, `pnpm install --frozen-lockfile`.

### `buildCommand`

The build command. For example, `pnpm build:prod`.

### `outputDirectory`

The folder holding the built site, relative to the application root. Layero
serves its contents at the project's address. For example: `dist`, `build`,
`out`, `dist/my-app/browser`.

### `nodeVersion`

The Node.js major to build on. Accepts `"22"`, `"22.14.0"` or `"lts"`.

### `startCommand`

The start command for apps Layero runs in a container rather than serving as
files.

## Short names keep working

Four fields have a short form, and it is **not deprecated**: files written with
short names will keep working.

| main name | short |
|---|---|
| `installCommand` | `install` |
| `buildCommand` | `build` |
| `outputDirectory` | `output` |
| `nodeVersion` | `node` |
| `startCommand` | `start` |

If both names for one field end up in the file, the main one is applied and
Layero mentions the other in the build log — staying quiet would be worse: you
would be editing the wrong line.

## What beats what

Per field, independently:

```
layero.json  →  project settings  →  found in the repository  →  framework default
```

The first one set wins. For example, with this `package.json`:

```json
{ "scripts": { "build": "vite build" } }
```

and this `layero.json`:

```json
{ "buildCommand": "npm run build:production" }
```

the build runs `npm run build:production`.

`nodeVersion` has a slightly longer order, because the repository itself can
declare a version:

```
layero.json → project settings → .nvmrc → .node-version → engines.node → Layero default
```

An overridden pin is named in the build log, never applied silently.

The log shows where every value came from:

```
[config] framework=nextjs (from layero.json)
[config] node=22.18.0 (source: layero.json); layero.json overrode .nvmrc=20
[config] build=`npm run build` (from layero.json)
[config] output=out (default for nextjs)
```

## A field from the file is not editable in the dashboard

When a field is declared in `layero.json`, the dashboard shows its value and a
badge with the file name — instead of an edit button. Clicking the badge opens
the file in the repository.

This is deliberate. An open field is a promise that your edit will apply, and
an edit in the dashboard would be undone by the very next build: the file is
stronger. Change such a value where it is set — in the repository.

A locked field is left out of saving too: the dashboard will not write into the
project settings a value that would lose to the file anyway.

## Where the file goes

- **A regular project** — at the repository root.
- **A monorepo** — in the same subfolder the project settings name as the
  application folder. Set `apps/web`, and Layero reads `apps/web/layero.json`.

## An error in the file never fails the build

Layero never refuses to build because of `layero.json`. Anything it could not
read becomes a note in the build log and in the dashboard:

| what is in the file | what Layero does |
|---|---|
| invalid JSON | says so and builds as if the file were absent |
| unknown field name | says so, suggests the closest known one, skips the field |
| empty value | says so, skips the field |
| a `framework` not present in the repository | warns and applies it anyway |

Notes are shown in the setup wizard and on the deploy page, under the contents
of the file itself.

## Schema URL

```
https://layero.ru/schema/layero-v2.json
```

The previous address keeps working and will not be removed:

```
https://layero.ru/schema/layero-v1.json
```

If your repositories point at `v1`, there is no need to change them — the file
is read the same way. New projects are better off with the new address: it
knows the main field names and does not flag as an error what Layero accepts.
