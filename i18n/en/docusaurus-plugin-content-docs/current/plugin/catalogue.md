---
sidebar_position: 3
title: Catalogue of designs and structures
description: 5 design systems (vibes) × 6 landing structures, which combinations work together, and what is used by default.
---

# Catalogue

`@layero` assembles a landing page from two independent axes: the **structure**
(what is being built) and the **design system** (how it looks). Any structure can
be painted with any system; the matcher picks the three closest candidates for
the user's brief.

## Design systems

### `minimal` · Clean sans, light background, blue accent

Inter, a light neutral background, one saturated accent. Plenty of air, square
corners, no shadows. In context it reads like a modern product site of the
Linear or Stripe kind.

**Good for**: SaaS waitlists and demos, corporate masterclasses, technical
events, B2B landing pages.

**Not for**: anything warm, vintage, handmade or personal-brand.

### `editorial` · Magazine, serif, warm

Cormorant Garamond for headings, a cream background, one muted accent. Plenty of
air, square radii, thin dividers. It reads like a long article or a Substack
page.

**Good for**: mentor landing pages, designer portfolios, newsletter waitlists,
book launches, craft workshops.

**Not for**: dev, SaaS, corporate, neon.

### `terminal` · Dark background, monospace, neon accent

JetBrains Mono for labels and markers, dense typography, a neon green accent. No
decoration. It reads like an engineer's notes — signal, not noise.

**Good for**: dev portfolios, open-source projects, technical products,
hackathons.

**Not for**: warm, friendly, decorative or corporate.

### `warm` · Warm palette, soft shapes

Manrope with a cream-and-peach palette, rounded corners (16–24px), pill buttons,
a coral accent. In context it reads like a personal invitation rather than a
product page.

**Good for**: mentoring, workshops for non-technical audiences, wellness,
creative masterclasses, community.

**Not for**: corporate, dark, minimalist or technical products.

### `bold` · Huge typography, dark background, vivid

Space Grotesk, giant display headings, monochrome slabs, one bright accent
(yellow). High contrast, urgency. It reads like a manifesto.

**Good for**: conferences, festivals, product releases, manifestos, large
meetups.

**Not for**: anything quiet, personal-brand or editorial.

## Structures

| Structure | What it is | Compatible systems |
|---|---|---|
| `masterclass` | A landing page for a single masterclass or workshop, collecting submissions | all |
| `portfolio-dev` | A developer's personal page — projects, experience, contacts | `terminal`, `minimal` |
| `portfolio-designer` | A designer's portfolio — case studies with large visuals | `editorial`, `minimal`, `warm` |
| `portfolio-mentor` | A mentor or coach landing page, collecting session requests | `warm`, `editorial`, `minimal` |
| `event` | A conference, meetup or release — a one-pager built around the date | `bold`, `minimal`, `editorial` |
| `saas` | A product collecting waitlist or demo requests | `minimal`, `bold`, `terminal` |

## How the matcher chooses

When you call `@layero ...`, the plugin:

1. Asks about motivation (topic, audience, goal) → determines the **structure**
2. Asks about visual preference (palette, tone, optional references) → builds a
   query
3. Scores every design system against its descriptive metadata:
   - `visual_tags` (warm, mono, neon, serif, …) — +3 per match
   - `mood_keywords` (technical, personal, urgent, …) — +2 per match
   - `description` — +1 for a mentioned token
   - `not_for` — −4 (a sharp penalty)
4. Returns the top three and shows them in the final quiz with previews

## Out of scope: what if nothing fits

The plugin **never refuses**. If the user's topic does not map onto a category —
say, "a landing page for a yoga retreat" — it:

1. Picks the closest structure (`event` for a yoga retreat, since it is a
   one-off gathering)
2. Uses that structure's design system as is
3. Adapts the copy to the real topic
4. Says what it did, in one sentence

More on this in the
["When the user's case doesn't fit"](https://github.com/LayeroInfra/layero-claude/blob/main/SOUL.md#when-the-users-case-doesnt-fit)
section of SOUL.md.
