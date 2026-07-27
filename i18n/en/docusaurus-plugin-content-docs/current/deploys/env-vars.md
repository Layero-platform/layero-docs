---
sidebar_position: 3
title: Environment variables
description: Env vars are encrypted with AES-256-GCM and available at build time and inside the runtime container.
---

# Environment variables

Env vars are set in the project dashboard (**Project → Environment
Variables**) or through the API. They are available to the build process and
end up in `process.env`.

## Where they apply

Env vars are injected into the environment **at build time** (the `env` stage
of the builder pipeline, before `install`). This means frameworks that inline
variables into the bundle (Vite, Next.js with `NEXT_PUBLIC_*`, CRA with
`REACT_APP_*`) will see them and bake them into the artifacts.

For **runtime projects** (SSR Next, Streamlit, Gradio) the variables are
additionally passed into the environment of the running container — available
at runtime through the same `process.env` / `os.environ`.

## Security

Values are encrypted in the database with **AES-256-GCM**, with a unique nonce
per record. The encryption key (`ENV_ENCRYPTION_KEY`) is stored separately from
the database and is not reachable from applications. In the UI values are
hidden by default; you can reveal a specific record when viewing.

## What not to store

- **Never commit `.env*`.** `.env`, `.env.local` and the like are in the
  built-in denylist of `layero deploy` and are not uploaded in any case. But if
  they end up in the git repository under the GitHub flow, Layero will clone
  them at the `clone` stage.
- **Production secrets must not go into `NEXT_PUBLIC_*` / `VITE_*` /
  `REACT_APP_*`.** Those prefixes mean "goes into the client bundle". Use them
  only for public values — public API endpoints, analytics tokens and so on.

## CLI / API

The UI is the simplest path. If you need a script:

```bash
curl -X PUT https://api.layero.ru/projects/{id}/env \
  -H "Authorization: Bearer $LAYERO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"vars": [{"key": "API_URL", "value": "https://api.example.com"}]}'
```

(The full API specification is published separately.)
