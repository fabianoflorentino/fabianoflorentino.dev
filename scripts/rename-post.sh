#!/usr/bin/env sh
#
# rename-post.sh - Renomeia um post (base) e preserva a URL antiga via aliases.
#
# Uso: sh scripts/rename-post.sh KEY NOVO [content_dir]
#   KEY:  slug atual (ex.: dependency_inversion_principle)
#   NOVO: novo slug  (ex.: dependency-inversion-principle)
#   content_dir: diretório de conteúdo (default: content)
#
# Comportamento:
# - Renomeia <KEY>.pt.md e <KEY>.en.md para <NOVO>.pt.md/.en.md (os que existirem).
# - Adiciona `aliases: [/posts/KEY/]` no frontmatter (Hugo redireciona a URL antiga).
# - Atualiza translationKey para NOVO quando era igual a KEY (mantém pares pt/en).
#
# Exit code: 0 se ok, 1 se houver erro (KEY inválida, arquivo ausente, colisão).

set -u

KEY="${1:-}"
NEW="${2:-}"
CONTENT_DIR="${3:-content}"

if [ -z "$KEY" ] || [ -z "$NEW" ]; then
  echo "❌ Uso: sh scripts/rename-post.sh KEY NOVO [content_dir]" >&2
  echo "   Ex.: sh scripts/rename-post.sh solid_em_go_principio_ou_dogma solid-em-go-principio-ou-dogma" >&2
  exit 1
fi

if [ "$KEY" = "$NEW" ]; then
  echo "❌ KEY e NOVO são iguais: nada a fazer." >&2
  exit 1
fi

# Valida slugs (mesmo padrão do check-slugs.sh).
if ! printf '%s' "$KEY" | grep -qE '^[a-z0-9._-]+$'; then
  echo "❌ KEY inválida: '${KEY}' (use apenas [a-z0-9._-])." >&2
  exit 1
fi
if ! printf '%s' "$NEW" | grep -qE '^[a-z0-9._-]+$'; then
  echo "❌ NOVO inválido: '${NEW}' (use apenas [a-z0-9._-])." >&2
  exit 1
fi

POSTS_DIR="${CONTENT_DIR}/posts"
if [ ! -d "${POSTS_DIR}" ]; then
  echo "❌ Diretório '${POSTS_DIR}' não existe." >&2
  exit 1
fi

# get_key <arquivo> -> valor de translationKey no frontmatter (ou vazio).
get_key() {
  file="$1"
  sed -n '1,/^---$/p' "$file" \
    | sed -n '2,/^---$/p' \
    | grep '^translationKey:' \
    | head -n 1 \
    | sed -E "s/^translationKey:[[:space:]]*//; s/^['\"]//; s/['\"]$//"
}

# Primeiro passe: valida existência e colisões (nada é alterado ainda).
FOUND=0
for lang in pt en; do
  old="${POSTS_DIR}/${KEY}.${lang}.md"
  new="${POSTS_DIR}/${NEW}.${lang}.md"
  [ -f "$old" ] || continue
  FOUND=1
  if [ -f "$new" ]; then
    echo "❌ ${new} já existe: não vou sobrescrever." >&2
    exit 1
  fi
done

if [ "$FOUND" = 0 ]; then
  echo "❌ Nenhum post '${KEY}.pt.md'/.en.md encontrado em '${POSTS_DIR}'." >&2
  exit 1
fi

# Segundo passe: aplica as alterações.
for lang in pt en; do
  old="${POSTS_DIR}/${KEY}.${lang}.md"
  new="${POSTS_DIR}/${NEW}.${lang}.md"
  [ -f "$old" ] || continue

  # 1) aliases para a URL antiga (dentro do frontmatter, logo após o '---').
  #    Se já existir 'aliases:', apenas acrescenta a entrada à lista.
  if sed -n '1,/^---$/p' "$old" | grep -q '^aliases:'; then
    sed -i "/^aliases:/a\\
  - /posts/${KEY}/" "$old"
  else
    sed -i "1a\\
aliases:\\
  - /posts/${KEY}/" "$old"
  fi

  # 2) translationKey: alinha com o novo slug quando era o antigo.
  if [ "$(get_key "$old")" = "$KEY" ]; then
    sed -i "s/^translationKey:.*/translationKey: ${NEW}/" "$old"
  fi

  # 3) Renomeia o arquivo.
  mv "$old" "$new"
  echo "  ✓ ${KEY}.${lang}.md -> ${NEW}.${lang}.md (alias /posts/${KEY}/)"
done

echo ""
echo "🔤 Rename concluído. A URL antiga /posts/${KEY}/ redirecionará para /posts/${NEW}/."
echo "   Dica: rode 'make check-slugs' e 'make check-frontmatter' para validar."
