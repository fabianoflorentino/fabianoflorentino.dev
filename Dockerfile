FROM alpine:3.23.3 AS development

ARG HUGO_VERSION=0.155.3

WORKDIR /blog

COPY . .

RUN apk add --no-cache curl tar ca-certificates \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz \
    -o /tmp/hugo.tar.gz \
  && tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin \
  && chmod +x /usr/local/bin/hugo \
  && rm -rf /tmp/hugo.tar.gz \
  && hugo --minify

FROM gcr.io/distroless/static:nonroot AS production

WORKDIR /site

COPY --from=development /blog/public .

USER nonroot:nonroot
