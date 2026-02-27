#!/usr/bin/env sh
set -eu

# Cloudflare Pages provides:
# - CF_PAGES_BRANCH
# - CF_PAGES_URL (preview URL)
# See: https://developers.cloudflare.com/pages/platform/build-configuration/

if [ "${CF_PAGES_BRANCH:-}" = "main" ]; then
  BASE_URL="https://fabianoflorentino.dev"
else
  BASE_URL="${CF_PAGES_URL:-https://fabianoflorentino.dev}"
fi

echo "Building Hugo site with baseURL=${BASE_URL}"

hugo --minify --baseURL="${BASE_URL}"
