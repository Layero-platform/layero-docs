---
sidebar_position: 5
title: layero promote
description: Перевести production apex на конкретный деплой — из любой ветки, без пересборки. Плюс one-click rollback на предыдущий production.
---

# `layero promote`


:::danger Формы команды проверены 27.07.2026
- Деплой указывается **позиционным аргументом**: `layero promote <commit-sha>`.
  Флага `--deploy=` не существует. Sha берётся из `layero deploys list`.
- **`layero promote --rollback` не существует** — CLI отвечает
  `unknown option`. Про рабочий откат — [Rollback](./rollback).
:::

Перевести production apex проекта на указанный деплой. Двигает указатель `production_deploy_id` — без пересборки, апекс начинает отдавать новый артефакт практически сразу (задержку даёт только короткий кеш на edge, до минуты).

## Зачем

Production-флоу в Layero «как у Vercel»:

1. Push в любую ветку → preview-URL ветки
2. Тестируем, шерим, сравниваем
3. Готовы выкатить — **promote** на тот ready-деплой, который проверили

Без promote'а apex продолжает отдавать предыдущий production. Это страховка от случайных релизов после merge'а в main (если auto-promote выключен для команды).

## Использование

```bash
# promote последнего ready-деплоя default-ветки
layero promote

# promote по commit SHA (первые 7+ символов) или полному deploy id
layero promote a3f9c2b

# конкретная ветка → её последний ready
layero promote --branch=staging

# откат: вернуть apex на прошлый рабочий деплой — по его sha
layero promote <commit-sha>

# CI: без подтверждения
layero promote --yes
```

## Что происходит

1. CLI находит deploy (по позиционному sha, по последнему ready в `--branch`, или по последнему ready в default-ветке).
2. Показывает план:
   ```
   promote plan:
     from: 1743a29  2026-05-08 20:30  v2.4.1 — bugfix release
     to:   ce70191  2026-05-19 07:09  feature: new pricing page
   proceed? [y/N]
   ```
3. После confirm бэкенд:
   - Атомарно обновляет `projects.production_deploy_id` (CTE захватывает старое значение в `previous_production_deploy_id` — для rollback'а).
   - Записывает `promote_events` (audit log: кто, когда, source='cli', prev → new).
   - Инвалидирует resolver-кеш через Postgres NOTIFY.
4. Edge подхватывает новый артефакт сразу; ранее закэшированные ответы обновляются по короткому TTL (до минуты).

## Откат

:::warning `layero rollback` не возвращает апекс
Проверено на живом проекте 27.07.2026: команда печатает `rolled back to <sha>`
и `CDN cache purged`, но двигает только `environments.active_deploy_id`.
`production_deploy_id` остаётся на сломанном деплое — **апекс продолжает
отдавать сломанную версию**.
:::

Рабочий откат — тот же `promote`, только на прошлый sha:

```bash
layero deploys list                # взять commit_sha рабочего билда
layero promote ff0d1b86 --yes      # вернуть на него апекс
```

Платформа хранит на проекте два указателя — `production_deploy_id` и
`previous_production_deploy_id`; второй обновляется при каждом promote, поэтому
предыдущий рабочий деплой всегда видно в истории промоутов. Подробности —
[Rollback](./rollback).

## `--promote` как флаг `layero deploy`

Если хочется одной командой: build → promote, не дожидаясь ready'я в UI:

```bash
layero deploy --branch=hot-fix --promote --yes
```

Билд завершится, CLI автоматом перейдёт в promote и подтвердит. Эквивалентно `layero deploy ... && layero promote <last-sha>`, но без второй ручной команды.

## Ограничения

- Promote можно сделать только на `ready`-деплой с `s3_path` (или зарегистрированным runtime-контейнером).
- Для **runtime**-проектов (SSR Next, Streamlit, Gradio, Flask) promote переключает указатель моментально, но running-инстанс старого билда продолжает отвечать пока его не дёрнут (cold-start триггернёт следующий запрос на новом артефакте).
- Если auto-promote default-ветки **включён**, любой следующий push в default перетрёт ваш ручной promote. Выключите auto-promote в Settings проекта если хотите оставить ручной контроль за production.

## Альтернативы

- В дашборде на странице деплоя — кнопка «Promote to production».
- На странице проекта в Production card — кнопка «Откатить». Она работает на стороне бэкенда и двигает production-указатель, в отличие от CLI-команды `rollback`.
- История промоутов — Project → Deploys → «Promote history» (видно auto vs ui vs cli + кто).

## Как это связано с rollback

Раньше у каждой ветки был свой канонический хост, и `layero rollback` менял
`environments.active_deploy_id` — то есть работал по-веточно. Под V071 модель
доменов стала одна-на-проект, и откат должен двигать **production-указатель**
проекта. CLI-команда за этой сменой не пошла: она осталась на старом,
по-веточном пути, и поэтому апекс не возвращает. Рабочий откат — `promote` на
нужный sha, см. [Rollback](./rollback).
