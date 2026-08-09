# TODO

Ideias de melhorias (alto impacto, baixo risco) para o blog (Hugo + Cloudflare Pages).

## Prioridade (começar aqui)

- [x] Posts relacionados por tags (3–5 itens no fim do post)
- [x] Navegação de série (anterior/próximo dentro de `series`)
- [x] Link checker no repo (ex.: `make check-links`) para links internos/externos

## Conteúdo / UX

- [x] Série com navegação: “post anterior / próximo” dentro de uma série
- [x] “Relacionado por tags”: seção no fim do post com 3–5 posts semelhantes
- [x] Embed do calendário de contribuições do GitHub na home (no final da página)
- [x] RSS por idioma
- [x] RSS por tag

## Busca / Performance

- [x] Busca melhor (ranking + destaque de termos) usando `index.json`
- [x] Lazy-load de imagens + tamanhos responsivos (image processing do Hugo)
- [x] WebP no build para imagens grandes (AVIF não suportado pelo Hugo 0.155.3)

## SEO / Compartilhamento

- [x] OpenGraph/Twitter Cards por post (com imagem/título/descrição)
- [x] Canonical URL correto em previews (via `CF_PAGES_URL` no build)
- [x] Garantir `hreflang` PT/EN consistente

## Qualidade / Manutenção

- [x] Validação de frontmatter: garantir `translationKey` quando existir `.pt.md` e `.en.md`
- [x] Padronizar slugs (evitar acentos/espaços)
- [x] Redirecionamentos com `aliases` quando renomear posts

## Interação

- [x] Comentários (giscus/GitHub Discussions)
- [x] Reações (👍) via endpoint serverless (Cloudflare Worker)
