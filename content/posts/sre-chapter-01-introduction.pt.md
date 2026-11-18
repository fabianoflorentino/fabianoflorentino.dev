---
date: '2026-11-18T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Introdução'
translationKey: sre_chapter_01_introduction
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-01.png
translation:
  url: /en/posts/sre-chapter-01-introduction/
  text: English version
---

Este é o primeiro post de uma série em que vou percorrer o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/), capítulo por capítulo, conectando as ideias com a realidade de quem vive a operação no dia a dia.

## Por que começar por aqui

O capítulo 1 é curto, mas talvez seja o mais importante de todos. É nele que o livro define o que SRE significa — e, mais importante, **por que o Google sentiu que precisava criar essa função**.

Antes de falar de SLO, alertas ou postmortem, vale entender o problema que o SRE tenta resolver. Sem esse contexto, todo o resto vira receita solta.

## O jeito tradicional de operar

Durante muito tempo, operar sistemas foi tratado como um trabalho essencialmente manual: times de sysadmins cuidavam de servidores, respondiam a incidentes, faziam deploys e aplicavam correções "na mão".

O livro chama isso de _sysadmin approach_ (abordagem do administrador de sistemas). E aponta dois custos bem concretos desse modelo:

- **Custo direto:** conforme o sistema cresce, você precisa de mais gente para operá-lo. Escalar operação vira uma corrida para contratar — e o custo cresce de forma quase linear.
- **Custo indireto:** existe um atrito natural entre o time de desenvolvimento (que quer entregar rápido) e o time de operação (que quer estabilidade). Quando os objetivos divergem, a culpa circula e a confiança se desgasta.

Nesse modelo, o trabalho operacional é visto como algo **separado da engenharia** — e, pior, como algo que não melhora por meio de código. Você resolve o mesmo incidente de novo e de novo, sempre no braço.

## A aposta do Google

O Google propôs uma saída diferente. Em vez de contratar mais operadores, contratou **engenheiros de software para cuidar da operação** — e chamou esse time de Site Reliability Engineering.

A frase que abre o livro resume a inversão de lógica:

> SRE é o que acontece quando você pede para um engenheiro de software projetar um time de operações.

Atribuída a Ben Treynor Sloss (criador do termo), essa definição muda tudo. A operação deixa de ser um "mal necessário" e passa a ser encarada como um **problema de engenharia**.

Na prática, isso significa:

- tratar o trabalho operacional como software: automatizar, versionar, testar;
- aplicar as mesmas boas práticas de engenharia à infraestrutura;
- reduzir o trabalho repetitivo (**toil**) para liberar tempo para projetos que melhoram a confiabilidade de verdade.

O livro também menciona uma divisão de tempo que virou referência: SREs dedicam, idealmente, **no máximo 50% do tempo a trabalho operacional** (on-call, incidentes, mudanças) e o restante a **engenharia** — ferramentas, automação e melhorias estruturais. Se o toil começa a engolir o time, algo está errado e precisa ser corrigido.

## Os princípios que sustentam tudo

O capítulo lista os objetivos centrais do SRE. Vale decorar, porque praticamente todo o resto do livro é um desdobramento deles:

1. **Foco duradouro em engenharia** — a operação não pode engolir o time; precisa sobrar tempo para construir.
2. **Velocidade de mudança sem violar o SLO** — entregar rápido, mas dentro de um limite acordado de confiabilidade (o _error budget_).
3. **Monitoramento** — entender o comportamento do sistema por meio de sinais, não só de "checks" binários.
4. **Resposta a emergências** — ter processo claro para quando o pior acontece.
5. **Gestão de mudanças** — mudar com segurança e previsibilidade.
6. **Previsão de demanda e planejamento de capacidade** — saber para onde o sistema vai antes de quebrar.
7. **Provisionamento** — entregar recursos de forma consistente e automatizada.
8. **Eficiência e performance** — fazer mais com menos, sem sacrificar a confiabilidade.

Perceba que quase tudo isso é **trabalho de engenharia**, não "trabalho de apagar incêndio". Essa é a essência da proposta.

## O que eu levo deste capítulo

Eu não conhecia o termo SRE quando comecei a praticá-lo. Foi na **Soluti**, ainda como analista de infraestrutura, que dei os primeiros passos — sem saber: ao implementar gestão de configuração com Puppet, automação e monitoramento com Zabbix e Rundeck, eu estava, na prática, reduzindo toil e tratando a operação como um problema de engenharia.

Na **2Com**, em uma passagem breve, veio a prova mais concreta de que isso funciona: automatizei um processo custoso que levava cerca de **três dias** para ser concluído e passou a rodar em **poucos minutos**, desde que o ambiente do cliente estivesse preparado. Foi a primeira vez que eliminei toil de verdade — e a primeira vez que senti, na pele, o impacto da disciplina.

Levei esses ensinamentos para a **IBM** e, depois, para a **Kyndryl**, gerenciando ambientes críticos de grandes clientes. Lá, o padrão se repetiu: melhorar processos e automatizar operações repetitivas (ou de alto custo de tempo), transformando dias em minutos.

A operação tradicional me ensinou a reagir. O SRE me ensinou a **projetar**. Não é sobre ser mais rápido no incidente; é sobre reduzir a chance de ele acontecer — e, quando acontecer, ter um sistema que se recupera com o mínimo de intervenção.

Também gosto da honestidade do modelo: ninguém promete 100% de disponibilidade. O que se negocia é **quanto de indisponibilidade é aceitável** e, a partir daí, quanto de velocidade de entrega você "compra". É uma troca explícita, não um desejo vago.

## Próximos capítulos

No próximo post, vou falar do **Capítulo 2: O ambiente de produção no Google do ponto de vista de um SRE**. É onde o livro descreve o ecossistema (Borg, Chubby, Bigtable e companhia) e começa a dar nome às peças que sustentam a confiabilidade.

Acompanhe a série pela página [/series/sre/](/series/sre/).
