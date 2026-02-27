# fabianoflorentino.dev

Hugo website built with the `hugo-profile` theme and deployed on Cloudflare Pages.

## Local development (Docker)

- Start the dev server: `make up`
- Follow logs: `make logs`
- Stop: `make down`

The dev server runs on http://localhost:1313.

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

## Repo hygiene

This repo does not commit Hugo build artifacts:

- `public/`
- `resources/_gen/`
- `.hugo_build.lock`
