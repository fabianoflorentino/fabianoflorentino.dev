---
date: '2026-11-20T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Abraçando o Risco'
translationKey: sre_chapter_03_embracing_risk
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-03.png
translation:
  url: /en/posts/sre-chapter-03-embracing-risk/
  text: English version
---

Este é o terceiro post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de entender o ambiente de produção, o livro agora apresenta uma das ideias mais contraintuitivas — e mais importantes — do SRE: **por que 100% de disponibilidade é a meta errada**.

## Por que 100% não é a meta

Parece absurdo à primeira vista. Por que o Google não tentaria fazer serviços que nunca falham?

O capítulo responde com uma constatação simples: **a partir de certo ponto, mais confiabilidade piora o serviço em vez de melhorá-lo**. Confiabilidade extrema custa caro — limita a velocidade com que novas funcionalidades são desenvolvidas, encarece o produto e reduz o número de features que um time consegue bancar.

E há um detalhe ainda mais forte: **os usuários não percebem a diferença**. Quem usa um smartphone que já é 99% confiável não consegue distinguir um serviço 99,99% de um 99,999% — a experiência é dominada por componentes menos confiáveis, como a rede celular.

A conclusão é a essência do capítulo: **o SRE não busca maximizar uptime, e sim equilibrar o risco de indisponibilidade com a inovação rápida**. O que se otimiza é a felicidade total do usuário — features, serviço e performance juntos.

## Confiabilidade tem custo e não é linear

O livro faz uma afirmação desconfortável: **o custo não cresce de forma linear com a confiabilidade**. Subir mais um "nove" de disponibilidade pode custar 100x mais que o incremento anterior.

Esse custo tem duas dimensões:

- **Recursos redundantes** — máquinas e equipamentos extras que permitem tirar sistemas do ar para manutenção, ou armazenar blocos de paridade para durabilidade.
- **Custo de oportunidade** — engenheiros alocados para reduzir risco em vez de construir features visíveis para o usuário. Cada engenheiro dedicado à confiabilidade é um que não está entregando produto novo.

O SRE trata risco como um **continuum**. O objetivo é deixar o serviço **confiável o suficiente — mas não mais confiável do que precisa ser**. O alvo de disponibilidade vira, ao mesmo tempo, um mínimo e um máximo.

## Medindo o risco

Como transformar "risco" em algo mensurável? O livro foca no **downtime não planejado**, expresso em "noves" de disponibilidade: 99,9%, 99,99%, 99,999%. Cada nove a mais representa uma ordem de magnitude.

