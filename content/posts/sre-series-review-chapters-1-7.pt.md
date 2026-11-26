---
date: '2026-11-26T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: O que vimos até aqui'
translationKey: sre_series_review_chapters_1_7
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-review.png
translation:
  url: /en/posts/sre-series-review-chapters-1-7/
  text: English version
---

Depois de sete capítulos, vale olhar para trás antes de seguir. Este post é uma pausa entre o capítulo 7 e o capítulo 8: uma oportunidade de revisitar o caminho, conectar os conceitos e entender o que mudou na minha percepção sobre Site Reliability Engineering.

O livro do Google [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/) foi a base desta série. Ao longo dos capítulos, percorremos os fundamentos apresentados nele: começamos entendendo por que o SRE surgiu, passamos pela arquitetura dos ambientes de produção e chegamos a temas como gerenciamento de risco, objetivos de nível de serviço, toil, monitoramento e automação.

Mais do que conhecer ferramentas ou memorizar conceitos, a leitura me fez olhar para algumas experiências profissionais de outra maneira. Práticas que eu já adotava ganharam uma fundamentação mais clara, enquanto outras revelaram lacunas que ainda preciso desenvolver.

Antes de entrar em Engenharia de Release (_Release Engineering_), vale entender como essas peças se encaixam.

## O que vimos até aqui

O [capítulo 1: Introdução](/posts/sre-chapter-01-introduction/) apresentou a ideia que sustenta toda a série: o que muda quando a operação passa a ser tratada como engenharia?

O Google propôs uma mudança de abordagem. Em vez de escalar a operação simplesmente adicionando pessoas, passou a aplicar engenharia de software aos problemas operacionais. A redução do trabalho operacional repetitivo, o chamado _toil_, e a dedicação de pelo menos 50% do tempo à engenharia são consequências dessa filosofia.

O [capítulo 2: O ambiente de produção](/posts/sre-chapter-02-production-environment/) mostrou onde essa filosofia acontece. Borg, Colossus, Bigtable, Spanner, Jupiter, Chubby e Borgmon não são apenas tecnologias isoladas. São componentes de uma arquitetura construída para operar em grande escala, considerando que falhas de hardware, software e rede fazem parte da realidade.

A principal lição foi entender que confiabilidade não depende de máquinas que nunca falham, mas de uma arquitetura capaz de assumir falhas e continuar funcionando.

Os [capítulos 3 e 4](/posts/sre-chapter-03-embracing-risk/) aprofundaram a relação entre confiabilidade e risco.

No capítulo 3, _Embracing Risk_, o livro questiona uma ideia bastante comum: 100% de disponibilidade nem sempre é o melhor objetivo. Confiabilidade tem custo, e cada novo nível de disponibilidade exige investimentos que podem comprometer a velocidade de desenvolvimento e a entrega de funcionalidades.

O _error budget_ aparece como uma maneira objetiva de equilibrar essas necessidades, permitindo que produto e operação tomem decisões a partir de um mesmo indicador.

No capítulo 4, [Service Level Objectives](/posts/sre-chapter-04-service-level-objectives/), esse raciocínio ganha uma estrutura mais clara. SLI, SLO e SLA deixam de ser siglas usadas indistintamente e passam a representar coisas diferentes: o que medimos, qual objetivo queremos atingir e qual compromisso assumimos com o usuário.

Outro ponto importante foi entender que medir tudo não significa medir bem. Os indicadores precisam representar a experiência do usuário, e os objetivos devem ser simples, relevantes e possíveis de acompanhar.

Os [capítulos 5 e 6](/posts/sre-chapter-05-eliminating-toil/) trouxeram a discussão para o trabalho cotidiano de quem opera sistemas.

Em _Eliminating Toil_, o capítulo 5, aprendemos que toil não é simplesmente trabalho repetitivo ou desagradável. É o trabalho operacional que tende a ser manual, repetitivo, automatizável, tático, sem valor duradouro e que cresce junto com o serviço.

O capítulo 6, [Monitoring Distributed Systems](/posts/sre-chapter-06-monitoring-distributed-systems/), mostrou como transformar dados em decisões. Os quatro sinais dourados — latência, tráfego, erros e saturação — ajudam a entender o comportamento dos serviços, enquanto a distinção entre white-box e black-box mostra por que observar a infraestrutura não é necessariamente o mesmo que observar a experiência do usuário.

Também ficou uma pergunta que vale carregar para qualquer ambiente de produção: isso realmente merece acordar alguém às três da manhã?

