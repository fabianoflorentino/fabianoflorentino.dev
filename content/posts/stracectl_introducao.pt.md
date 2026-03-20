---
date: '2026-03-19T00:00:00Z'
draft: false
title: 'Você conhece o strace?'
translationKey: stracectl_introducao
tags: [post, strace, linux, sistema operacional]
image: /images/strace-banner.jpg
---

Na primeira semana de março a **[linuxtips](https://linuxtips.io/)** junto com o **[Jefferson](https://www.linkedin.com/in/jefersonfernando/)** organizaram um evento online 100% gratuita sobre devops e tudo que permeia essa área a **[Semana DevOps](https://linuxtips.io/semana-devops)**. O evento contou com palestras de diversos profissionais da área, e no primeiro dia, o Jefferson apresentou uma palestra sobre o Profissional de TI na era Cloud Native.

Já no segundo dia, ele falou sobre construir infraestrutura com linux e terraform. Em certo ponto da palestra, ele falou sobre como os antigos administradores de sistemas (Sysadmin) tinham o domínio sobre várias ferramentas de troubleshooting, e que se você não conhecia o `strace`, você não era um verdadeiro Sysadmin.

Ele não falou exatamente isso, mas foi como eu me senti quando me peguei lembrando do quão pouco eu usei essa ferramenta. Como um execelente professor que é deu uma breve introdução sobre o `strace`, e mostrou como ele é poderoso para entender o que está acontecendo com um processo, e como ele pode ser útil para identificar gargalos, erros, e até mesmo para aprender como o sistema operacional funciona.

Abri um terminal e rodei o programa e vi o porque de não ter usado ele tanto. A saída do `strace` é verbosa e só com muita prática e conhecimento do sistema operacional para entender o que está acontecendo.

Logo em seguida, lembrei do papo que o **[Fábio Akita](https://akitaonrails.com/)** teve com o **[mano dayvin](https://manodeyvin.com.br/)** no **[canal dele](https://www.youtube.com/watch?v=G_8uG1Ot0yo)** e de como ele fez uma imersão de como criar projetos usando AI e vibe coding. Se interesar você pode ser a série dos artigos que ele fez sobre o assunto, começando por **[37 dias de Imersão em Vibe Coding: Conclusão quanto a Modelos de Negócio](https://akitaonrails.com/2026/03/05/37-dias-de-imers%C3%A3o-em-vibe-coding-conclus%C3%A3o-quanto-a-modelos-de-neg%C3%B3cio/)**.

Então, já que a bolha dev não fala de outra coisa que não seja **AI** e **vibe coding**, porque não tentar usar a mesma abordagem para aprender melhor sobre o `strace` e também entender melhor sobre esse processo de criar as coisas usando AI?

---

## stracectl?

Por que stracectl? Seguindo o que a maioria das boas ferramentas escritas em Go usam com `ctl` no nome, `kubectl`, `etcdctl`, `consulctl`, etc, o `stracectl` é uma ferramenta de linha de comando que tem como objetivo tornar o uso do `strace` mais acessível e fácil de entender. Ele é um wrapper em Go que roda o `strace` e processa a saída para apresentar informações mais das syscalls e do processo de forma mais amigável e visual.

## Resumo rápido

`stracectl` transforma a saída do `strace` em um dashboard interativo (TUI) e em uma API HTTP para modo sidecar. Em vez de vasculhar um fluxo gigante de syscalls, você vê agregações em tempo real: contagens, latências (AVG, MAX, P95/P99), taxas de erro e uma visão por categoria (I/O, FS, NET, MEM, PROC). Ideal para debugging local, análise pós-morte e troubleshooting em Kubernetes.

Por que usar

- Reduz o ruído do `strace` e mostra o que realmente importa.
- Atualização em tempo real com interface estilo `htop`.
- Modo sidecar HTTP para expor dados via JSON, WebSocket e Prometheus.
- Relatórios HTML auto-contidos para análises posteriores.
- Backend opcional por eBPF (quando disponível) para maior precisão.

Principais recursos

- Real-time aggregation: agregação ao vivo dos syscalls sem arquivo intermediário.
- Colunas de latência: AVG, MAX, TOTAL, P95 e P99 por syscall.
- Per-errno breakdown: quantos erros por código (`ENOENT`, `EACCES`, …) e buffer de amostras.
- Smart anomaly alerts: indicadores visuais e mensagens explicando anomalias.
- Detail overlay: pressione Enter em qualquer syscall para ver assinatura, argumentos, errno e estatísticas ao vivo.
- Built-in syscall reference: referência rápida para ~50 syscalls com assinaturas e notas.
- Sidecar mode: `--serve` expõe APIs e dashboard HTML, útil em ambiente Kubernetes.
- Post-mortem: reexecute logs `strace -T -o` e obtenha as mesmas visualizações.

Novidades na v1.0.94 (destaques)

- Top Files: overlay de arquivos mais abertos (TUI) e endpoint `/api/files`.
- Melhor atribuição no agregador (fd→path).
- TUI: coluna `FILE`, truncamento seguro com runes e sanitação de bytes de controle.
- Server: deadlines do WebSocket, métricas Prometheus adicionais e handlers de debug/pprof.

Instalação rápida
Pré-requisitos: Linux (usa `ptrace` via `strace`), Go 1.26+, `strace` instalado. eBPF é opcional e requer kernel ≥ 5.8, `clang`, headers e `bpf2go`.

Exemplos:

- Trace um novo comando:
`sudo stracectl run curl https://example.com`
- Anexar a um PID:
`sudo stracectl attach 1234`
- Analisar um log `strace` salvo:
`stracectl stats trace.log`
- Modo sidecar (HTTP + WebSocket + Prometheus):
`sudo stracectl run --serve :8080 curl https://example.com`
- Gerar relatório HTML:
`sudo stracectl run --report report.html curl https://example.com`

Autenticação WebSocket

Use `--ws-token` para exigir token na conexão WebSocket. Exemplos de cliente:

- `wscat` com header:
`wscat -c ws://localhost:8080/stream -H "Authorization: Bearer SUPER_SECRET_TOKEN"`
- Browser (use query string + TLS):
`new WebSocket('wss://example.com/stream?token=SUPER_SECRET_TOKEN')`
Nota: preferir `Authorization: Bearer` quando possível — query strings podem vazar.

Casos de uso práticos

- Diagnosticar hotspots de I/O (arquivos mais acessados, latências).
- Entender padrões de erro frequentes (p.ex. ENOENT em probing do linker).
- Depurar falhas intermitentes em contêineres sem ocupar o terminal do pod (modo sidecar).
- Reproduzir investigações a partir de um `strace` salvo com relatórios HTML.

Como contribuir / onde achar
O projeto está no GitHub — clone, rode `go build` para compilar localmente, ou use a imagem Docker oficial. Abra issues com edge cases do parser, sugestões para a UI, ou PRs para docs e features.

Conclusão
stracectl é uma abordagem prática para tornar tracing mais humano: menos log cru, mais insights acionáveis. Se você já recorreu ao `strace` e sentiu que gastou mais tempo filtrando do que entendendo, vale testar o stracectl.
