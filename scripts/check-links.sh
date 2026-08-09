#!/usr/bin/env sh
#
# check-links.sh - Verifica links internos e externos do site buildado.
#
# Uso: sh scripts/check-links.sh [public_dir]
#   public_dir: diretório com o output do Hugo (default: public)
#
# - Links internos (/, relativos)  -> checados contra os arquivos em public_dir
# - Links externos (http/https)    -> checados via HEAD (fallback GET), com dedup
# - Ignora: mailto:, tel:, javascript:, data:, # (âncoras), feeds XML
#
# Exit code: 0 se tudo OK, 1 se houver links quebrados.

set -u

PUBLIC_DIR="${1:-public}"
if [ ! -d "${PUBLIC_DIR}" ]; then
  echo "❌ Diretório '${PUBLIC_DIR}' não existe. Rode o build antes (ex.: make generate)." >&2
  exit 1
fi
PUBLIC_DIR="$(cd "${PUBLIC_DIR}" && pwd)"

# Domínios que bloqueiam requests não-browser (mesmo com User-Agent de
# navegador) mas funcionam para usuários reais. Adicione aqui novos domínios
# com o mesmo comportamento.
IGNORE_DOMAINS="1drv.ms x.com oreilly.com linkedin.com"

# Hosts do próprio site: links para eles são checados localmente contra
# public/ em vez de bater na rede. Default: host de baseURL no hugo.yaml.
# Sobrescreva com: SITE_HOSTS="fabianoflorentino.dev example.com" make check-links
SITE_HOSTS="${SITE_HOSTS:-}"
if [ -z "$SITE_HOSTS" ]; then
  baseurl="$(grep -m1 '^baseURL:' hugo.yaml 2>/dev/null | sed -E 's/.*https?:\/\/([^\/]+).*/\1/')"
  SITE_HOSTS="$(printf '%s\n' "${baseurl}" | sed 's/[:/].*//')"
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT
BROKEN_FILE="${TMPDIR}/broken.txt"
WARN_FILE="${TMPDIR}/warn.txt"
INTERNAL_FILE="${TMPDIR}/internal.txt"
EXTERNAL_FILE="${TMPDIR}/external.txt"
: > "${BROKEN_FILE}"
: > "${WARN_FILE}"
: > "${INTERNAL_FILE}"
: > "${EXTERNAL_FILE}"

log_broken() {
  echo "  ❌ $1" >> "${BROKEN_FILE}"
}

# --- HTTP client -----------------------------------------------------------

fetch_status() {
  # Retorna o código HTTP (000 se erro de rede) de uma URL, HEAD com fallback
  # GET. Usa User-Agent de navegador (alguns sites bloqueiam bots) e considera
  # 429 (rate limit) como retry-once, senão skip.
  url="$1"
  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
  if command -v curl >/dev/null 2>&1; then
    code="$(curl -s -o /dev/null -m 20 -w '%{http_code}' -L -A "$UA" -I "$url" 2>/dev/null || echo 000)"
    if [ "$code" = "000" ] || [ "$code" -ge 400 ] 2>/dev/null; then
      code="$(curl -s -o /dev/null -m 20 -w '%{http_code}' -L -A "$UA" "$url" 2>/dev/null || echo 000)"
    fi
    if [ "$code" = "429" ]; then
      sleep 3
      code="$(curl -s -o /dev/null -m 20 -w '%{http_code}' -L -A "$UA" "$url" 2>/dev/null || echo 000)"
    fi
    if [ "$code" = "429" ]; then
      echo "429"
      return
    fi
    printf '%s' "$code"
  elif command -v wget >/dev/null 2>&1; then
    code="$(wget --spider -q -T 20 -o /dev/null --server-response --user-agent="$UA" "$url" 2>&1 | awk 'tolower($0) ~ /http\// {c=$2} END {print c+0}')"
    printf '%s' "${code:-000}"
  else
    echo "000"
  fi
}

# --- Extração de links -----------------------------------------------------

is_ignored_domain() {
  url="$1"
  for d in ${IGNORE_DOMAINS}; do
    case "$url" in
      *"${d}"*) return 0 ;;
    esac
  done
  return 1
}

is_site_host() {
  url="$1"
  host="${url#*://}"
  host="${host%%/*}"
  for h in ${SITE_HOSTS}; do
    if [ "$host" = "$h" ]; then
      return 0
    fi
  done
  return 1
}

normalize_target() {
  # Remove fragmento (#...) e query (?...) mantendo o que importa para checagem.
  target="$1"
  case "$target" in
    *\#*) target="${target%%\#*}" ;;
  esac
  case "$target" in
    *\?*) target="${target%%\?*}" ;;
  esac
  printf '%s' "$target"
}

