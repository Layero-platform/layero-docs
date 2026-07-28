#!/usr/bin/env bash
# Layero docs → s3://layero-docs/ + YC CDN purge.
# Аналог frontend/landing/deploy.sh, но рекурсивная синхронизация (Docusaurus build).
set -euo pipefail

cd "$(dirname "$0")"

BUCKET="${BUCKET:-layero-docs}"
BUILD_DIR="${BUILD_DIR:-build}"

CDN_RESOURCE_ID="${CDN_RESOURCE_ID:-$(yc cdn resource list --format json 2>/dev/null \
  | python3 -c "import json,sys; print(next((r['id'] for r in json.load(sys.stdin) if r.get('cname')=='docs.layero.ru'), ''))" 2>/dev/null || true)}"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "==> Building Docusaurus (locales: ru + en)"
  npm ci
  npm run build
fi

content_type() {
  case "$1" in
    *.html) echo "text/html; charset=utf-8" ;;
    *.css)  echo "text/css; charset=utf-8" ;;
    *.js|*.mjs) echo "application/javascript; charset=utf-8" ;;
    *.json) echo "application/json" ;;
    *.svg)  echo "image/svg+xml" ;;
    *.png)  echo "image/png" ;;
    *.jpg|*.jpeg) echo "image/jpeg" ;;
    *.webp) echo "image/webp" ;;
    *.ico)  echo "image/x-icon" ;;
    *.woff) echo "font/woff" ;;
    *.woff2) echo "font/woff2" ;;
    *.xml)  echo "application/xml" ;;
    *.txt|*.map) echo "text/plain; charset=utf-8" ;;
    *)      echo "application/octet-stream" ;;
  esac
}

cache_control() {
  case "$1" in
    *.html|*.xml) echo "no-cache" ;;
    assets/*) echo "public, max-age=31536000, immutable" ;;
    *)        echo "public, max-age=3600" ;;
  esac
}

echo "==> Uploading $BUILD_DIR to s3://$BUCKET/"
cd "$BUILD_DIR"
find . -type f | while read -r path; do
  key="${path#./}"
  ct=$(content_type "$key")
  cc=$(cache_control "$key")
  yc storage s3 cp "$key" "s3://$BUCKET/$key" \
    --content-type "$ct" \
    --cache-control "$cc" >/dev/null
  echo "  $key  ($ct)"
done
cd - >/dev/null

if [[ -n "$CDN_RESOURCE_ID" ]]; then
  echo "==> Purging CDN cache (resource $CDN_RESOURCE_ID)"
  yc cdn cache purge --resource-id "$CDN_RESOURCE_ID" --path '/*' >/dev/null || true
else
  echo "==> CDN resource not found yet — skipping cache purge (first deploy?)"
fi

# IndexNow — мгновенное уведомление Яндекса и Bing об обновлённых URL.
# Shared key между layero.ru и docs.layero.ru. Key-файл лежит в static/ и
# копируется в build/ самим Docusaurus, поэтому отдельно его загружать не надо.
# Ошибки игнорируем — внешний сервис не должен ронять деплой.
INDEXNOW_KEY="305edf9b810aa739d9d8f7f022d960b2"
echo "==> Pinging IndexNow (Yandex + Bing)"
python3 - <<PY || true
import json, os, re, urllib.parse, urllib.request, urllib.error
key  = "${INDEXNOW_KEY}"
host = "docs.layero.ru"
# Docusaurus с i18n кладёт ОТДЕЛЬНЫЙ sitemap в каждую локаль: build/sitemap.xml
# (ru) и build/en/sitemap.xml. Долгое время отправлялся только первый, и
# 56 английских страниц не попадали в IndexNow вообще — при том, что именно
# английская документация нужна международным краулерам.
#
# НО: локаль en переведена частично. Docusaurus для непереведённой страницы
# отдаёт русский текст по английскому адресу (штатный fallback). Пушить такое
# в IndexNow нельзя: IndexNow — это заявка «страница готова, приходите», а мы
# заявляли бы дубль русской страницы с заголовком hreflang=en-US. Поэтому
# английские адреса фильтруются по фактическому языку СОБРАННОГО html.
# Проверка самонастраивающаяся: по мере перевода страницы начинают попадать
# в пуш сами, без правки этого скрипта.
BUILD = "${BUILD_DIR}"

def is_english(url: str) -> bool:
    # Адрес из карты сайта процентно-закодирован, а файл на диске лежит с
    # именем в UTF-8: страницы разделов зовутся /en/category/тарифы-и-оплата.
    # Без unquote os.path.exists не находил их, и ВСЕ ШЕСТЬ английских
    # страниц-разделов молча выпадали из пуша — при этом лог называл их
    # «непереведёнными». Именно эти страницы краулеры используют как хабы.
    rel = urllib.parse.unquote(url.replace("https://docs.layero.ru/", "")).strip("/")
    for candidate in (os.path.join(BUILD, rel, "index.html"),
                      os.path.join(BUILD, rel + ".html")):
        if os.path.exists(candidate):
            html = open(candidate, encoding="utf-8", errors="ignore").read()
            m = re.search(r"<article.*?</article>", html, re.S)
            text = re.sub(r"<[^>]+>", " ", m.group(0) if m else "")
            cyr = sum(1 for c in text if "а" <= c.lower() <= "я")
            lat = sum(1 for c in text if "a" <= c.lower() <= "z")
            # Критерий — «страница НЕ русская», а не «латиницы больше».
            # Прежнее `lat > cyr` на служебных страницах без <article>
            # (/en/search, /en/blog/archive, /en/blog/authors) давало 0 > 0,
            # то есть «ложь», и они тоже выпадали из пуша.
            return cyr <= lat
    return False  # файла нет — не рискуем

urls = []
for rel in ("sitemap.xml", "en/sitemap.xml"):
    path = os.path.join(BUILD, rel)
    if not os.path.exists(path):
        print(f"  WARN: {path} отсутствует — локаль пропущена")
        continue
    found = re.findall(r"<loc>([^<]+)</loc>", open(path, encoding="utf-8").read())
    if rel.startswith("en/"):
        kept = [u for u in found if is_english(u)]
        # Исключённые печатаем поимённо. Прежняя строка называла их
        # «непереведёнными», ничего не проверяя, — и десять адресов, из них
        # шесть страниц-разделов, годами выпадали под правдоподобной подписью.
        dropped = [u for u in found if u not in set(kept)]
        print(f"  {rel}: {len(kept)} из {len(found)} URL")
        for u in dropped:
            print(f"    не отправлен: {urllib.parse.unquote(u)}")
        found = kept
    else:
        print(f"  {rel}: {len(found)} URL")
    urls.extend(found)
urls = list(dict.fromkeys(urls))
payload = json.dumps({
    "host": host,
    "key": key,
    "keyLocation": f"https://{host}/{key}.txt",
    "urlList": urls,
}).encode("utf-8")
for endpoint in ("https://api.indexnow.org/IndexNow", "https://yandex.com/indexnow"):
    req = urllib.request.Request(
        endpoint, data=payload,
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    try:
        r = urllib.request.urlopen(req, timeout=15)
        print(f"  {endpoint}: HTTP {r.status} ({len(urls)} URLs)")
    except urllib.error.HTTPError as e:
        print(f"  {endpoint}: HTTP {e.code} {e.reason}")
    except Exception as e:
        print(f"  {endpoint}: {type(e).__name__}: {e}")
PY

echo "Done. https://docs.layero.ru/"