Por fim, o [capítulo 7: A evolução da automação no Google](/posts/sre-chapter-07-evolution-of-automation/) mostrou que automatizar não significa necessariamente alcançar maturidade operacional.

O capítulo apresenta uma evolução que vai da execução manual até sistemas capazes de identificar problemas e se recuperar sem intervenção humana. A diferença entre automação e autonomia é importante: automatizar uma tarefa é diferente de construir um sistema que não precisa mais daquela tarefa.

A leitura também trouxe um alerta: automação sem entendimento pode multiplicar erros em escala. Por isso, precisa ser tratada como software, com versionamento, testes, idempotência, observabilidade e mecanismos de segurança.

## O que conecta esses capítulos

Lendo os sete capítulos em sequência, fica mais fácil perceber que o SRE não é um conjunto de práticas independentes. Existe uma relação entre todas elas.

Tudo começa entendendo o ambiente e aceitando que falhas fazem parte de sistemas distribuídos. A partir daí, precisamos definir quanto risco estamos dispostos a assumir e transformar essa decisão em objetivos mensuráveis, por meio de SLIs, SLOs e error budgets.

Com os objetivos definidos, o monitoramento permite acompanhar o comportamento do serviço, identificar problemas e entender se a experiência do usuário está dentro do esperado.

Ao mesmo tempo, precisamos reduzir o trabalho operacional repetitivo. Uma equipe que passa todo o tempo mantendo sistemas funcionando não consegue dedicar o mesmo esforço à melhoria desses sistemas.

É nesse ponto que a automação entra como ferramenta de engenharia. Não apenas para executar tarefas mais rapidamente, mas para reduzir intervenções humanas, padronizar processos e construir sistemas capazes de lidar com falhas de maneira previsível.

Essas práticas se complementam:

- **Confiabilidade** define o que precisamos preservar.
- **SLIs e SLOs** estabelecem como medir e qual objetivo perseguir.
- **Monitoramento** permite entender o comportamento do sistema.
- **Redução de toil** devolve tempo para atividades de engenharia.
- **Automação** reduz intervenções e padroniza operações.
- **Autonomia** representa a evolução de sistemas capazes de operar e se recuperar dentro de limites seguros.

Nenhum desses elementos resolve tudo sozinho.

Um SLO sem monitoramento é apenas uma intenção. Monitoramento sem objetivos claros pode gerar uma quantidade enorme de dados sem ajudar nas decisões. Automação sem entendimento pode acelerar uma falha. E uma equipe sem tempo para engenharia acaba apenas sustentando os problemas existentes.

**SRE conecta essas práticas em torno de um objetivo: construir e operar sistemas confiáveis, sem transformar a operação em um trabalho exclusivamente manual.**

## O que eu levo destes sete capítulos

Quando comecei a ler o livro, minha identificação com SRE veio principalmente das experiências que já tinha com infraestrutura, monitoramento e automação. Muitos dos problemas apresentados não eram novidade para mim. Eu já havia enfrentado situações semelhantes em diferentes ambientes e organizações.

A diferença é que, ao longo dos capítulos, comecei a enxergar essas experiências sob outra perspectiva.

Na **Soluti**, comecei como analista de infraestrutura, cuidando de servidores físicos individualmente. A primeira grande mudança foi virtualizar esse ambiente, que saiu de pouco mais de 20 servidores para aproximadamente 150, chegando posteriormente a quase 200 serviços e máquinas virtuais. Vieram também o Zabbix, o Puppet e a automação de configuração e release.

Naquele momento, meu objetivo era melhorar a administração do ambiente, aproveitar melhor os recursos e reduzir o trabalho manual. Hoje consigo identificar nessas decisões alguns dos fundamentos apresentados pelo livro: padronização, redução de toil e tratamento da infraestrutura como algo que pode ser gerenciado por software.

Na **2Com Consulting**, a evolução veio principalmente pela necessidade de escala. Processos que dependiam de scripts Shell e configurações manuais passaram a ser estruturados em roles e playbooks Ansible. A entrega de monitoramento, que antes levava dias, passou a acontecer em aproximadamente 30–40 minutos. A fila de chamados caiu mais de 60%, e o backlog de entregas foi zerado, atendendo uma base de aproximadamente 700 clientes.

Foi uma experiência importante para entender que automação não representa apenas economia de tempo. Ela muda a capacidade de uma equipe atender demandas, padronizar ambientes e manter a qualidade da entrega conforme a operação cresce.

