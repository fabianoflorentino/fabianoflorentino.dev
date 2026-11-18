#!/usr/bin/env bash
# Gera um banner cyberpunk (2400x1260) para a série SRE do Google.
# Estilo: grid escuro, neon (teal/cyan/violet), texto glitch e cantos HUD.
#
# Uso:
#   scripts/gen-banner.sh <numero> <topico> [arquivo-saida]
#
# Exemplo:
#   scripts/gen-banner.sh 01 "Introduction"
#   scripts/gen-banner.sh 02 "Production Environment"
set -euo pipefail

number="${1:?uso: gen-banner.sh <numero> <topico> [arquivo-saida]}"
topic="${2:?uso: gen-banner.sh <numero> <topico> [arquivo-saida]}"
out="${3:-assets/images/sre-${number}.png}"

topic_upper="$(printf '%s' "$topic" | tr '[:lower:]' '[:upper:]')"

cat > /tmp/sre-banner.svg <<'SVG'
<svg width="2400" height="1260" viewBox="0 0 2400 1260" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#060b14"/>
      <stop offset="0.55" stop-color="#0a1424"/>
      <stop offset="1" stop-color="#0d1a30"/>
    </linearGradient>
    <radialGradient id="glowA" cx="0.18" cy="0.22" r="0.6">
      <stop offset="0" stop-color="#0b8f7d" stop-opacity="0.34"/>
      <stop offset="1" stop-color="#0b8f7d" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="glowB" cx="0.84" cy="0.78" r="0.6">
      <stop offset="0" stop-color="#6d3fd1" stop-opacity="0.30"/>
      <stop offset="1" stop-color="#6d3fd1" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="titleGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#6bffd6"/>
      <stop offset="0.5" stop-color="#31c9ff"/>
      <stop offset="1" stop-color="#a78bfa"/>
    </linearGradient>
    <pattern id="grid" width="80" height="80" patternUnits="userSpaceOnUse">
      <path d="M80 0 H0 V80" fill="none" stroke="#31c9ff" stroke-opacity="0.07" stroke-width="1"/>
    </pattern>
    <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="8" result="b"/>
      <feMerge>
        <feMergeNode in="b"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <rect width="2400" height="1260" fill="url(#bg)"/>
  <rect width="2400" height="1260" fill="url(#glowA)"/>
  <rect width="2400" height="1260" fill="url(#glowB)"/>
  <rect width="2400" height="1260" fill="url(#grid)"/>

  <!-- Cantos HUD -->
  <g stroke="#31c9ff" stroke-width="4" fill="none" opacity="0.9">
    <path d="M70 120 L70 70 L120 70"/>
    <path d="M2280 70 L2330 70 L2330 120"/>
    <path d="M70 1140 L70 1190 L120 1190"/>
    <path d="M2280 1190 L2330 1190 L2330 1140"/>
  </g>

  <!-- Rótulos HUD -->
  <g fill="#31c9ff" font-family="'DejaVu Sans Mono', monospace">
    <text x="96" y="58" font-size="28" letter-spacing="6" opacity="0.8">SRE / GOOGLE</text>
    <text x="2304" y="58" font-size="28" letter-spacing="6" text-anchor="end" opacity="0.8">CH __NUMBER__</text>
  </g>

  <!-- Título com glitch -->
  <g font-family="'DejaVu Sans Mono', monospace" font-weight="bold">
    <text x="1200" y="640" font-size="440" text-anchor="middle" fill="#a78bfa" opacity="0.8" transform="translate(16,0)">SRE</text>
    <text x="1200" y="640" font-size="440" text-anchor="middle" fill="#31c9ff" opacity="0.8" transform="translate(-16,0)">SRE</text>
    <text x="1200" y="640" font-size="440" text-anchor="middle" fill="#e6edf3">SRE</text>
  </g>

  <!-- Barras de glitch -->
  <rect x="560" y="548" width="1280" height="8" fill="#a78bfa" opacity="0.45"/>
  <rect x="640" y="680" width="1040" height="6" fill="#31c9ff" opacity="0.4"/>

  <!-- Subtítulo -->
  <text x="1200" y="856" font-family="'DejaVu Sans Mono', monospace" font-size="58" letter-spacing="18" text-anchor="middle" fill="url(#titleGrad)" filter="url(#softGlow)">SITE RELIABILITY ENGINEERING</text>

  <!-- Tópico do capítulo -->
  <text x="1200" y="974" font-family="'DejaVu Sans Mono', monospace" font-size="56" letter-spacing="10" text-anchor="middle" fill="#93a4b8">__TOPIC__</text>

  <!-- Linha inferior -->
  <line x1="820" y1="1050" x2="1580" y2="1050" stroke="#31c9ff" stroke-opacity="0.35" stroke-width="2"/>
</svg>
SVG

sed -e "s/__NUMBER__/${number}/g" \
    -e "s/__TOPIC__/${topic_upper}/g" \
    /tmp/sre-banner.svg > /tmp/sre-banner-rendered.svg

rsvg-convert -w 2400 -h 1260 /tmp/sre-banner-rendered.svg -o "${out}"

echo "Gerado: ${out}"
