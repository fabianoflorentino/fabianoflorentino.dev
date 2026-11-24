---
date: '2026-11-24T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Monitoramento de sistemas distribuídos'
translationKey: sre_chapter_06_monitoring_distributed_systems
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-06.png
translation:
  url: /en/posts/sre-chapter-06-monitoring-distributed-systems/
  text: English version
---

Este é o sexto post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de falar de toil, o livro entra no capítulo que transforma sinal em decisão. O [capítulo 6](https://sre.google/sre-book/monitoring-distributed-systems/) começa com uma pergunta simples e desconfortável: **o que merece acordar uma pessoa às três da manhã?**

## Monitorar não é olhar gráfico

O capítulo começa separando vocabulário que muita gente usa como sinônimo:

- **Monitoramento**: coletar, processar, agregar e exibir dados quantitativos em tempo real sobre o sistema.
- **White-box**: métricas expostas pelo interior do sistema — logs, endpoints, estatísticas internas.
- **Black-box**: teste do comportamento externo, como um usuário veria.
- **Dashboard**: uma visão resumida dos sinais mais importantes do serviço.
- **Alerta**: uma notificação para um humano, que pode virar ticket, email ou **page**.

Essa última distinção importa. **Page** é o alerta que interrompe alguém de verdade. Email e ticket podem esperar; page não. E page é caro: interrompe o trabalho, o descanso e o sono. Quando ele vira rotina, as pessoas começam a ignorar, ler por cima ou silenciar — inclusive o page que importava.

O capítulo também lembra por que monitoramos: enxergar tendências de longo prazo, comparar períodos ou experimentos, alertar, montar dashboards e investigar incidentes depois que acontecem. Monitorar é trabalho de engenharia: uma equipe de 10–12 SREs costuma ter uma ou duas pessoas dedicadas a isso — e ninguém deve ficar “olhando tela” esperando problema.

**Dashboard não é monitoramento; é uma janela para ele. Se ninguém olha e nada dispara, o sistema está sozinho.**

## Os quatro sinais dourados

Se você só puder medir quatro coisas de um sistema voltado ao usuário, meça estas: **latência, tráfego, erros e saturação**.

- **Latência**: o tempo para atender uma requisição. Separe a latência do sucesso da latência do erro. Um erro rápido não é bom, mas um erro lento é ainda pior.
- **Tráfego**: quanto de demanda o sistema está recebendo. Pode ser requisições por segundo, sessões concorrentes, I/O ou transações.
- **Erros**: a taxa de requisições que falham — de forma explícita, implícita ou por política. Um HTTP 200 com conteúdo errado também é erro.
- **Saturação**: quão cheio o serviço está. Olhe para o recurso mais restrito e lembre que muitos sistemas degradam antes de chegar a 100%.

O capítulo também lembra que latência costuma ser o primeiro aviso de saturação. E que saturação não é só o presente: “o disco enche em quatro horas” é um sinal tão útil quanto “o disco está cheio”.

**Quatro sinais bem medidos cobrem melhor o serviço do que duzentos gráficos sem dono.**

## A média mente; olhe a cauda

A média é confortável e quase sempre enganosa. Um serviço com latência média de 100 ms pode ter 1% das requisições levando 5 segundos. Se o usuário depende de vários serviços para montar uma página, o 99º percentil de um backend vira facilmente a mediana da experiência final.

Por isso o capítulo recomenda histogramas com faixas de latência, não só a média. Em vez de perguntar “qual foi a latência média?”, pergunte “quantas requisições caíram em cada faixa?”. Faixas aproximadamente exponenciais — 0–10 ms, 10–30 ms, 30–100 ms, 100–300 ms — mostram a distribuição sem esconder a cauda.

A resolução da medição também importa. CPU medida a cada minuto pode não revelar picos curtos que destroem a latência. Já um probe de disponibilidade a cada segundo é exagero para um serviço que aceita 99,9% de disponibilidade. Coletar, armazenar e analisar tem custo; às vezes vale amostrar no servidor e agregar depois.

**Se você só olha a média, está monitorando um usuário que não existe.**

## Página é caro; alerta é contrato

O capítulo faz uma distinção que deveria estar em todo runbook: **sintoma** é o que está quebrado; **causa** é o porquê. O monitoramento precisa responder às duas perguntas, mas com papéis diferentes.

Para **page**, priorize **black-box**: o problema já está acontecendo e afetando o usuário. White-box é excelente para detectar problemas iminentes, falhas mascaradas por retries e para debugging. Mas white-box também gera ruído: CPU alta nem sempre significa usuário sofrendo.

Antes de criar um alerta, o capítulo sugere perguntar:

- Ele detecta uma condição urgente, acionável e visível para o usuário?
- Vou poder ignorá-lo sabendo que é benigno? Se sim, por que ele existe?
- Ele indica impacto real, ou só um recurso ocupado?
- Existe ação possível? A ação pode ser automatizada?
- Outra pessoa já foi acionada pelo mesmo problema?

A filosofia é dura: **todo page deve ser urgente, acionável, exigir inteligência e tratar de um problema novo**. Se a resposta é sempre a mesma, aquilo não é page — é automação faltando. Email alerts, nesse contexto, têm valor limitado e viram ruído rápido; melhor colocá-los em um dashboard de problemas subcríticos.

**Se a página não exige pensamento, ela deveria ser automação; se não exige ação, não deveria ser página.**

## Simples o suficiente

Monitoramento é fácil de complicar. O capítulo alerta para o risco de regras demais, dependências demais e dashboards demais. Hierarquias complexas de dependência (“se o banco está lento, não alerte o site”) envelhecem mal em sistemas que mudam o tempo todo.

A recomendação é manter o caminho crítico simples e compreensível:

- As regras que mais pegam incidentes reais devem ser as mais simples e previsíveis.
- Coleta, agregação e alerta que quase nunca são usados são candidatos à remoção.
- Métricas coletadas que não aparecem em dashboard nem disparam alerta também.
- Monitoramento não deve virar uma mistura de profiling, debug de processo, logs, tracing e load test. Integre por APIs claras, não por um monstro único.

O caso do [**Bigtable**](https://sre.google/sre-book/monitoring-distributed-systems/#bigtable-sre-a-tale-of-over-alerting-dbsXtjSM) — o banco de dados distribuído do Google — mostra o custo do excesso. A equipe recebia alertas em volume, gastava tempo triando ruído e às vezes perdia o problema que realmente afetava usuários. A solução foi temporariamente baixar o alvo de SLO, desligar os alertas por email e usar o fôlego para corrigir a causa raiz. Já o caso do [**Gmail**](https://sre.google/sre-book/monitoring-distributed-systems/#gmail-predictable-scriptable-responses-from-humans-BVs1h4SD) — o serviço de email do Google — mostra o outro lado: páginas com resposta robótica são um alerta de dívida técnica. Se a equipe não automatiza nem corrige, o page está apenas escondendo o problema.

**Monitoramento bom é chato: simples, previsível e com pouco ruído.**

## O que eu levo deste capítulo

Na Soluti, o monitoramento era feito direto na console de virtualização. Ele mostrava o básico, mas não dava uma visão ampla do que estava acontecendo. Com o crescimento do ambiente, implementei **Zabbix** com um módulo **Puppet**, acompanhando CPU, memória e disco. Isso melhorou a visão sobre os recursos, ajudou no planejamento de capacidade e deu mais agilidade para agir antes de uma falha maior — em um ambiente que chegou a quase **200 serviços e servidores virtualizados**.

Em um cliente de grande porte, participei da construção de um dashboard de **Zabbix + Grafana** em containers, cobrindo ambientes **AIX, Linux e Windows**, IIS, bancos Oracle, SQL Server e DB2 e vencimento de certificados digitais. A ideia era ter uma visão “ao vivo” do ambiente e agir antes de o problema virar alerta ou ticket. Funcionou: houve caso de identificar um problema em Oracle antes de a fila de atendimento ser acionada.

Mas, olhando com o critério do capítulo, eu tinha **white-box de sobra e pouco black-box**. Sabia dizer como estava a CPU, a memória e o disco; não sabia dizer, com a mesma clareza, como estava a experiência do usuário. Meu monitoramento era de infraestrutura, não de serviço no sentido que o livro usa.

Os quatro sinais dourados me dão a ordem que faltava: começar pelo sintoma — latência, tráfego, erros e saturação — e só então descer para a causa. E lembrar que alerta não é email: se ninguém precisa acordar, não é page.

**Meu monitoramento olhava para a máquina; o capítulo me ensina a olhar para o serviço.**

## Próximos capítulos

No próximo post, vou falar do **Capítulo 7: A evolução da automação no Google** (_The Evolution of Automation at Google_). É o capítulo que mostra como a automação amadurece — e por que a ferramenta certa depende do problema, do time e do contexto.

Acompanhe a série pela página [/series/sre/](/series/sre/).