Na **IBM** e, posteriormente, na **Kyndryl**, passei a trabalhar em ambientes críticos de grandes clientes, com diferentes tecnologias, requisitos operacionais e necessidades de confiabilidade. Monitoramento, automação e plataformas de operação continuaram fazendo parte do meu trabalho, mas a escala e a complexidade trouxeram outros desafios.

Mais recentemente, minha atuação também se aproximou da engenharia de software, trabalhando com Go, APIs e sistemas distribuídos, incluindo plataformas de automação que precisam executar processos em larga escala.

Olhando para essa trajetória, percebo que a mudança não aconteceu de uma ferramenta para outra. Foi uma evolução na maneira de pensar sobre os sistemas: de manter servidores funcionando para entender os serviços, seus comportamentos, suas dependências e o impacto que uma falha pode causar.

Mas a leitura também deixou algumas lacunas bastante claras.

**Eu automatizava processos, mas não media formalmente o toil. Monitorava infraestrutura, mas nem sempre conseguia medir a experiência do usuário. Buscava disponibilidade, mas não trabalhava com SLOs formalmente definidos.**

Essas constatações não diminuem o valor das experiências anteriores. Pelo contrário, ajudam a entender o que eu fazia, por que fazia e como poderia ter feito melhor.

É uma das contribuições mais importantes dessa leitura: não apenas reconhecer aquilo que já praticamos, mas identificar o que ainda precisamos desenvolver.

**O mercado transformou SRE em uma função profissional, mas, para mim, ele representa principalmente uma disciplina de engenharia: estudar continuamente, aplicar os princípios e assumir a responsabilidade pela confiabilidade dos sistemas.**

## Aprendizado contínuo

Nem tudo o que quero praticar cabe no dia a dia do trabalho. Por isso, boa parte do meu estudo também acontece em laboratório, por meio de projetos pequenos, desenvolvidos para experimentar, errar sem consequência em produção e entender como os conceitos funcionam na prática.

Alguns projetos open source nasceram justamente dessa necessidade de transformar leitura em experiência.

O [**srectl**](https://github.com/fabianoflorentino/srectl) é um ambiente local de treinamento em SRE, DevOps e Platform Engineering, desenvolvido em Go, com Kubernetes, Argo CD e a stack LGTM. É onde posso experimentar SLIs, SLOs, error budgets e observabilidade em um ambiente controlado.

O [**seraph**](https://github.com/fabianoflorentino/seraph) surgiu da ideia de construir um status board independente, que consulta páginas de status oficiais e apresenta a situação dos serviços. É uma forma de explorar disponibilidade e comunicação do estado operacional.

O [**certificate-validate**](https://github.com/fabianoflorentino/certificate-validate) trabalha com um indicador bastante concreto: a validade de certificados SSL/TLS. Um certificado expirado pode tornar um serviço inacessível, mesmo quando todos os seus componentes parecem estar funcionando normalmente.

Já o [**fraudctl**](https://github.com/fabianoflorentino/fraudctl) é uma API em Go que recebe pagamentos e analisa possíveis fraudes. O projeto participou da Rinha de Backend deste ano, ficando em 19º lugar, e também funciona como um campo de experimentação para latência, taxa de erros e disponibilidade em uma aplicação real.

Cada projeto representa uma oportunidade diferente de colocar em prática conceitos que aparecem ao longo da série.

Nenhum deles é um produto pronto, e essa nunca foi a intenção. São projetos de estudo, experimentação e aprendizado contínuo. O objetivo é construir algo concreto, testar hipóteses e entender os problemas que aparecem quando saímos da teoria.

**A teoria só vira disciplina quando encontra um sistema para praticar.**

## O que vem pela frente

Sete capítulos depois, tenho uma visão mais estruturada sobre SRE, mas também uma lista maior de coisas que quero aprender e experimentar.

Ainda preciso aprofundar a definição e o acompanhamento de SLOs, melhorar a instrumentação dos meus projetos, explorar práticas de resposta a incidentes e entender melhor como construir sistemas com maior autonomia operacional.

E é justamente por isso que a leitura continua fazendo sentido.

No próximo post, vamos entrar no **Capítulo 8: Engenharia de Release** (_Release Engineering_).

Até aqui, falamos sobre confiabilidade, risco, monitoramento e automação. Agora, o livro aborda como organizar o processo de entrega de software para que releases sejam previsíveis, reproduzíveis e confiáveis.

Afinal, fazer o deploy de uma aplicação é apenas uma parte do processo. Garantir que uma nova versão chegue à produção com segurança exige engenharia.

Acompanhe a série pela página [/series/sre/](/series/sre/).
