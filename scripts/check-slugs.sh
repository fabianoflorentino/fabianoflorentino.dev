#!/usr/bin/env sh
#
# check-slugs.sh - Valida nomes de arquivo e translationKey dos posts.
#
# Uso: sh scripts/check-slugs.sh [content_dir]
#   content_dir: diretório de conteúdo (default: content)
#
# Regras:
# - Erro: base do filename ou translationKey com caracteres fora de
#   [a-z0-9._-] (acentos, espaços, maiúsculas ou símbolos quebram URLs).
# - Aviso: post sem a versão no outro idioma (.pt.md sem .en.md e vice-versa).
#
# Obs.: underscores são aceitos (posts legados os usam; renomear quebraria
# URLs já publicadas). O padrão hífen é garantido pelos targets new-post-*.
#
# Exit code: 0 se tudo OK, 1 se houver erro.

set -u

CONTENT_DIR="${1:-content}"
if [ ! -d "${CONTENT_DIR}" ]; then
  echo "❌ Diretório '${CONTENT_DIR}' não existe." >&2
  exit 1
fi

ERRORS=0
WARNINGS=0

# get_key <arquivo> -> valor de translationKey no frontmatter (ou vazio).
get_key() {
  file="$1"
  sed -n '1,/^---$/p' "$file" \
    | sed -n '2,/^---$/p' \
    | grep '^translationKey:' \
    | head -n 1 \
    | sed -E "s/^translationKey:[[:space:]]*//; s/^['\"]//; s/['\"]$//"
}

check_name() {
  # $1 = tipo (arquivo/chave), $2 = nome base, $3 = caminho do arquivo
  type="$1"
  name="$2"
  path="$3"

  if ! printf '%s' "$name" | grep -qE '^[a-z0-9._-]+$'; then
    echo "  ❌ ${type} com caracteres inválidos: '${name}' (em ${path})"
    ERRORS=$((ERRORS + 1))
  fi
}

FILES="$(find "${CONTENT_DIR}" \( -name '*.pt.md' -o -name '*.en.md' \) -type f 2>/dev/null)"

if [ -z "$FILES" ]; then
  echo "⚠️  Nenhum post .pt.md/.en.md encontrado em '${CONTENT_DIR}'."
  exit 0
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT
printf '%s\n' "$FILES" > "${TMPDIR}/files.txt"

# Valida base + pares pt/en.
sed -E 's/\.(pt|en)\.md$//' "${TMPDIR}/files.txt" | sort -u > "${TMPDIR}/bases.txt"
while IFS= read -r base; do
  [ -z "$base" ] && continue
  base_name="$(basename "$base")"
  check_name "arquivo" "$base_name" "${base}.pt.md"
  pt="${base}.pt.md"
  en="${base}.en.md"
  [ -f "$pt" ] && [ ! -f "$en" ] && echo "  ⚠️  post sem versão .en.md: ${base}.pt.md"
  [ -f "$en" ] && [ ! -f "$pt" ] && echo "  ⚠️  post sem versão .pt.md: ${base}.en.md"
done < "${TMPDIR}/bases.txt"

# Valida translationKey (mesmo padrão de caracteres).
while IFS= read -r f; do
  [ -z "$f" ] && continue
  key="$(get_key "$f")"
  [ -z "$key" ] && continue
  check_name "translationKey" "$key" "$f"
done < "${TMPDIR}/files.txt"

echo ""
echo "🔤 Resumo: $(wc -l < "${TMPDIR}/bases.txt" | tr -d ' ') base(s), ${ERRORS} erro(s), ${WARNINGS} aviso(s)"

if [ "${ERRORS}" -gt 0 ]; then
  echo "❌ Slugs inválidos encontrados: corrija os nomes de arquivo/keys." >&2
  exit 1
fi

echo "✅ Slugs OK."
exit 0
