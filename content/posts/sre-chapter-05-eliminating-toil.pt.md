---
date: '2026-11-23T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Eliminando o toil'
translationKey: sre_chapter_05_eliminating_toil
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-05.png
translation:
  url: /en/posts/sre-chapter-05-eliminating-toil/
  text: English version
---

Este é o quinto post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de falar de SLOs, o livro olha para o trabalho que consome o tempo do SRE. O [capítulo 5](https://sre.google/sre-book/eliminating-toil/) abre com uma frase de Carla Geisser que vale o post inteiro: **"Se um operador humano precisa tocar seu sistema durante a operação normal, você tem um bug. A definição de normal muda conforme o sistema cresce."**

## O que é toil — e o que não é

*Toil* não é simplesmente "trabalho de que eu não gosto". Gosto pessoal não define o conceito: algumas pessoas até gostam de tarefas manuais e repetitivas. Também não é qualquer tarefa administrativa. O livro separa três coisas:

- **Overhead**: trabalho administrativo que não está diretamente ligado a rodar um serviço — reuniões, metas, formulários de RH, snippets semanais.
- **Trabalho sujo com valor duradouro**: limpar uma configuração de alertas cheia de lixo pode ser chato, mas deixa o serviço melhor. Não é toil.
- **Toil**: trabalho ligado à operação de um serviço que tende a ser **manual, repetitivo, automatizável, tático, sem valor duradouro e que cresce linearmente com o serviço**.

Não é preciso marcar todos os critérios para ser toil. Quanto mais a tarefa se parece com essa lista, mais provável que seja. Um detalhe importante: rodar um script manualmente também é toil — o tempo humano gasto ali conta, mesmo que o script faça o trabalho pesado. E se a tarefa exige julgamento humano, cuidado: talvez o problema seja um sistema mal desenhado que insiste em pedir julgamento humano várias vezes por dia.

**Toil não é o trabalho chato; é o trabalho que não deixa o sistema melhor depois que você termina.**

## Por que menos toil é melhor

A meta pública do SRE do Google é manter o toil **abaixo de 50% do tempo de cada SRE**. A outra metade, no mínimo, deve ir para trabalho de engenharia que reduza toil futuro ou adicione funcionalidade ao serviço.

O motivo é simples: **toil se expande se ninguém coloca limite**. Sem uma meta explícita, ele ocupa 100% do tempo e a organização vira operação. O trabalho de reduzir toil e escalar serviços é justamente o "Engineering" de *Site Reliability Engineering*.

O capítulo faz a conta do piso de toil de quem está de plantão. Em uma rotação de 6 pessoas, com uma semana de on-call primário e uma de secundário, pelo menos 2 de cada 6 semanas vão para plantão e interrupções: **33% do tempo**. Em uma rotação de 8 pessoas, o piso cai para **25%**. Nas pesquisas trimestrais do Google, a média fica em torno de **33%** — abaixo da meta de 50%, mas com outliers: alguns SREs reportam 0% e outros, 80%. Quando alguém concentra toil demais, é sinal de que a carga precisa ser redistribuída.

**Toil não se combate com boa vontade; se combate com limite, medição e engenharia.**

## O que conta como engenharia

O capítulo também delimita o outro lado: **trabalho de engenharia é novo, exige julgamento humano, produz melhoria permanente e é guiado por estratégia**. Quanto mais generalizável a solução, melhor — ela ajuda o time a operar mais serviços com o mesmo número de pessoas.

As atividades de um SRE caem, aproximadamente, em quatro caixas:

- **Engenharia de software**: escrever ou modificar código, criar ferramentas e frameworks, adicionar recursos de escalabilidade e confiabilidade, melhorar infraestrutura como código.
- **Engenharia de sistemas**: configurar sistemas de produção, ajustar parâmetros, documentar de forma que um esforço único gere melhoria duradoura; inclui monitoramento, balanceamento, configuração de servidores e consultoria de arquitetura.
- **Toil**: trabalho repetitivo e manual diretamente ligado à operação do serviço.
- **Overhead**: trabalho administrativo que não está diretamente ligado ao serviço.

A meta de 50% é uma média ao longo de alguns trimestres ou de um ano, não uma cota diária. Toil é irregular: há semanas que concentram mais incêndio, e uma equipe pode ficar temporariamente abaixo do piso de 50% de engenharia. O problema é quando o **tempo de engenharia** fica persistentemente abaixo de 50% — ou seja, o toil passa de 50% —; aí é hora de parar e entender o que está errado.

**Se todo o seu tempo é apagar incêndio, você não está escalando o serviço; está apenas pagando a conta dele.**

## Toil nem sempre é vilão

O livro é honesto: **toil em pequenas doses não é necessariamente ruim**. Tarefas previsíveis e repetitivas podem ser calmas, dar sensação de conclusão rápida e ter baixo risco. Todo mundo precisa de um pouco disso de vez em quando.

O problema aparece na quantidade. Toil demais causa **estagnação de carreira** e **baixa moral** — burnout, tédio, insatisfação. E o efeito não é só individual:

- **Cria confusão**: se times de SRE fazem toil demais, fica menos claro que SRE é uma organização de engenharia.
- **Desacelera o progresso**: tempo gasto em trabalho manual é tempo que não vai para entregar features.
- **Cria precedente**: quem aceita toil sem reclamar atrai ainda mais toil — inclusive tarefas que deveriam ser do time de desenvolvimento.
- **Aumenta a rotatividade**: os melhores engenheiros procuram trabalho mais recompensador.
- **Quebra a promessa**: quem entra em SRE esperando projeto se sente enganado.

**Toil aceitável é dose; toil crônico é cultura — e cultura se corrige com engenharia e limite.**

## O que fazer com o toil

O capítulo não vende uma bala de prata. O caminho é **medir, classificar e atacar**:

1. **Medir** quanto tempo vai para toil, separando de overhead e de engenharia.
2. **Classificar** o que é manual, repetitivo, automatizável, tático, sem valor duradouro e linear com o crescimento.
3. **Eliminar, automatizar ou redesenhar** — às vezes a melhor automação é remover a necessidade da tarefa.

A frase de Carla Geisser volta aqui: se um humano precisa tocar o sistema na operação normal, isso é um bug. O "normal" de hoje não será o "normal" de amanhã, porque o sistema cresce. A disciplina é **eliminar um pouco de toil por semana** com engenharia de verdade, em vez de esperar o grande projeto de automação que nunca começa.

**Automação não é o fim; é o meio de devolver tempo humano para o que não escala sozinho.**

## O que eu levo deste capítulo

Por muito tempo, eu chamei toil de "rotina".

Em uma autoridade certificadora, a implementação de servidores seguia requisitos de conformidade do órgão regulador e era feita à mão. Levava **dias** para entregar cada ambiente. Quando a infraestrutura passou de pouco mais de **20 servidores para 100 e depois para 150**, ficou óbvio que a rotina não ia escalar. Com **Puppet**, o processo virou código e o tempo de entrega caiu de dias para **minutos** — incluindo a conformidade e a segurança que antes dependiam de checklist manual.

Em uma consultoria de banco de dados, o problema era a entrega de monitoramento: configuração manual, sem processo e sem documentação, levando **dias** para chegar ao cliente. Com **OMD + Ansible**, o tempo caiu para **30–40 minutos** (dependendo da internet do cliente), a fila de chamados encolheu **mais de 60%** e a fila de entrega foi **zerada**, atendendo uma base de aproximadamente **700 clientes**. O Puppet foi testado antes, mas pesou contra ele o modelo servidor-agente e a curva de aprendizado; o Ansible venceu por ser sem agente, declarativo e usar SSH/WinRM.

O que eu não fazia — e o capítulo deixa claro — era **medir o toil**. Não tinha percentual, não tinha orçamento de 50%, não separava toil de overhead. A automação veio pela pressão do crescimento e da fila, não por um diagnóstico formal. **Eu resolvia o sintoma; o capítulo me dá o critério.**

Hoje eu olharia diferente: mediria o que se repete, quanto tempo consome e o que cresce junto com o serviço. Porque toil não é só "trabalho manual": é o trabalho que **escala junto com o serviço** e devolve o time ao mesmo lugar. Automatizar o que se repete é o que transforma operação em engenharia.

## Próximos capítulos

No próximo post, vou falar do **Capítulo 6: Monitoramento de sistemas distribuídos** (_Monitoring Distributed Systems_). É o capítulo que conecta os sinais que medimos com a pergunta que importa: o que merece acordar uma pessoa às três da manhã?

Acompanhe a série pela página [/series/sre/](/series/sre/).
