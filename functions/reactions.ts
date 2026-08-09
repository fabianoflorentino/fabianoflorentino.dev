// Cloudflare Pages Function: reações (👍) por post.
//
// Rotas (mesmo domínio, sem CORS necessário):
//   GET  /reactions?key=<translationKey> -> { "<emoji>": count, ... }
//   POST /reactions  body: { "key": <translationKey>, "emoji": "👍" }
//          -> { "<emoji>": novo_count, ... }
//
// Persistência: Cloudflare KV (binding `REACTIONS_KV`).
//   Chave: "reaction:<translationKey>"  ->  JSON { "<emoji>": count }
//   Usa translationKey para que as versões PT/EN do mesmo post
//   compartilhem a mesma contagem.
//
// Limitação conhecida: KV não oferece incremento atômico. O padrão
// read-modify-write abaixo pode perder contagens sob concorrência real
// (aceitável para um blog pessoal; documentado em vez de escondido).
//
// Setup em produção (Cloudflare Pages):
//   1. Criar um namespace KV (Workers & Pages > KV).
//   2. No projeto Pages: Settings > Functions > KV namespace bindings,
//      nome da variável: `REACTIONS_KV`.

const ALLOWED_EMOJIS = new Set(["👍"]);
// Mesmo padrão de slug dos posts (check-slugs.sh): [a-z0-9._-].
const KEY_RE = /^[a-z0-9._-]{1,200}$/;

interface Env {
  REACTIONS_KV: KVNamespace;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

async function readCounts(kv: KVNamespace, key: string): Promise<Record<string, number>> {
  try {
    const raw = await kv.get(`reaction:${key}`);
    return raw ? (JSON.parse(raw) as Record<string, number>) : {};
  } catch {
    // KV corrompido/parcial: recomeça a contagem em vez de quebrar o endpoint.
    return {};
  }
}

export const onRequestGet: PagesFunction<Env> = async ({ env, request }) => {
  const url = new URL(request.url);
  const key = url.searchParams.get("key") ?? "";
  if (!KEY_RE.test(key)) {
    return json({ error: "invalid key" }, 400);
  }
  return json(await readCounts(env.REACTIONS_KV, key));
};

export const onRequestPost: PagesFunction<Env> = async ({ env, request }) => {
  if (!request.headers.get("content-type")?.includes("application/json")) {
    return json({ error: "content-type must be application/json" }, 400);
  }

  let body: { key?: unknown; emoji?: unknown };
  try {
    body = (await request.json()) as { key?: unknown; emoji?: unknown };
  } catch {
    return json({ error: "invalid json body" }, 400);
  }

  const { key, emoji } = body;
  if (typeof key !== "string" || !KEY_RE.test(key)) {
    return json({ error: "invalid key" }, 400);
  }
  if (typeof emoji !== "string" || !ALLOWED_EMOJIS.has(emoji)) {
    return json({ error: "invalid emoji" }, 400);
  }

  const counts = await readCounts(env.REACTIONS_KV, key);
  counts[emoji] = (counts[emoji] ?? 0) + 1;
  await env.REACTIONS_KV.put(`reaction:${key}`, JSON.stringify(counts));

  return json(counts);
};
