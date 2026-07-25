---
sidebar_position: 1
title: Быстрый старт
description: Установите CLI, залогиньтесь и опубликуйте первый сайт за одну команду.
---

# Быстрый старт

За 30 секунд опубликуем локальный фронтенд через CLI. Если вы предпочитаете
автодеплой по `git push`, см. раздел [Деплой из GitHub](../deploys/github.md).

## 1. Поставьте CLI

```bash
npm install -g layero
```

Требуется Node.js ≥ 20.

## 2. Залогиньтесь

```bash
layero login
```

Команда откроет браузер и предложит авторизоваться через **GitHub** или
**Яндекс ID**. После успешной авторизации токен сохраняется в
`~/.layero/config.json` (chmod 600).

## 3. Задеплойте

```bash
cd my-site
layero deploy
```

CLI:

1. Упакует папку в tar.gz, уважая `.gitignore` и `.layeroignore`
   (см. [layero deploy](../cli/deploy.md)).
2. Зальёт архив в Yandex Object Storage.
3. Запустит сборку на стороне платформы.
4. Покажет ссылку на дашборд проекта в [app.layero.ru](https://app.layero.ru).

Первый деплой создаст проект и сохранит ссылку на него в
`./.layero/project.json` — последующие `layero deploy` уйдут в тот же проект.

## 4. Откройте сайт

После завершения сборки CLI напечатает адрес сайта — он живой сразу, ждать
прогрева хоста не нужно.

:::tip Какой адрес получит проект
Платформа переезжает в отдельную зону для пользовательских сайтов —
`layero.app`. Переход идёт волнами по организациям, поэтому адрес будет либо
`https://<project>.layero.app` (новая схема), либо
`https://<organization>-<project>.layero.ru` (прежняя — например,
`https://vasya-my-site.layero.ru`). Точный адрес печатает CLI и показывает
дашборд. Подробнее — в [Окружения и preview-URL](../deploys/environments.md).
:::

## Что дальше

- Поднимите свой проект из GitHub: [Деплой из GitHub](../deploys/github.md).
- Добавьте переменные окружения: [Env vars](../deploys/env-vars.md).
- Подключите свой домен: [Custom domains](../deploys/custom-domains.md).
