---
sidebar_position: 4
title: Custom domains
description: Attach a domain you own to a project and Layero issues the Let's Encrypt HTTPS certificate itself — no manual certbot, no steps in the Cloudflare panel.
---

# Custom domains

Every project gets an address from the platform (`<project>.layero.app`, or
`<org>-<project>.layero.app` under the [naming scheme](./environments)). You
can also attach **your own domain**, bought from any registrar — `my-site.ru`
or `shop.my-site.ru`, say. This is not a redirect: your domain genuinely
starts serving the project, with its own HTTPS certificate.

A custom domain behaves like the main address: it shows whichever deploy the
production pointer refers to. Promote and rollback work on it unchanged.

:::note[Beta]
The "Domains" section is currently in beta. It is marked "Coming soon" in the
project sidebar — press the **"Beta"** button in the dialog that opens to
reach the working setup wizard.
:::

## How to connect one

1. Open the project → **Domains** in the sidebar.
2. Enter the domain — `my-site.ru` or `shop.my-site.ru`. Layero works out
   whether it is an apex domain or a subdomain and recognises your registrar
   from DNS.
3. Press **Connect**. A domain card appears with a step-by-step checklist and
   the **two DNS records** you need to add.
4. Open your registrar's control panel, add the records (the wizard shows
   instructions for your specific registrar) and save.
5. There is nothing else to press. Layero checks DNS every 10 seconds, issues
   the certificate and connects the domain by itself. The card updates its
   status in real time.

## Which DNS records are needed

Two. The type of the first depends on whether you have an apex domain or a
subdomain.

| Domain | The "points at" record | The verification record |
|---|---|---|
| Apex (`my-site.ru`) | `A` → Layero's IP address | `TXT` `_layero-verify` |
| Subdomain (`shop.my-site.ru`) | `CNAME` → `cname.layero.ru` | `TXT` `_layero-verify.shop` |

The exact values (the IP address, the TXT value) are shown on the domain card
— each is copied in one click.

No third record is needed for the certificate: Layero verifies domain
ownership over HTTP as soon as the domain starts pointing at the platform.

### Apex domain and subdomain

- **Apex domain** (`my-site.ru`) — needs an `A` record to Layero's IP. The DNS
  standard forbids a `CNAME` at the zone apex, so `A` it is.
- **Subdomain** (`shop.my-site.ru`, `test.my-site.ru`) — a `CNAME` to
  `cname.layero.ru`. A subdomain at any depth (`api.v2.my-site.ru` too) works
  the same way.

A subdomain via `CNAME` is in fact more robust: if Layero's infrastructure
changes IP, subdomains follow automatically and nothing needs rewriting.

## Instructions for your registrar

The wizard picks step-by-step instructions for the popular registrars:
**REG.RU**, **Cloudflare**, **Beget**, **GoDaddy**, **Namecheap**. For the
rest there are generic instructions and support.

A few things worth knowing:

- **REG.RU with hosting.** If the domain's NS servers are
  `ns1.hosting.reg.ru`, DNS records are edited **not on the domain card** but
  in the hosting panel (ISPmanager). The wizard walks you through that path.
  For the apex leave the "Name" field **empty** — ISPmanager fills in the
  domain itself.
- **Cloudflare.** Set the added records to Proxy status → **"DNS only"** (the
  grey cloud). The orange cloud (proxy) breaks our TLS — Cloudflare will try
  to substitute the certificate.
- **TXT without quotes.** Paste the TXT value as-is, without surrounding
  quotes — most panels add them themselves.

## Common problems

- **The registrar's parking records.** Many registrars add their own "parking"
  `A` and `AAAA` records when a domain is bought. Those must be **deleted**,
  otherwise the domain opens intermittently — some requests go to the parking
  page.
- **The `AAAA` record (IPv6).** Layero is IPv4-only for now. Any `AAAA` record
  on the domain breaks certificate issuance (Let's Encrypt prefers IPv6) —
  remove it. The wizard warns you if it sees one.
- **DNS does not update instantly.** After you save at the registrar, records
  propagate in 5 minutes to an hour. Layero waits by itself — you do not need
  to keep the page open.

## How long it takes

| Step | Time |
|---|---|
| DNS propagation at the registrar | 5 minutes – 1 hour |
| Ownership check + Let's Encrypt issuance | 30–90 seconds once DNS is visible |
| Attaching to the server | ~10 seconds |

In total: from a couple of minutes to an hour, and nearly all of it is waiting
on DNS at your registrar — something Layero cannot influence.

## Bring your own certificate (BYOC)

If you already have a TLS certificate for the domain (an EV certificate from
your provider, for instance), you can upload it instead of issuing one through
Let's Encrypt. The domain card has an **"I already have a certificate"**
section: paste the PEM certificate and the private key. HTTPS works
immediately, with no call to Let's Encrypt. Domain ownership verification (the
`TXT` record) is still required.

## Where the domain points

By default a custom domain shows the project's production deploy — the same as
the main address. On the domain card, under **"Where this domain points"**,
you can attach the domain to a **specific branch** — handy for putting the
`staging` branch on its own subdomain, for example.

## Certificate renewal

A Let's Encrypt certificate is valid for 90 days. Layero **renews it
automatically** roughly 30 days before expiry — without your involvement and
without downtime. Manually uploaded (BYOC) certificates you renew yourself.

## What Layero does not do

- **It does not buy domains.** Register them with any registrar.
- **It does not manage your DNS zone.** Layero gives exact instructions, but
  you add the records.
- **It does not set up a `www` ↔ apex redirect.** That is handled at the
  registrar or in the application.

## Detaching

The domain card has a cross in the top right corner. Layero removes the
certificate and the configuration. Remove the DNS records in your own zone by
hand.
