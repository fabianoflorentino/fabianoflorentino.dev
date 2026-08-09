#!/usr/bin/env sh
#
# check-frontmatter.sh - Valida translationKey em posts traduzidos.
#
# Uso: sh scripts/check-frontmatter.sh [content_dir]
#   content_dir: diretório de conteúdo (default: content)
#
# Regras:
# - Par (.pt.md + .en.md com a mesma base): ambos DEVEM ter translationKey
#   com o MESMO valor (senão o Hugo não emparelha as traduções).
# - Post sem par (apenas um idioma): aviso se translationKey ausente
#   (recomendado para permitir tradução futura).
#
# Exit code: 0 se tudo OK, 1 se houver erro (par sem translationKey ou divergente).

set -u

CONTENT_DIR="${1:-content}"
if [ ! -d "${CONTENT_DIR}" ]; then
  echo "❌ Diretório '${CONTENT_DIR}' não existe." >&2
  exit 1
fi

ERRORS=0
WARNINGS=0

# get_key <arquivo> -> valor de translationKey no frontmatter (ou vazio).
# Lê apenas o bloco YAML delimitado por --- no início do arquivo.
get_key() {
  file="$1"
  sed -n '1,/^---$/p' "$file" \
    | sed -n '2,/^---$/p' \
    | grep '^translationKey:' \
    | head -n 1 \
    | sed -E "s/^translationKey:[[:space:]]*//; s/^['\"]//; s/['\"]$//"
}

BASES="$(find "${CONTENT_DIR}" \( -name '*.pt.md' -o -name '*.en.md' \) -type f 2>/dev/null | sed -E 's/\.(pt|en)\.md$//' | sort -u)"

if [ -z "$BASES" ]; then
  echo "⚠️  Nenhum post .pt.md/.en.md encontrado em '${CONTENT_DIR}'."
  exit 0
fi

for base in $BASES; do
  pt="${base}.pt.md"
  en="${base}.en.md"
  has_pt=no
  has_en=no
  [ -f "$pt" ] && has_pt=yes
  [ -f "$en" ] && has_en=yes
  rel="${base#${CONTENT_DIR}/}"

  if [ "$has_pt" = yes ] && [ "$has_en" = yes ]; then
    key_pt="$(get_key "$pt")"
    key_en="$(get_key "$en")"
    if [ -z "$key_pt" ] || [ -z "$key_en" ]; then
      echo "  ❌ ${rel}: par sem translationKey (pt='${key_pt}', en='${key_en}')"
      ERRORS=$((ERRORS + 1))
    elif [ "$key_pt" != "$key_en" ]; then
      echo "  ❌ ${rel}: translationKey divergente (pt='${key_pt}', en='${key_en}')"
      ERRORS=$((ERRORS + 1))
    fi
  else
    file="$([ "$has_pt" = yes ] && echo "$pt" || echo "$en")"
    key="$(get_key "$file")"
    if [ -z "$key" ]; then
      echo "  ⚠️  ${rel}: apenas um idioma e sem translationKey"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done

echo ""
echo "📄 Resumo: $(printf '%s\n' "$BASES" | wc -l | tr -d ' ') base(s), ${ERRORS} erro(s), ${WARNINGS} aviso(s)"

if [ "${ERRORS}" -gt 0 ]; then
  echo "❌ Frontmatter com problemas: adicione/alinhe translationKey nos pares." >&2
  exit 1
fi

echo "✅ Frontmatter OK."
exit 0
