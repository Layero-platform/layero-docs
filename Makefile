.PHONY: help setup check typecheck build check-texts serve start

help:
	@echo "layero-docs — документация → docs.layero.ru"
	@echo ""
	@echo "  make check      — типы + сборка (сборка падуча на битой ссылке)"
	@echo "  make typecheck  — tsc"
	@echo "  make build      — сборка Docusaurus, обе локали"
	@echo "  make check-texts— тексты ↔ код (проверки живут в core и mcp)"
	@echo "  make start      — локально с горячей перезагрузкой"
	@echo "  make setup      — npm ci"
	@echo ""
	@echo "  🚨 push ≠ публикация: деплой сломан, тикет T-20260816-6"

# ── Проверка ─────────────────────────────────────────────────────────────────
#
# Сборка входит в `check` намеренно и является главным здесь: Docusaurus
# падает на битой ссылке, а не предупреждает. Уронить публикацию пушем легко,
# и до правки раннеров это вообще не всплывёт — job уходит в очередь и
# отменяется через сутки, статус `queued`, а не `failure`.
#
# Чего здесь НЕТ и почему:
#  · тестов — документация проверяется сборкой и сверкой с кодом;
#  · check-texts в `check` — проверки лежат в СОСЕДНИХ репозиториях (core,
#    mcp), и гейт docs не должен зависеть от их состояния. Цель отдельная,
#    прогонять перед выкаткой текстов;
#  · проверки живого адреса — `check` локальный. docs.layero.ru смотреть глазами.

typecheck:
	npm run typecheck

build:
	npm run build

# Кросс-репозиторные: скрипты живут в core и mcp.
check-texts:
	python3 ../core/cli/check-error-codes.py
	python3 ../core/cli/check-npx-pin.py
	python3 ../core/cli/check-typography.py
	python3 ../mcp/check-tool-names.py

check: typecheck build
	@echo ""
	@echo "✅ ALL CHECKS PASSED"

setup:
	npm ci

start:
	npm start

serve:
	npm run serve
