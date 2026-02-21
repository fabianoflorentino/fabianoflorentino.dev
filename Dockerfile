FROM alpine:3.23.3

ARG HUGO_VERSION=0.156.0 \
  HUGO_URL=https://github.com/gohugoio/hugo \
  HUGO_PATH=releases/download/v${HUGO_VERSION} \
  HUGO_BINARY=hugo_${HUGO_VERSION}_linux-amd64.tar.gz

WORKDIR /blog

RUN apk add --no-cache curl tar ca-certificates \
  && curl -L ${HUGO_URL}/${HUGO_PATH}/${HUGO_BINARY} -o /tmp/hugo.tar.gz \
  && tar -xzf /tmp/hugo.tar.gz -C /tmp \
  && mv /tmp/hugo /usr/local/bin/hugo \
  && chmod +x /usr/local/bin/hugo \
  && rm -rf /tmp/hugo.tar.gz \
  && apk del curl tar ca-certificates \
  && rm -rf /var/cache/apk/*

COPY . .

EXPOSE 1313

USER 1000:1000

ENTRYPOINT ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--disableFastRender"]
