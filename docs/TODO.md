# TODO

Ideias de melhorias (alto impacto, baixo risco) para o blog (Hugo + Cloudflare Pages).

## Prioridade (começar aqui)

- [x] Posts relacionados por tags (3–5 itens no fim do post)
- [ ] Navegação de série (anterior/próximo dentro de `series`)
- [ ] Link checker no repo (ex.: `make check-links`) para links internos/externos

## Conteúdo / UX

- [ ] Série com navegação: “post anterior / próximo” dentro de uma série
- [x] “Relacionado por tags”: seção no fim do post com 3–5 posts semelhantes
- [ ] Página “Now”
- [ ] Página “Uses”
- [ ] RSS por idioma
- [ ] RSS por tag

## Busca / Performance

- [ ] Busca melhor (ranking + destaque de termos) usando `index.json`
- [ ] Lazy-load de imagens + tamanhos responsivos (image processing do Hugo)
- [ ] WebP/AVIF no build para imagens grandes (quando fizer sentido)

## SEO / Compartilhamento

- [x] OpenGraph/Twitter Cards por post (com imagem/título/descrição)
- [ ] Canonical URL correto em previews (via `CF_PAGES_URL` no build)
- [ ] Garantir `hreflang` PT/EN consistente

## Qualidade / Manutenção

- [ ] Validação de frontmatter: garantir `translationKey` quando existir `.pt.md` e `.en.md`
- [ ] Padronizar slugs (evitar acentos/espaços)
- [ ] Redirecionamentos com `aliases` quando renomear posts

## Interação

- [ ] Comentários (giscus/GitHub Discussions)
- [ ] Reações (👍) via endpoint serverless (Cloudflare Worker)
