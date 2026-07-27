#!/usr/bin/env python3
"""Проверяет внешние ссылки в исходниках документации.

Зачем отдельный скрипт. Docusaurus умеет `onBrokenLinks: throw`, но только
для ВНУТРЕННИХ ссылок — внешние он не трогает вовсе. За счёт этого в доках
жила ссылка на файл в приватном репозитории (`LayeroInfra/core/.../init.ts`),
отдававшая 404 каждому читателю, и никакая сборка на это не жаловалась.

Политика падений намеренно узкая: валим сборку только на 404/410 — это
однозначное «страницы нет». 403, 429 и таймауты печатаем предупреждением и
идём дальше: их выдают защиты от ботов (npmjs.com отвечает 403 на любой
скриптовый запрос) и сетевые флапы, а красная сборка из-за чужого
рейт-лимита обесценивает проверку — её начнут игнорировать.
"""
from __future__ import annotations

import concurrent.futures
import os
import re
import sys
import urllib.error
import urllib.request

ROOTS = [
    "docs",
    "blog",
    "src/pages",
    "i18n/en/docusaurus-plugin-content-docs/current",
    "i18n/en/docusaurus-plugin-content-pages",
]
UA = {"User-Agent": "Mozilla/5.0 (compatible; layero-docs-linkcheck)"}
FATAL = {404, 410}
LINK_RE = re.compile(r"\]\((https?://[^)\s]+)|<(https?://[^>\s]+)>")


def collect() -> dict[str, set[str]]:
    found: dict[str, set[str]] = {}
    for root in ROOTS:
        for dirpath, _, files in os.walk(root):
            for name in files:
                if not name.endswith((".md", ".mdx")):
                    continue
                path = os.path.join(dirpath, name)
                text = open(path, encoding="utf-8").read()
                for a, b in LINK_RE.findall(text):
                    url = (a or b).rstrip(".,;:")
                    found.setdefault(url, set()).add(path)
    return found


def check(url: str) -> tuple[str, int]:
    try:
        resp = urllib.request.urlopen(
            urllib.request.Request(url, headers=UA), timeout=25
        )
        return url, resp.status
    except urllib.error.HTTPError as exc:
        return url, exc.code
    except Exception:
        return url, 0


def main() -> int:
    links = collect()
    print(f"внешних ссылок: {len(links)}")

    fatal, warn = [], []
    with concurrent.futures.ThreadPoolExecutor(8) as pool:
        for url, status in pool.map(check, links):
            if status in FATAL:
                fatal.append((status, url))
            elif status >= 400 or status == 0:
                warn.append((status, url))

    for status, url in sorted(warn):
        print(f"  предупреждение {status or 'нет ответа'}: {url}")
    for status, url in sorted(fatal):
        print(f"  БИТАЯ {status}: {url}")
        for src in sorted(links[url]):
            print(f"      {src}")

    if fatal:
        print(f"\nбитых ссылок: {len(fatal)} — правьте или убирайте")
        return 1
    print("битых ссылок нет")
    return 0


if __name__ == "__main__":
    sys.exit(main())
