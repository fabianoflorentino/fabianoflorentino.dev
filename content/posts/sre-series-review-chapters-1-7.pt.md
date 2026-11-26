---
date: '2026-11-26T00:00:00Z'
draft: true
title: 'Site Reliability Engineering: O que vimos até aqui'
translationKey: sre_series_review_chapters_1_7
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-review.png
translation:
  url: /en/posts/sre-series-review-chapters-1-7/
  text: English version
---

Depois de sete capítulos, vale olhar para trás antes de seguir. Este post é uma pausa entre o capítulo 7 e o capítulo 8: uma chance de revisitar o caminho, organizar o que ficou e chegar a **Release Engineering** com o terreno mais firme.

A continuação é o **Capítulo 8: Engenharia de release**. Aqui, a ideia não é repetir o que já foi dito, mas enxergar as conexões que só aparecem depois de ler tudo em sequência.

## O que vimos até aqui

O [capítulo 1](/posts/sre-chapter-01-introduction/) fez a pergunta que sustenta a série até aqui: o que muda quando a operação é tratada como engenharia? A resposta não veio como cargo ou ferramenta, mas como postura — parar de apagar incêndio e começar a projetar. A meta de manter o toil abaixo de 50% apareceu como consequência disso.

O [capítulo 2](/posts/sre-chapter-02-production-environment/) mostrou o palco. Borg, armazenamento, rede, locks e monitoramento deixaram de ser nomes soltos e viraram camadas de um mesmo desenho. A confiabilidade não estava no hardware, mas na arquitetura que assume a falha.

Os capítulos 3 e 4 deram o vocabulário do risco. O [capítulo 3](/posts/sre-chapter-03-embracing-risk/) derrubou a ideia de que 100% é a meta: confiabilidade custa, tem retorno decrescente, e o error budget transforma essa tensão em decisão.

O [capítulo 4](/posts/sre-chapter-04-service-level-objectives/) deu nome às peças — SLI, SLO e SLA — e lembrou que medir o usuário, olhar a cauda e escolher poucos indicadores vale mais que uma parede de dashboards. O caso do Chubby ficou como aviso de que ser bom demais também pode ser um problema.

Os três capítulos seguintes olharam para o trabalho. O [capítulo 5](/posts/sre-chapter-05-eliminating-toil/) definiu o toil: não é o trabalho chato, é o que não deixa o sistema melhor depois que você termina. O [capítulo 6](/posts/sre-chapter-06-monitoring-distributed-systems/) trouxe os quatro sinais dourados (golden signals), a diferença entre sintoma e causa e a pergunta que vale carregar: isso merece acordar alguém às três da manhã? O [capítulo 7](/posts/sre-chapter-07-evolution-of-automation/) mostrou que automação é multiplicador, não panaceia — e que o horizonte é autonomia, não só script.

**Lidos juntos, os capítulos formam um ciclo: definir risco, medir, reduzir trabalho, automatizar, observar e aprender.**

## Engenharia contínua

Talvez os capítulos pareçam assuntos separados. Mas eles se encaixam em um ciclo.

O risco aparece no começo e volta sempre. Sem SLO, “disponibilidade” é opinião. Com SLO, vira orçamento, prioridade e conversa entre produto e operação.

A visibilidade entra no meio. Monitoramento não é enfeite de dashboard, é o sistema nervoso que permite decidir se o problema é sintoma, causa ou ruído.

E o trabalho fecha o ciclo. Reduzir toil e evoluir a automação são dois lados da mesma moeda: um diz por que melhorar, o outro mostra como.

Nenhum capítulo resolve tudo sozinho. **SLO sem monitoramento é intenção; monitoramento sem SLO é ruído; automação sem SLO é velocidade na direção errada.**

## O que eu levo destes sete capítulos

Eu comecei como analista de infraestrutura, cuidando de servidores um por um. Na **Soluti**, a primeira virada foi virtualizar e criar cluster: quase **200 serviços e máquinas virtuais** deixaram de ser caixas isoladas e passaram a ser um parque gerenciável. Depois vieram o **Zabbix**, o **Puppet** e a automação de configuração e release.

Na **2Com Consulting**, a virada foi de escala e processo: scripts Shell viraram roles Ansible, a entrega de monitoramento caiu de dias para **30–40 minutos**, a fila de chamados encolheu **mais de 60%** e o backlog foi zerado. Foi a primeira vez que vi automação mudar o jogo de forma mensurável.

Na **IBM** e na **Kyndryl**, o mesmo padrão apareceu em ambientes críticos de grandes clientes, com monitoramento, automação e plataformas de operação. Mas a série também me obrigou a ser honesto sobre o que eu **não** tinha: nunca defini um SLO formal, nunca documentei um postmortem blameless e nunca cheguei ao nível 5 de autonomia.

Olhando para trás, a mudança não foi de ferramenta para ferramenta. Foi de “manter no ar” para “entender o que ‘no ar’ significa”. De herói de incidente para sistema que aprende.

**O mercado transformou SRE em um cargo. Para mim, é uma disciplina: estudar continuamente, aplicar os princípios e tratar operação como engenharia.**

## Aprendizado contínuo

Nem tudo o que quero praticar cabe no dia a dia do trabalho. Por isso, boa parte do meu estudo virou laboratório: projetos pequenos, feitos para errar sem consequência e entender de verdade como as peças se encaixam.

No [**srectl**](https://github.com/fabianoflorentino/srectl), por exemplo, monto um ambiente local de SRE, DevOps e Platform Engineering em Go, com Kubernetes, Argo CD e a stack LGTM. É onde testo SLIs, SLO e error budget sem fingir que estou em produção.

O [**seraph**](https://github.com/fabianoflorentino/seraph) nasceu da vontade de ter um status board que lê páginas de status oficiais — o lugar natural para publicar disponibilidade. O [**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) transforma um SLI concreto em ferramenta: certificado expirado é serviço indisponível. E o [**fraudctl**](https://github.com/fabianoflorentino/fraudctl) é um campo de teste para latência, erro e disponibilidade em uma API real.

Nenhum deles é um produto pronto. São projetos de estudo, feitos para manter o conhecimento em movimento e me obrigar a aplicar os princípios de SRE em algo concreto.

Ainda tenho muito a aprender — e é isso que mantém o estudo vivo. **A teoria só vira disciplina quando encontra um sistema para praticar.**

## Acompanhe a série

No próximo post, vou falar do **Capítulo 8: Engenharia de release** (_Release Engineering_). É o capítulo que mostra por que “funciona na minha máquina” não é um processo de entrega — e o que separa um deploy de um release confiável.

Acompanhe a série pela página [/series/sre/](/series/sre/).
