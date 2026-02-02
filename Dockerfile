FROM alpine:3.23 AS development

ARG HUGO_VERSION=0.155.1

WORKDIR /blog

RUN apk add --no-cache \
  curl \
  tar \
  ca-certificates \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v0.155.1/hugo_${HUGO_VERSION}_linux-amd64.tar.gz \
  -o /tmp/hugo.tar.gz \
  && tar -xzf /tmp/hugo.tar.gz -C /tmp \
  && mv /tmp/hugo /usr/local/bin/hugo \
  && chmod +x /usr/local/bin/hugo \
  && rm -rf /tmp/hugo.tar.gz

COPY . .

EXPOSE 1313

USER 1000:1000

ENTRYPOINT ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--disableFastRender"]

FROM gcr.io/distroless/static:nonroot AS production

WORKDIR /blog

COPY . .

COPY --from=development /site/public /site

USER nonroot:nonroot
