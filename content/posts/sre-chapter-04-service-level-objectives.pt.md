---
date: '2026-11-21T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Objetivos de Nível de Serviço'
translationKey: sre_chapter_04_service_level_objectives
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-04.png
translation:
  url: /en/posts/sre-chapter-04-service-level-objectives/
  text: English version
---

Este é o quarto post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de apresentar o error budget no capítulo 3, o livro agora formaliza o vocabulário que sustenta tudo isso: **SLI, SLO e SLA** — como medir um serviço, que meta definir e o que acontece se a meta não for cumprida.

## A terminologia: SLI, SLO e SLA

Três siglas que muita gente usa como sinônimo, e que o livro faz questão de separar:

- **SLI** (indicador de nível de serviço): a medida quantitativa de um aspecto do serviço — latência de resposta, taxa de erro, throughput, disponibilidade.
- **SLO** (objetivo de nível de serviço): o alvo que o SLI deve atingir. Ex.: "a latência média das buscas deve ficar abaixo de 100 ms". A estrutura natural é `SLI ≤ alvo`.
- **SLA** (acordo de nível de serviço): o contrato com o usuário — e, principalmente, a **consequência** se o SLO não for cumprido (multa, desconto, rescisão).

O teste rápido que o livro dá para separar SLO de SLA: **"o que acontece se a meta não for cumprida?"** Se não há consequência explícita, é SLO. E uma observação honesta: quase todo mundo que fala em "violação de SLA" está, na prática, falando de um SLO não cumprido.

O detalhe importante: **o SRE não costuma construir SLAs** — isso é decisão de negócio e jurídico. O papel do SRE é definir SLIs objetivos e ajudar a cumprir os SLOs para não disparar a consequência.

**SLI é o que você mede; SLO é a meta; SLA é a promessa com preço de quebra.**

## O que medir: comece pelo usuário

O erro clássico é medir tudo o que o monitoramento consegue. O livro inverte: **comece pelo que o usuário se importa e escolha poucos indicadores**.

Os serviços caem em categorias:

- **Serviços que atendem usuário final** (como a busca Shakespeare): **disponibilidade** (a requisição respondeu?), **latência** (quanto tempo levou?) e **throughput** (quantas requisições por segundo?).
- **Sistemas de armazenamento**: **latência**, **disponibilidade** e **durabilidade** (o dado continua lá anos depois?).
- **Big data e pipelines**: **throughput** e **latência ponta a ponta**.
- **Todos** devem se importar com **correção**: a resposta certa foi retornada?

A disponibilidade, na prática, vira **taxa de sucesso de requisição**: a fração de requisições bem-formadas que respondem certo. O capítulo lembra que 100% é impossível, e que "noves" é a forma comum — 99% são "2 noves", 99,999% são "5 noves". O Google Compute Engine, por exemplo, publica "três noves e meio": 99,95%.

**Um punhado de indicadores que refletem o usuário vale mais que uma parede de dashboards.**

## Coletar: servidor, cliente e a cauda

Métrica parece simples até você pensar em como coletar. A maioria nasce no **lado do servidor** (Borgmon, Prometheus, análise de log). Mas medir só o servidor esconde problema que afeta o usuário — um JavaScript pesado na página pode deixar a busca lenta para o cliente mesmo com o backend rápido. Por isso alguns SLIs precisam ser coletados no **lado do cliente**.

O segundo cuidado é a **agregação**. A média esconde a cauda: dá para a maioria das requisições ser rápida e 5% delas serem **20 vezes mais lentas**. O livro recomenda trabalhar com **percentis** (p50, p99, p99.9) em vez de média, e tratar métrica como **distribuição**, não como número único. Um detalhe técnico: não dá para assumir que os dados são normais — e agir sobre outliers sem verificar a distribuição pode te fazer reiniciar servidor à toa.

**Média é um jeito confortável de mentir sobre latência; use percentis.**

## Escolher o alvo: menos é mais

Definir o SLO não é só atividade técnica — tem implicação de produto e negócio. O livro dá cinco regras:

1. **Não copie a performance atual** — adotar o valor de hoje pode te travar num sistema que exige esforço heroico.
2. **Mantenha simples** — agregação complicada esconde mudança e é difícil de raciocinar.
3. **Evite absolutos** — "infinito" e "sempre disponível" não existem, e custam caro à toa.
4. **Tenha o mínimo de SLOs** — se você nunca ganha uma discussão de prioridade citando um SLO, ele não vale a pena ter.
5. **A perfeição pode esperar** — comece com alvo folgado e aperte conforme aprende; afrouxar depois é doloroso.

Na prática, o SLO é a alavanca que prioriza o trabalho do SRE e do time de produto. **Um SLO bem pensado é uma forcing function legítima; um mal pensado gera trabalho desperdiçado.**

## Chubby: quando estar bom demais vira problema

