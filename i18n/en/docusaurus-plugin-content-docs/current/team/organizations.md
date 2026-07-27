---
sidebar_position: 1
title: Organizations (personal and team)
description: How a personal account differs from a team, when to use which, and how to switch between them.
---

# Organizations

Layero, like Vercel, organises everything around a **scope** — the active
organization. Every project, member, domain and integration belongs to a
specific organization. In the top left corner of the dashboard is the
**OrganizationSwitcher**:

* **Personal Account** — your personal account. Created automatically at
  signup, with your `username` as the slug. One per user; it cannot be deleted
  or renamed to another slug.
* **Teams** — team organizations. Created through **+ Create team** at the
  bottom of the switcher, or on the Team page.

## How personal differs from team

| | Personal | Team |
|---|---|---|
| Who is a member | The owner only | Several people |
| Invitations | No | Yes |
| Roles | — | admin / member |
| GitHub repositories | A personal GitHub account through OAuth | A GitHub Organization through the GitHub App |
| Can be deleted | No (it lives as long as the user does) | Yes |
| Can be renamed | The slug is fixed to the username | The slug can be changed |

**Important:** a personal Layero account is not the same thing as a personal
GitHub account.

* A personal Layero account can be connected to a personal GitHub
  (repositories under `github.com/<login>/…`).
* A Layero team organization connects to a **GitHub Organization** through the
  [GitHub App](./github-app), so that access to repositories does not depend on
  one person.

## Creating a team

1. Click **+ Create team** in the OrganizationSwitcher (or on the Team page →
   "Create a new team").
2. Enter the organization slug. For projects created before the move to
   [`layero.app`](../deploys/environments) it ended up in the site address
   (`<org>-<project>.layero.app`). For new ones the address consists of the
   project slug alone, and the organization slug is only visible in the
   dashboard and the CLI.
3. The team is created and you are its admin.
4. Optionally: connect the [GitHub App](./github-app) and invite members.

## Inviting a member

`/account/team` → pick the team organization → the **"Invite by email"**
section → enter the email and role (admin/member) → create the invite. The CLI
returns a link you can send to the invitee. When they sign in through
GitHub/Yandex with that email, the invite applies automatically.

## Roles

| Role | Can |
|---|---|
| admin | Everything: manage members, settings, projects and billing |
| member | See the team's projects; the role on a specific project is set separately (owner/editor/viewer) |

Organization roles are **separate** from project roles. Being a member of a
team does not automatically make you an editor of a project — that is done on
the Project → Members page.

## Switching scope

The top-bar OrganizationSwitcher persists the active scope in localStorage, so
a refresh returns you to the same organization. Every list (Projects, Deploys,
repositories to import) is filtered by the active organization.

## Transferring a project between organizations

**Project → Settings → Transfer** starts a transfer to a target organization.
An admin of the target accepts the request on the Team page → "Incoming
project transfers". The current owner can be kept as an editor after the
transfer (an option in the transfer form) or lose access.

## From the CLI

Every CLI command works in the context of a Layero organization — your
personal one by default.

### List organizations

```bash
layero orgs list
# borisowvalia        personal  (admin)
# acme-team           team      (admin)
```

### Create a project in a specific team

```bash
# the first layero deploy in a directory creates the project; --org says where
layero deploy --org acme-team
```

If you belong to several organizations and `--org` is not given, the CLI asks
interactively (or takes the personal one under `--yes` / `--config`).

After the first deploy the project is bound to that organization; later
`layero deploy` runs in the same folder use the same team without `--org`.

### Deleting a team

The CLI does not support deleting a team — that is a destructive operation. Do
it from the dashboard: Team → Danger zone → Delete team. The team must be empty
(no active projects).

## GitHub binding

A personal account binds **only** to a personal GitHub account. A team binds to
a personal GitHub **or** to a GitHub Organization. This is enforced on the
backend and in the UI. Details in the [GitHub App](./github-app) page.
