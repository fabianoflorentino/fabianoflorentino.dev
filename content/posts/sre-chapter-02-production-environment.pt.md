---
date: '2026-11-19T00:00:00Z'
draft: true
title: 'Site Reliability Engineering: O Ambiente de Produção'
translationKey: sre_chapter_02_production_environment
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-02.png
translation:
  url: /en/posts/sre-chapter-02-production-environment/
  text: English version
---

Este é o segundo post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de definir o que é SRE no capítulo 1, agora o livro desce um nível e descreve o palco onde tudo acontece: **o ambiente de produção**.

## Por que entender o ambiente

Parece óbvio, mas é fácil pular essa parte: **você não consegue tornar confiável algo que não entende**. Antes de falar de SLO, alerta ou incidente, o SRE precisa ter um mapa mental claro de onde os serviços rodam e do que depende cada camada.

O capítulo 2 é, essencialmente, esse mapa — do hardware até o software de infraestrutura que sustenta os serviços do Google.

## Hardware: computação em escala de armazém

O primeiro ponto do capítulo é uma mudança de mentalidade. O Google trata seus datacenters como **computadores em escala de armazém** (_warehouse-scale computing_): milhares de máquinas homogêneas que, juntas, funcionam como um único computador gigante.

A consequência prática é que **máquinas não são especiais**. Elas quebram o tempo todo, em grande quantidade. A confiabilidade não vem de um hardware confiável, e sim de software que **assume a falha e a contorna** — replicação, redundância e tolerância a falhas em cada camada.

É a filosofia que a comunidade resumiu em "trate servidores como gado, não como animais de estimação". O Google usa outra metáfora: gerencia máquinas como quem cuida de um **rebanho**, não de indivíduos.

## O software que organiza o hardware: Borg

Ninguém administra milhares de máquinas na mão. O Google criou o **Borg**, o sistema de gestão de cluster que agenda tarefas, aloca recursos e decide onde cada job roda.

Por que isso importa para um SRE? Porque o Borg é a camada que transforma "um monte de máquinas" em "uma plataforma". E, mais importante: **o Kubernetes é o descendente open source do Borg**. Quem trabalha com Kubernetes hoje está, em certo sentido, usando as mesmas ideias que o Google consolidou anos atrás.

Se quiser entender o Borg em detalhes — como ele distribui jobs em tarefas, usa o Borg Naming Service (BNS) e faz o *binpacking* dos recursos — veja a [descrição completa no livro](https://sre.google/sre-book/production-environment/#managing-machines-XQsKIBTq).

## Armazenamento: Colossus, Bigtable e Spanner

O armazenamento no Google é organizado em camadas, e o capítulo apresenta três sistemas que se apoiam uns nos outros:

**Colossus** é o sistema de arquivos distribuído do cluster — sucessor do GFS — que oferece semântica de filesystem, replicação e criptografia. É a base sobre a qual os bancos de dados são construídos. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

**Bigtable** é um banco NoSQL distribuído, capaz de lidar com bancos na casa dos petabytes, usado para dados estruturados em larga escala (índices de busca, YouTube e muitos outros), com replicação entre datacenters e consistência eventual. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

**Spanner** é o banco SQL globalmente distribuído, para quem precisa de consistência forte e semântica relacional em escala mundial. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM))

A lição aqui não é decorar os nomes, e sim perceber o padrão: **cada camada de dados é construída para sobreviver à falha**. A durabilidade não é um acidente; é um requisito de projeto.

## Rede: Jupiter e GSLB

Na rede, o capítulo descreve o **Jupiter**, o tecido de rede do datacenter com alta largura de banda, e o **GSLB** (_Global Software Load Balancer_), que distribui tráfego entre datacenters e regiões.

De novo, a ideia é a mesma: a rede é tratada como um recurso de software, programável e redundante, não como cabos fixos. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#networking-2ksZhrT8))

## Serviço de lock: Chubby

Um detalhe que muita gente acha curioso: o Google tem um **serviço de lock distribuído** chamado Chubby, usado para eleição de líder e coordenação entre sistemas. Baseado em Paxos, ele resolve o problema de "quem é o responsável agora" em um ambiente distribuído.

Parece nicho, mas é a fundação de coisas como eleger quem é o líder de um cluster — um problema que aparece em praticamente qualquer sistema distribuído. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#lock-service-jWsjIlcM))

## Monitoramento: ver o ambiente

Por fim, o capítulo fala de **monitoramento e alerta** como parte integrante do ambiente — no Google, sistemas como o Borgmon coletam métricas em série temporal para dar visibilidade ao que acontece.

O ponto-chave: **monitoramento não é um acessório que você adiciona depois**. É parte da plataforma, assim como storage e rede. ([descrição completa no livro](https://sre.google/sre-book/production-environment/#monitoring-and-alerting-2ksLtBc8))

## O que eu levo deste capítulo

Esse capítulo me pegou porque ele descreve, em escala planetária, uma trajetória que eu percorri em escala bem menor.

Comecei cuidando de servidores físicos, um por um — o oposto do "rebanho". Na época de analista de infraestrutura em uma autoridade certificadora, a primeira virada de chave foi **virtualizar e criar um cluster**: servidores isolados viraram um parque de quase **200 serviços e máquinas virtuais**, com melhor aproveitamento de CPU e memória e, principalmente, mais disponibilidade. Foi meu primeiro contato com a ideia de tratar recursos como algo gerenciável em conjunto, não como caixas individuais.

Depois, já trabalhando com **Kubernetes**, vi a mesma lógica do Borg em ação. Em um projeto para um grande varejista brasileiro, o problema era exatamente um daqueles que o capítulo ensina a evitar: **produção e desenvolvimento dividiam o mesmo cluster**. Criar clusters separados trouxe isolamento, alta disponibilidade e estabilidade para a produção. Foi a versão moderna, e bem mais simples, daquilo que o Google faz com o Borg.

E há o monitoramento. Passei de "olhar a console de virtualização" para **Zabbix e Grafana**, monitorando ambientes críticos de grandes clientes (Linux, Windows, AIX e bancos). Foi ali que entendi o que o capítulo diz: **monitoramento é parte da plataforma**. Em mais de uma ocasião, o time conseguiu identificar um problema antes de virar alerta — o comportamento proativo que o capítulo assume como padrão.

A grande lição, para mim, é a seguinte: **subir a pilha muda a sua relação com a confiabilidade**. Quem só vê o servidor físico acha que confiabilidade é "comprar hardware melhor". Quem enxerga o ambiente como camadas entende que confiabilidade é **arquitetura** — replicação, isolamento, observabilidade e software assumindo a falha.

## Próximos capítulos

No próximo post, vou falar do **Capítulo 3: Abraçando o risco** (_Embracing Risk_). É onde o livro apresenta uma das ideias mais importantes do SRE: o **error budget** e por que 100% de disponibilidade não é a meta.

Acompanhe a série pela página [/series/sre/](/series/sre/).
