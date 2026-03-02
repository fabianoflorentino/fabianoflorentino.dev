# fabianoflorentino.dev

Hugo website built with the `hugo-profile` theme and deployed on Cloudflare Pages.

## Local development (Docker)

- Start the dev server: `make up`
- Follow logs: `make logs`
- Stop: `make down`
- Clean generated files: `make clean-hugo`
- Regenerate from scratch: `make regen`

## Creating new posts (i18n)

This project uses language suffixes in filenames:

- `content/posts/<key>.pt.md`
- `content/posts/<key>.en.md`

Helpers:

- `make new-post-pt TITLE="Meu Título"`
- `make new-post-en TITLE="My Title"`

By default, `translationKey` is set to the generated `<key>`.
If you want both languages to share the same key even with different titles, pass it explicitly:

- `make new-post-pt TITLE="..." KEY="minha-chave"`
- `make new-post-en TITLE="..." KEY="minha-chave"`

The dev server runs on <http://localhost:1313>.

### Pinning Hugo version

Cloudflare Pages uses `HUGO_VERSION=0.155.3`.
To keep local builds consistent, copy `.env.example` to `.env`:

- `cp .env.example .env`

`docker compose` will pick up `HUGO_VERSION` and pass it to the Docker build.

## Cloudflare Pages build settings

- **Build command**: `sh scripts/cf-build.sh`
- **Build output directory**: `public`
- **Environment variables**:
  - `HUGO_VERSION=0.155.3`

Why a script?

- On `main`, it builds with `baseURL=https://fabianoflorentino.dev`.
- On preview branches, it uses `CF_PAGES_URL` so links/canonical URLs work correctly.

## Comments (Giscus)

Comments are powered by Giscus (GitHub Discussions).

Prerequisites:

- The target repository must be public.
- GitHub Discussions must be enabled.
- The Giscus GitHub app must be installed for the repository.

Current site configuration is set in `hugo.yaml` under `params.giscus`, including:

- `repo`, `repoId`, `category`, `categoryId`
- `mapping: "pathname"`
- `strict`, `reactionsEnabled`, `emitMetadata`, `inputPosition`
- `theme`, plus dynamic light/dark sync (`dynamicTheme`, `lightTheme`, `darkTheme`)

After updating config, restart local dev server (`make down && make up`) if needed.

If Cloudflare Pages does not pick up the latest `main` commit automatically, trigger a manual redeploy from the Deployments page.

## Repo hygiene

This repo does not commit Hugo build artifacts:

- `public/`
- `resources/_gen/`
- `.hugo_build.lock`