check_internal() {
  # $1 = caminho já normalizado (começa com / ou é relativo), $2 = arquivo página
  echo "x" >> "${INTERNAL_FILE}"
  path="$1"
  page="$2"

  case "$path" in
    /*) file_path="${PUBLIC_DIR}${path}" ;;
    *)
      page_dir="$(dirname "$page")"
      file_path="${page_dir}/${path}"
      ;;
  esac

  # Resolve caminhos com ".." / "." e normaliza.
  file_path="$(cd "${PUBLIC_DIR}" >/dev/null 2>&1 && realpath -m "$file_path" 2>/dev/null || echo "$file_path")"
  file_path="${PUBLIC_DIR}${file_path#${PUBLIC_DIR}}"

  if [ -f "$file_path" ] || [ -f "${file_path}/index.html" ]; then
    :
  else
    log_broken "interno: ${path} (em ${page#${PUBLIC_DIR}/})"
  fi
}

check_external() {
  echo "x" >> "${EXTERNAL_FILE}"
  code="$(fetch_status "$1")"
  if [ "$code" = "429" ]; then
    echo "  ⚠️  rate-limited (429), pulado: $1" >> "${WARN_FILE}"
    return
  fi
  if [ "$code" = "000" ] || [ "$code" -ge 400 ] 2>/dev/null; then
    log_broken "externo: $1 (HTTP ${code})"
  fi
}

# --- Varredura --------------------------------------------------------------

FILES="$(find "${PUBLIC_DIR}" -name '*.html' -type f 2>/dev/null)"

if [ -z "$FILES" ]; then
  echo "⚠️  Nenhum arquivo .html encontrado em '${PUBLIC_DIR}'."
  exit 1
fi

# Varredura: classifica cada link por página. O Hugo com --minify remove aspas
# dos atributos, então aceitamos valores com e sem aspas. Tags <link> (preconnect/
# stylesheet) são puladas: apontam para CDNs/domínios nus que respondem 404 a bots.
for page in $FILES; do
  grep -oE '<(a|img|script|iframe)[^>]*>' "$page" 2>/dev/null | \
    grep -oE '(href|src)=("[^"]*"|[^[:space:]"'"'"'>]*)' | \
    sed -E 's/^(href|src)=//; s/^"//; s/"$//' | \
  while IFS= read -r url; do
    case "$url" in
      '' | '#'* | 'mailto:'* | 'tel:'* | 'javascript:'* | 'data:'*)
        continue
        ;;
      '//'*)
        url="https:${url}"
        ;;
    esac

    case "$url" in
      http://* | https://*)
        if is_ignored_domain "$url"; then
          continue
        fi
        if is_site_host "$url"; then
          path="/${url#*://*/}"
          target="$(normalize_target "$path")"
          [ -z "$target" ] && continue
          check_internal "$target" "$page"
        else
          printf '%s\n' "$url" >> "${TMPDIR}/external_candidates.txt"
        fi
        ;;
      *)
        target="$(normalize_target "$url")"
        [ -z "$target" ] && continue
        check_internal "$target" "$page"
        ;;
    esac
  done
done

# Checa links externos (deduplicados).
if [ -f "${TMPDIR}/external_candidates.txt" ]; then
  sort -u "${TMPDIR}/external_candidates.txt" | while IFS= read -r url; do
    check_external "$url"
  done
fi

# --- Resumo -----------------------------------------------------------------

INTERNAL_COUNT="$(wc -l < "${INTERNAL_FILE}" 2>/dev/null || echo 0)"
EXTERNAL_COUNT="$(wc -l < "${EXTERNAL_FILE}" 2>/dev/null || echo 0)"
BROKEN_COUNT="$(wc -l < "${BROKEN_FILE}" 2>/dev/null || echo 0)"

if [ "${BROKEN_COUNT}" -gt 0 ]; then
  cat "${BROKEN_FILE}"
fi

WARN_COUNT="$(wc -l < "${WARN_FILE}" 2>/dev/null || echo 0)"
if [ "${WARN_COUNT}" -gt 0 ]; then
  cat "${WARN_FILE}"
fi

echo ""
echo "🔗 Resumo: ${INTERNAL_COUNT} links internos, ${EXTERNAL_COUNT} externos (únicos), ${BROKEN_COUNT} quebrados"

if [ "${BROKEN_COUNT}" -gt 0 ]; then
  echo "❌ Encontrados ${BROKEN_COUNT} link(s) quebrado(s)." >&2
  exit 1
fi

echo "✅ Todos os links estão OK."
exit 0
