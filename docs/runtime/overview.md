---
sidebar_position: 1
title: Когда нужен runtime
description: SSR Next.js, любой Node-сервер (Express, NestJS, Fastify), любое WSGI/ASGI-приложение на Python (Django, FastAPI, Flask), Streamlit и Gradio — для приложений с долгоживущим процессом.
---

# Когда нужен runtime

Большинство фронтенд-проектов — статика: после `npm run build` получается
папка с HTML/JS/CSS, и её достаточно положить в хранилище. Это самый быстрый
и самый дешёвый режим Layero.

Но некоторые приложения нельзя превратить в SPA — им нужен **процесс
на сервере**:

- **SSR Next.js** без `output: 'export'`,
- **Node-сервер** — Express, NestJS, Fastify и любой другой, слушающий порт,
- **Python-приложение** — Django, FastAPI, Flask и любое WSGI/ASGI,
- **Streamlit / Gradio** — Python-приложения с веб-интерфейсом.

Для них Layero запускает пользовательский **контейнер**.

## Поддерживаемые пресеты

| `project_type` | Что это |
|---|---|
| `spa` | Статика (по умолчанию). |
| `ssr_next` | Next.js с SSR или API-роутами. |
| `node_web` | **Любой Node-сервер**, слушающий HTTP: Express, Fastify, NestJS, Koa, Hono и другие. |
| `python_web` | **Любое WSGI/ASGI-приложение**: Django, FastAPI, Flask, Starlette, Litestar и другие. |
| `streamlit` | Streamlit-приложение (нужен `app.py`). |
| `gradio` | Gradio-приложение (нужен `app.py`). |

`flask` — устаревшее имя, оставленное для совместимости: это алиас
`python_web`. Новые проекты получают `python_web`.

Пресет выбирается в дашборде проекта (**Project → Runtime type**). Для
каждого используется готовый Dockerfile-шаблон — свой образ собирать не нужно.

### Что определяется автоматически

Тип угадывается по зависимостям — руками выбирать обычно не нужно.

**Python → `python_web`.** Фреймворки: Django, FastAPI, Flask, Starlette,
Litestar, Quart, Sanic, BlackSheep, Falcon, Bottle, Pyramid, CherryPy,
aiohttp, Tornado. Серверы: Uvicorn, Gunicorn, Hypercorn, Daphne. Точка
входа ищется в `app.py`, `main.py` или `manage.py`.

**Node → `node_web`.** Express, Fastify, Koa, NestJS, Hapi, Hono, AdonisJS,
Restify, Polka, Feathers, Sails, h3, Elysia, json-server.

Если вашего фреймворка в списке нет, но приложение слушает HTTP-порт — оно
всё равно запустится: выберите `node_web` или `python_web` в настройках
проекта вручную. Список нужен для автоопределения, а не для ограничения.

## Cold start

Контейнер **поднимается по первому запросу**, обслуживает трафик
и **засыпает при простое**. Это значит:

- Разбуженное из «тёплого» состояния приложение отвечает за **~0.2 с**,
  полностью холодный старт — **4–12 с** в зависимости от стека (Python
  быстрее, Streamlit медленнее). Это медианы реальных замеров; таблица по
  типам приложений и все состояния — в
  [Жизненном цикле](./lifecycle).
- Приложения с регулярным трафиком платформа **прогревает автоматически**.
- В простое проект ничего не стоит по compute — за это serverless и любят.

Выделенный keep-warm (гарантированно без холодных стартов) — платная
настройка в планах.

## Stateless-инвариант

Файловая система контейнера **эфемерна** — это важное ограничение,
которое легко проглядеть. Прочтите [Stateless-инвариант](./stateless.md)
**прежде чем** мигрировать существующее SSR-приложение, использующее
SQLite, файловые сессии или локальный кеш.
