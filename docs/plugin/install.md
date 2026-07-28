---
sidebar_position: 2
title: Установка
description: Один клик в Cursor через deeplink, copy-paste команды в Claude Code и Codex. Что происходит после клика, какие настройки IDE нужны.
---

# Установка `@layero`

## Cursor (one-click)

Открой [land.layero.app](https://land.layero.app), нажми **Add to Cursor**. Браузер выкинет deeplink — IDE откроется и покажет диалог:

```
Install MCP Server
  Name:      layero
  Transport: http
  URL:       https://mcp.layero.ru/mcp

  [Cancel]   [Install]
```

После `Install` Cursor сам пишет запись в `~/.cursor/mcp.json`. Файл редактировать не надо. В чате становится доступен `@layero`.

### Что внутри deeplink

Если интересно, кнопка строит:

```
cursor://anysphere.cursor-deeplink/mcp/install
  ?name=layero
  &config=<base64({"url":"https://mcp.layero.ru/mcp","type":"http"})>
```

Cursor парсит base64, валидирует и применяет.

## Claude Code

В Claude Code нет URL-протокола, поэтому установка идёт через две slash-команды внутри IDE:

```
/plugin marketplace add LayeroInfra/layero-claude
/plugin install layero@layero-claude
```

После — в чате доступен `@layero`.

## Codex

В Codex нет URL-протокола И нет встроенного маркетплейса. Установка — одна команда в терминале:

```bash
codex mcp add layero --url https://mcp.layero.ru/mcp --bearer-token-env-var LAYERO_TOKEN
```

Перезапусти Codex, чтобы он перечитал `~/.codex/config.toml`.

## Ручной путь (Cursor)

Если хочешь добавить вручную (например, для отладки локального сервера), открой `~/.cursor/mcp.json` и добавь:

```json
{
  "mcpServers": {
    "layero": {
      "url": "https://mcp.layero.ru/mcp",
      "transport": "http"
    }
  }
}
```

Перезапусти Cursor. Готово.

## Подключение аккаунта

Установки достаточно, чтобы собрать лендинг: подбор структуры и дизайн-системы
работает без всякой авторизации. А вот **публикация требует токен** — без него
`publish_landing` отвечает:

```
Layero-токен не передан. Выпустите токен на https://app.layero.ru/settings/cli
и добавьте его в конфиг MCP-сервера: "headers": {"Authorization": "Bearer <токен>"}.
```

Токен выпускается на [app.layero.ru/settings/cli](https://app.layero.ru/settings/cli)
и передаётся заголовком в конфиге сервера — по одному разу на IDE.

**Cursor** — в `~/.cursor/mcp.json`, рядом с `url`:

```json
{
  "mcpServers": {
    "layero": {
      "url": "https://mcp.layero.ru/mcp",
      "transport": "http",
      "headers": { "Authorization": "Bearer <твой токен>" }
    }
  }
}
```

**Claude Code** — если плагин ставился через маркетплейс (способ выше), задай
переменную окружения: заголовок в конфиге плагина уже объявлен как
`Bearer ${LAYERO_TOKEN}`, Claude Code подставит значение сам.

```bash
export LAYERO_TOKEN="<твой токен>"
```

Держи её в профиле оболочки (`~/.zshrc`, `~/.bashrc`), иначе она пропадёт в
следующей сессии. Если сервер добавлялся командой, а не плагином, у команды
есть флаг заголовка:

```bash
claude mcp add --transport http layero https://mcp.layero.ru/mcp \
  --header "Authorization: Bearer <твой токен>"
```

**Codex** — команда установки выше уже связывает сервер с переменной
(`--bearer-token-env-var LAYERO_TOKEN`), так что достаточно задать её:

```bash
export LAYERO_TOKEN="<твой токен>"
```

Если переменная не задана, Codex подключится без авторизации — обзор работает,
а публикация ответит, что токен не передан.

После правки перезапусти IDE, чтобы она перечитала конфиг.

:::tip Почему не логин из чата
MCP-сервер не хранит сессий между вызовами и не может открыть браузер за тебя —
он видит только тот HTTP-запрос, который прислала IDE. Поэтому аккаунт
подключается один раз в конфиге, а не командой внутри диалога.
:::

## Проверка установки

В чате IDE напиши:

```
@layero привет
```

Плагин должен ответить приветствием и предложить начать. Если ничего не происходит — проверь:

1. **Cursor**: нижняя левая шестерёнка → MCP → видишь ли `layero` в списке серверов и статус «connected»?
2. **Claude Code**: `/plugin list` — есть ли `layero@layero-claude`?
3. **Codex**: `/mcp` в TUI — показывает ли `layero` среди подключённых?

## Удаление

| IDE | Команда |
|---|---|
| Cursor | удалить запись `layero` из `~/.cursor/mcp.json` |
| Claude Code | `/plugin uninstall layero` |
| Codex | удалить блок `[mcp_servers.layero]` из `~/.codex/config.toml` |