A história mais contraintuitiva do capítulo. O **Chubby** — o serviço de lock distribuído do Google, que já apareceu no capítulo 2 — é tão confiável que os times começaram a **depender dele assumindo que nunca cairia**. A alta disponibilidade virou uma falsa sensação de segurança: quando o Chubby caía (raramente), derrubava uma cascata de serviços que não sabiam funcionar sem ele.

A solução do Google é genial e um pouco assustadora: **o Chubby cumpre o SLO, mas não pode excedê-lo**. Se num trimestre nenhuma falha real derrubou a disponibilidade abaixo do alvo, o SRE **sintetiza uma queda controlada** — derruba o sistema de propósito para "expulsar" dependências irracionais logo depois de criadas. ([descrição completa no livro](https://sre.google/sre-book/service-level-objectives/#xref_risk-management_global-chubby-planned-outage))

Isso amarra duas lições do capítulo: **não entregue mais que o prometido** (os usuários constroem sobre a realidade, não sobre o que você disse) e **deixe uma margem de segurança interna** maior que a publicada.

## O que eu levo deste capítulo

Este é um dos capítulos que mais me colocou na parede — e uma das razões de eu estar escrevendo esta série.

**Eu nunca defini um SLO formal na minha carreira.** Operei quase 200 serviços e máquinas virtuais num cluster VMware na **Soluti**, monitorando com Zabbix — CPU, memória, disco. A palavra "disponibilidade" estava no meu vocabulário o tempo inteiro, mas era **intuição, não indicador**. O Zabbix media saúde de recurso, que é proxy de saúde; não media o que o usuário sente — taxa de sucesso, latência na ponta do cliente. E, sem um SLO publicado, a expectativa ficava implícita, exatamente o cenário que o capítulo alerta: cada um acha o que quiser.

Nos meus trabalhos mais recentes, definir SLI, SLO e SLA também não passa diretamente por mim ou pela equipe. Atendemos uma série de clientes com **requisitos de compliance diferentes**, e alguns exigem que essas métricas sejam definidas por **equipes específicas ou órgãos reguladores** — o que limita o quanto influenciamos esses parâmetros. O que segue nas nossas mãos é **monitorar e analisar os dados**: medir se o padrão está sendo cumprido e perseguir melhoria contínua. **Se a meta vem de fora, medir e melhorar continua sendo engenharia.**

Para mim, o capítulo 4 marca a passagem **da operação para a engenharia**: de "mantém no ar" para "mede e negocia o que 'no ar' significa". É a ponte entre o que eu fazia e o que eu quero fazer — e por isso ele entra na minha lista de estudo contínuo.

A ideia que mais muda a minha postura: **você não precisa prometer 100% — você precisa prometer um número e cumpri-lo, sem exceder tanto a ponto de virar dependência.** Disponibilidade é contrato, não virtude.

Como parte do aprendizado contínuo, tenho desenvolvido alguns projetos open source para praticar e entender essas disciplinas — e aprimorar o conhecimento para, quando precisar colocá-las em prática, fazer da forma mais correta possível.

É o caso do SLO. No **srectl** eu posso definir SLIs reais (latência e taxa de erro de um app de exemplo), fixar um SLO e instrumentar um **error budget burn** para ver o orçamento sendo consumido — o que transforma a teoria deste capítulo em algo que eu executo, não só leio.

Se você quiser conhecer (e, por que não, usar para praticar também), os projetos estão abertos no GitHub:

- [**srectl**](https://github.com/fabianoflorentino/srectl) — ambiente local de treinamento em SRE, DevOps e Platform Engineering, em Go, com Kubernetes, Argo CD e a stack LGTM (Loki, Grafana, Tempo e Mimir).
- [**seraph**](https://github.com/fabianoflorentino/seraph) — status board independente e sem anúncios que lê páginas de status oficiais e publica a situação dos seus serviços; o lugar natural onde um SLO vira algo publicado.
- [**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) — ferramenta de validação de certificados SSL/TLS, um SLI concreto disfarçado: certificado expirado é serviço indisponível para o usuário.
- [**fraudctl**](https://github.com/fabianoflorentino/fraudctl) — API em Go que recebe pagamentos e analisa se são fraudulentos ou não; participou da **Rinha de Backend** deste ano e ficou em **19º lugar**. Um ótimo campo de teste para os SLIs do capítulo (latência, taxa de erro, disponibilidade) — [ranking da competição](https://rinhadebackend.com.br/).

Esses projetos foram o jeito que encontrei de transformar leitura em habilidade.

## Próximos capítulos

No próximo post, vou falar do **Capítulo 5: Eliminando o toil** (_Eliminating Toil_). É o capítulo que nomeia o trabalho manual e repetitivo que não gera valor — e que, na minha história, foi o que me empurrou para Puppet e Ansible.

Acompanhe a série pela página [/series/sre/](/series/sre/).
