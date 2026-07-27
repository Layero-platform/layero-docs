---
sidebar_position: 4
title: Form integrations
description: A Telegram bot, Google Sheets or a custom webhook — where submissions from the landing page can go.
---

# Form integrations

Every landing page from `@layero` includes a form. Where the data goes is chosen
by the user in the third quiz.

## Telegram

Submissions arrive in a chat or a group through a bot.

**What the user provides**:

1. A bot token from [`@BotFather`](https://t.me/BotFather)
2. The id of the chat to send to (through `@RawDataBot` — send it any message
   and it replies with the chat_id)

**What the plugin does**:

1. Creates a small relay on FastAPI (`forms-relay/main.py`)
2. Deploys it as a Layero runtime app
3. Sets the env vars `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`
4. Puts the relay URL into the landing page's `<form action>`

The user does not have to configure CORS, run their own API or stand up a
server — Layero does that in one move.

## Google Sheets

Submissions become new rows in a Google spreadsheet. No backend of your own.

**What the user provides**:

1. Create an empty spreadsheet
2. **Extensions** → **Apps Script** → paste the code (the plugin generates it
   for the right fields)
3. **Deploy** → **Web app** → **Access: anyone** → copy the URL
4. Paste the URL back into the chat

**What the plugin does**:

1. Generates the Apps Script for the form's columns (timestamp, name, email,
   message, …)
2. Writes the Web App URL into `<form action>`
3. Adds a little JS for a thank-you state without a reload

CORS is not needed — Apps Script accepts
`application/x-www-form-urlencoded` without a preflight.

## Custom webhook / Notion / HubSpot / your own API

If the user already has an endpoint or a service (Notion, HubSpot, ConvertKit,
Airtable, their own backend), the plugin works like this:

| What the user has | What the plugin does |
|---|---|
| A webhook URL | Writes it into `<form action>` — done |
| A public form embed (Mailchimp, HubSpot, and so on) | Extracts the action URL from the embed code and mirrors the field names |
| An API key for a service | Stands up a Layero relay (as with Telegram), keeps the key in env vars and forwards the payload |
| Their own backend | One question — "which fields does it expect?" — then fills in the names |

## When integration = `skip`

The user can skip the integration step outright. In that case `<form action>` is
set to the placeholder `{{FORM_ACTION}}`, and they can configure it later by
calling `@layero add-integration ...` again.
