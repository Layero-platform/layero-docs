---
sidebar_position: 2
title: Expiry & renewal of Pro
description: What happens to your projects, domains, and settings when a Pro subscription ends, and how everything is restored after you pay again. Nothing is deleted.
---

# Expiry & renewal of Pro

Short answer: **nothing is deleted when Pro ends.** The account moves to
Free, and whatever exceeds the Free limits is temporarily **suspended**
(not erased). After you pay again, everything is restored automatically.

## What happens when Pro ends

The account moves to [Free](./plans). All deploys, artifacts, settings,
environment variables, and history stay in place. Only what isn't part of
Free gets suspended:

- **Projects over the limit.** Free allows **5 projects**. If you had more
  on Pro, the **5 oldest** stay active and the rest become "suspended".
- **Custom domains.** These are a Pro capability, so all linked custom
  domains are suspended.

### A suspended project is not a deleted one

A suspended project:

- **stays in the dashboard** with a suspended marker — you can still see it;
- **does not serve its site** — a placeholder page is shown instead
  (HTTP 503);
- **rejects new deploys** until you return to Pro.

Projects within the Free limit (the 5 oldest) keep working normally and are
served on their `*.layero.ru` addresses.

### Custom domain

Only the **domain** is suspended — the project itself is unaffected. The DNS
record and the domain link in Layero are kept, and the project keeps
serving on its `*.layero.ru` address (if it's among the active ones). When
you return to Pro, the domain comes back with nothing to reconfigure.

## Data retention

There is **no** timer after which suspended projects are erased. No
automatic deletion exists — suspended projects are kept indefinitely,
waiting for you to return to Pro.

A project is deleted only if **you** delete it (or delete the whole
account). Subscription expiry has nothing to do with data deletion.

## Grace period

In some cases there is a **7-day** soft window during which Pro features
keep working:

- **A charge failed.** If an auto-renewal payment fails (e.g. insufficient
  funds), you get 7 days — Pro keeps working while the system retries the
  charge.
- **A trial ended.** The same 7-day window applies after a trial expires.

There is **no** grace period if you **cancel** the subscription yourself or
pay one-off without auto-renewal — in those cases the move to Free happens
right at the end of the paid period.

## Paying again restores everything automatically

On a successful Pro payment the account returns to the plan and **all**
previously suspended resources come back — projects, custom domains,
settings. Because nothing was deleted, exactly the same projects and domains
are restored, with nothing to set up again. Sites start serving again
within seconds.

## In short

| Event | What happens |
|---|---|
| Pro ended | Account → Free; projects over 5 and custom domains suspended (not deleted) |
| Sites on `*.layero.ru` | 5 oldest keep working; suspended ones show a placeholder (503) |
| Custom domain | Turned off; the project lives on, DNS and link preserved |
| Deletion by timer | **None.** Suspended projects are kept indefinitely |
| Paying for Pro again | Everything is restored automatically |

:::tip How to avoid downtime
If you keep more than 5 projects or rely on a custom domain, leave
auto-renewal on. Then there are no "Free ↔ Pro" transitions or suspensions
at all.
:::