Para ter noção: um alvo de 99,99% permite **52,56 minutos de indisponibilidade por ano**. A tabela completa está no [apêndice do livro](https://sre.google/sre-book/availability-table/).

Mas o Google raramente usa métrica baseada em tempo. Como os serviços são distribuídos globalmente, "estar parcialmente no ar" é a regra. Por isso a disponibilidade é medida por **taxa de sucesso de requisição** sobre uma janela: um serviço que atende 2,5 milhões de requisições por dia com alvo de 99,99% pode errar até 250 requisições.

## Quanto risco cada serviço aguenta

A tolerância a risco não é um número mágico — ela depende do serviço. O livro divide a análise entre serviços de consumo e de infraestrutura.

**Serviços de consumo** têm um time de produto que traduz metas de negócio em objetivos. A disponibilidade-alvo depende de: o que os usuários esperam, se o serviço está ligado a receita, se é pago ou gratuito, e o que a concorrência oferece. Exemplos: o **Google Apps for Work** mira 99,9% (usuários empresariais que dependem dele para trabalhar); o **YouTube**, logo após a aquisição, ganhou um alvo mais baixo — naquele momento, velocidade de evolução valia mais que estabilidade extrema.

Também importa o **tipo de falha**. Falha constante de baixa intensidade é diferente de um outage total. O exemplo do capítulo é contundente: numa aplicação de contatos, fotos que não carregam é chato; **expor dados privados de um usuário a outro** é grave o suficiente para derrubar o serviço inteiro durante a investigação.

E há o **custo**. No caso do Ads, o trade-off é direto: cada requisição se traduz em receita. O livro dá a conta — para um serviço de $1M, subir de 99,9% para 99,99% vale $900; só compensa investir se o custo for menor que isso. Um atalho útil: a taxa de erro de fundo dos ISPs fica entre 0,01% e 1%; errar abaixo disso é "sumir no ruído".

**Serviços de infraestrutura** são mais complexos, porque têm múltiplos clientes com necessidades opostas. O exemplo do **Bigtable** é perfeito: quem serve dados no caminho da requisição quer latência baixa e filas vazias; quem faz análise offline quer throughput e fila nunca vazia. A solução é **particionar o serviço em níveis**: clusters de baixa latência (caros) e clusters de throughput (muito mais baratos, às vezes 10–50% do custo). No Google+, dados críticos de privacidade iam para o **Spanner** (consistente e global), e dados opcionais para um datastore mais barato. ([descrições de Bigtable e Spanner no capítulo 2](/posts/sre-chapter-02-production-environment/))

A lição geral: **exponha o custo e deixe o cliente escolher o nível de serviço**. Constrangimentos que parecem incompatíveis se resolvem quando cada nível de serviço tem preço explícito.

## Error budget: risco que vira decisão

A parte mais prática do capítulo. Existe uma tensão natural entre o time de produto (quer velocidade) e o SRE (quer confiabilidade). Cada um enxerga metade do problema — e, sem um critério objetivo, a negociação vira política. O lema não-oficial do SRE resume: **"esperança não é estratégia"** (_hope is not a strategy_).

O **error budget** resolve isso. Funciona assim:

1. O time de produto define um **SLO** — quanto uptime o serviço deve ter por trimestre.
2. O monitoramento mede o uptime real, como parte neutra.
3. A diferença entre os dois é o **orçamento de erro** — quanta "indisponibilidade" ainda resta no trimestre.

Na prática: um SLO de 99,999% dá um orçamento de erro de 0,001% de falhas. Se um problema causar 0,0002% de falhas, ele gastou **20% do orçamento** do trimestre.

A mágica é que o error budget **alinha incentivos**. Enquanto há orçamento, o time pode lançar rápido. Quando ele está quase esgotado, o próprio time de produto passa a pedir mais testes e menos pressa — porque ninguém quer estourar o orçamento e travar o lançamento. O time passa a se **autopoliciar**. E, se o time estiver com dificuldade de lançar, pode afrouxar o SLO — aumentando o orçamento — para ganhar velocidade.

## O que eu levo deste capítulo

O que mais me marcou neste capítulo foi ver o livro dar nome a uma tensão que eu vivi o tempo inteiro, sem nunca ter um critério claro para resolvê-la.

Na autoridade certificadora onde trabalhei, a conversa entre desenvolvimento e operação era sempre a mesma: **um lado queria entregar, o outro queria estabilizar** — e não havia número nenhum para arbitrar. Foi só quando comecei a adotar **DevOps**, aproximando os times, que entendi que o problema não era de gente, era de **falta de um objetivo compartilhado**. O error budget é exatamente isso: um objetivo que os dois lados aceitam e que tira a decisão do terreno da política.

A ideia de "confiável o suficiente" também mudou como eu via projeto. Em um grande varejista brasileiro, o ambiente de **produção e desenvolvimento compartilhava o mesmo cluster Kubernetes** — ou seja, o negócio estava assumindo um risco que ninguém tinha quantificado. Separar em clusters dedicados não foi só uma melhoria técnica: foi **alinhar o risco aceito à tolerância real do negócio**. Produção passou a ter alta disponibilidade, e desenvolvimento ganhou liberdade para errar sem derrubar o cliente.

E o custo de oportunidade, para mim, é a parte mais honesta. Todo tempo que eu passava entregando servidor na mão ou apagando incêndio era tempo **não investido** em melhorar o ambiente. Quando automatizei com Puppet e Ansible — de **dias para minutos**, com a fila de chamados caindo **mais de 60%** — o que ganhei não foi só velocidade: foi a devolução desse tempo para engenharia de verdade.

No fim, a ideia que fica é esta: **confiabilidade não é um fim em si mesmo**. É uma moeda que você troca por velocidade, custo e features. Quem trata disponibilidade como dogma paga caro; quem trata como orçamento faz escolhas conscientes.

## Próximos capítulos

No próximo post, vou falar do **Capítulo 4: Service Level Objectives**. É onde o livro formaliza o que o error budget assume: como definir SLOs, SLIs e SLAs — e por que escolher os indicadores certos é metade do trabalho.

Acompanhe a série pela página [/series/sre/](/series/sre/).
