---
sidebar_position: 2
title: Команды
description: Полный список команд layero — init, login, projects, deploy, rollback, deploys list, link, token.
---

# Команды CLI

| Команда | Что делает |
|---|---|
| `layero init` | Авто-детект фреймворка, скаффолд `.layero/project.json` + блок для AI-агентов в `AGENTS.md` / `CLAUDE.md` / `.cursorrules`. |
| `layero login` | Авторизоваться через браузер (по коду на почту или через Яндекс ID) — device-flow. |
| `layero logout` | Удалить сохранённый токен. |
| `layero whoami` | Показать текущий аккаунт. |
| `layero orgs list` | Список Layero-организаций (личная + команды). |
| `layero projects list` | Список ваших проектов. |
| `layero link <id_or_slug>` | Привязать cwd к существующему проекту. |
| `layero deploy` | Авто-детект фреймворка, упаковать cwd, задеплоить (preview по умолчанию). |
| `layero deploy --prod` | Задеплоить в production (с подтверждением). |
| `layero deploy --org <slug>` | Создать новый проект в указанной команде вместо личной. |
| `layero deploy --json` | Machine-readable стрим событий — для агентов и CI. |
| `layero deploys list` | Показать недавние деплои текущего проекта. |
| `layero promote` | Переключить production apex на конкретный ready-деплой. |
| `layero promote <sha>` | Вернуть апекс на конкретный деплой по `commit_sha` — рабочий способ отката, см. [Rollback](./rollback.md). |
| `layero hooks list/create/delete` | Deploy-хуки — URL-токены, по POST на которые запускается сборка (CMS, cron, внешний CI). |
| `layero db list` | Базы организации: имя, слаг, включён ли Data API, объём. |
| `layero db create <имя>` | Завести базу. Строка подключения печатается один раз. |
| `layero db connect <база>` | Подключить проект к базе — строка подключения приедет в его переменные. |
| `layero db sql <база> -c "SQL"` | Выполнить запрос или скрипт в базе. |
| `layero data env` | Адрес и публичный ключ [Data API](/data-api) для фронтенда. |
| `layero token create <имя>` | Выпустить долгоживущий токен для CI и агентов. |
| `layero token list` / `revoke <id>` | Посмотреть и отозвать выпущенные токены. |
| `layero token set <jwt>` | Сохранить токен, полученный иначе. |

Полный список флагов конкретной команды:

```bash
npx layero@latest <cmd> --help
```

Глобальный флаг `--json` переключает CLI в режим JSON-lines на stdout — это для AI-агентов (Cursor, Claude Code) и CI-пайплайнов. Подробнее — [Деплой из AI-агентов](./agents.md).

## `layero init`

Запустите один раз внутри директории сайта:

```bash
cd my-site
npx layero@latest init
```

Что делает:

1. Читает `package.json` и характерные конфиги (`next.config.*`, `vite.config.*`, `astro.config.*` и т.д.) — определяет фреймворк.
2. Создаёт `.layero/project.json` со значениями `framework_hint` / `build_cmd` / `output_dir`. Если файл уже есть — не трогает.
3. Дописывает блок «Deploying with Layero» в `AGENTS.md`, `CLAUDE.md` и/или `.cursorrules` (выбирает существующие; если ни одного нет — создаёт `AGENTS.md`).

Блок огорожен маркерами `<!-- layero:start -->` / `<!-- layero:end -->` — повторный `init` обновит его в месте, не дублируя.

Флаги:

- `--skip-agent-docs` — не трогать `AGENTS.md` / `CLAUDE.md` / `.cursorrules`.
- `-y`, `--yes` — non-interactive (все умолчания применяются молча).

## `layero orgs list`

Показывает Layero-организации, в которых вы состоите:

```
borisowvalia        personal  (admin)
acme-team           team      (admin)
client-x            team      (member)
```

* **personal** — ваш личный аккаунт, создаётся при регистрации
* **team** — команда, создаётся вручную (на дашборде или при `layero deploy --org=...`)

В прежней схеме имён slug организации был префиксом hostname'а
(`<org>-<project>.layero.app`). У проектов, созданных после переезда, адрес состоит из
одного слага проекта — см. [Окружения, preview и production](../deploys/environments.md).

## `layero projects list`

Показывает все проекты, к которым у вас есть доступ.

## `layero link`

Привязать текущую директорию к существующему проекту:

```bash
npx layero@latest link 123          # по id
npx layero@latest link alice-blog   # по slug
```

Создаст `./.layero/project.json` со ссылкой на проект. Полезно, когда вы клонировали чужой репо и хотите деплоить в свой проект, или переехали из другой папки.

## `layero deploy`

Упаковать cwd и запустить деплой. Подробно — [`layero deploy`](./deploy.md).

## `layero deploys list`

Показать последние деплои проекта (по умолчанию — default-ветка):

```bash
npx layero@latest deploys list                       # текущая default-ветка
npx layero@latest deploys list --branch=staging      # другая ветка
npx layero@latest deploys list --limit 50            # больше истории
```

Каждая строка содержит статус (`ready`/`building`/`failed`), commit SHA, время и **источник** деплоя:

| Бейдж | Что значит |
|---|---|
| `(push)` | Пришёл от webhook'а GitHub после push |
| `(cli)` | Загружен через `layero deploy` |
| `(manual)` | Запущен вручную через дашборд (Redeploy) |


## `layero hooks`

Deploy-хук — URL, по `POST` на который запускается сборка. Нужен, когда билд
должен инициировать не человек: публикация в headless CMS, cron, внешний CI.

```bash
layero hooks create strapi-content        # хук на preview, ветка по умолчанию
layero hooks create publish --prod        # хук в production
layero hooks list
layero hooks delete <id>                  # отзывается сразу
```

Команда печатает URL вида `https://api.layero.ru/hooks/<токен>`. Проверено на
живом проекте: `POST` возвращает `202` с `deploy_id` и запускает сборку,
`GET` отдаёт `405` — то есть краулер или случайный переход в браузере сборку
не запустят.

:::warning[URL хука — это секрет]
Кто угодно с этим адресом может запустить сборку. Ротация — удалить и создать
заново; отдельного «обновить токен» нет.
:::

## `layero promote`

Перевести production apex проекта на конкретный ready-деплой. Подробно — [`layero promote`](./promote.md).

```bash
npx layero@latest promote                        # default-ветка → последний ready
npx layero@latest promote --branch=staging       # последний ready ветки staging
npx layero@latest promote a3f9c2b                # конкретный деплой по commit_sha (позиционный аргумент)
npx layero@latest promote --yes                  # без подтверждения (CI)
```

`layero deploy --promote` — короткий путь: «собери и сразу выкати в production», эквивалент `layero deploy ... && layero promote <last-sha>`.


## `layero db`

Базы организации из терминала — чтобы не уходить в браузер посреди работы и
чтобы то же самое умел агент в CI.

```bash
npx layero@latest db list                            # какие базы есть
npx layero@latest db create crm                      # завести
npx layero@latest db connect crm                     # подключить текущий проект
npx layero@latest db sql crm -c "select count(*) from entries"
```

Организация выбирается сама, если она одна; иначе — `--org <slug>`.
База адресуется именем, слагом или id.

:::warning[Строка подключения печатается один раз]
Пароль базы после создания больше не покажет никто — только ротация в панели.
Сохраните вывод `db create` сразу.
:::

`db sql` выполняет и скрипт из нескольких операторов — одной транзакцией, с
результатом по каждому оператору. Отказ называет номер оператора, а не только
текст ошибки Postgres.

## `layero token`

Вход человеком (`layero login`) требует браузера и подтверждения — в CI это
тупик. Для CI и агентов выпускается долгоживущий токен:

```bash
npx layero@latest token create ci                    # read + deploy
npx layero@latest token create ci --scope read       # только чтение
npx layero@latest token list
npx layero@latest token revoke <id>
```

Токен показывается **один раз** — в базе лежит только его хеш. Дальше он живёт
в переменной окружения:

```bash
LAYERO_TOKEN=<токен> npx layero@latest deploy
```

По умолчанию токен умеет читать и деплоить, но не умеет необратимого: удалить
проект, сменить адрес сайта, передать владение, выписать себе новый токен. Для
этого нужен `--scope admin`, и запрашивается он явно.

На машине без браузера (SSH, контейнер, среда агента) обычный вход тоже
работает — `layero login --no-browser` печатает адрес и код, открыть их можно
где угодно.
