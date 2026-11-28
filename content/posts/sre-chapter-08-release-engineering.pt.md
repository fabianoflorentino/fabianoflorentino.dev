---
date: '2026-11-29T00:00:00Z'
draft: false
title: 'Site Reliability Engineering: Engenharia de release no Google'
translationKey: sre_chapter_08_release_engineering
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-08.png
translation:
  url: /en/posts/sre-chapter-08-release-engineering/
  text: English version
---

Este é o oitavo post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). No capítulo anterior, vimos a automação como multiplicador de força. Agora o [capítulo 8](https://sre.google/sre-book/release-engineering/) aplica essa ideia ao ato de colocar software em produção: **engenharia de release** é a disciplina de construir e entregar software de forma repetível — sem "flocos de neve únicos".

## O papel do release engineer

O release engineer precisa entender, de ponta a ponta, o caminho do código até a produção: controle de versão, compiladores, configuração de build, ferramentas de empacotamento e instaladores. Ele não é só "quem sobe o deploy"; é quem define **como** o software sai do repositório e vira binário executável.

No Google, a função é orientada a dados: as ferramentas medem a **velocidade de release** — quanto tempo uma mudança de código leva para chegar à produção — e quais features são usadas nos arquivos de build. Boas práticas (flags de compilador, formato do identificador de build, etapas obrigatórias) existem para que qualquer time lance com método consistente e repetível.

Release engineers trabalham junto com SREs para definir **canário, rollout sem interrupção e rollback**. O objetivo é que ninguém precise "reinventar a roda" — e mal — na hora de lançar.

**Release confiável começa com processo confiável: do código-fonte ao deploy.**

## A filosofia: quatro princípios

O capítulo resume a engenharia de release do Google em quatro princípios:

- **Self-service**: os times precisam ser autossuficientes. Com milhares de engenheiros e produtos, a alta velocidade só acontece porque cada time decide quando e como lançar — com um processo automatizado a ponto de exigir pouquíssima intervenção humana.
- **Alta velocidade**: releases frequentes significam menos mudanças entre versões, o que torna testar e depurar mais fáceis. Alguns times fazem build de hora em hora; outros adotam o **"push on green"**, lançando todo build que passa nos testes.
- **Builds herméticos**: duas pessoas compilando a mesma revisão em máquinas diferentes devem obter o mesmo resultado. O build não depende de bibliotecas instaladas na máquina nem de serviços externos; dependências e compiladores têm versão conhecida e versionada.
- **Enforcement de políticas**: camadas de segurança e controle de acesso definem quem pode aprovar mudanças, criar release, aprovar cherry pick ou alterar a configuração de build. Quase toda mudança passa por code review, e o sistema gera um relatório com tudo que entrou no release.

O conceito de **build hermético** é o coração disso: se você não consegue reconstruir exatamente o binário que está rodando, consertar um bug de produção vira loteria. O Google resolve isso reconstruindo na mesma revisão e aplicando mudanças pontuais por **cherry pick**.

**O release não é uma ação; é um artefato reproduzível e auditável.**

## O pipeline: Blaze, Rapid e MPM

O sistema de release do Google se chama **Rapid**. Ele junta várias tecnologias internas para entregar releases escaláveis, herméticos e confiáveis.

- **[Blaze](https://sre.google/sre-book/release-engineering/#building-lqsAI1uM)** é a ferramenta de build (open source como **Bazel**). Suporta C++, Java, Python, Go e JavaScript, definindo alvos e dependências. Cada binário carrega data de build, revisão e identificador — dá para rastrear exatamente como ele foi produzido.
- **Branching**: quase nada é lançado direto da mainline. O release sai de um branch em uma revisão específica; correções vão para a mainline e são trazidas por **cherry pick**, para não arrastar mudanças não relacionadas.
- **[Midas Package Manager (MPM)](https://sre.google/sre-book/release-engineering/#packaging-8ksQTeum)**: empacota e distribui o software, com nome, hash de versão e assinatura. Rótulos como `dev`, `canary` e `production` indicam onde o pacote está no processo.
- **[Rapid](https://sre.google/sre-book/release-engineering/#rapid-m8sJcDux)**: configurado por *blueprints* que definem build, teste, regras de deploy e donos do projeto. Os workflows rodam em jobs **Borg** ([descrição no livro](https://sre.google/sre-book/production-environment/#managing-machines-XQsKIBTq)) e disparam milhares de releases em paralelo.
- **[Sisyphus](https://sre.google/sre-book/release-engineering/#deployment-dbsMi8um)**: framework de rollout criado por SRE. Controla a implantação em etapas — atualizar tudo de uma vez ou escalar de um cluster para todos ao longo de horas.

O deploy é desenhado para o **perfil de risco** do serviço: em desenvolvimento, build de hora em hora com push automático; em serviços grandes, expansão progressiva; em infraestrutura sensível, rollout ao longo de dias.

**A velocidade do deploy não é uniforme — ela se ajusta ao risco de cada serviço.**

## Gestão de configuração

Mudança de configuração é uma fonte clássica de instabilidade. O capítulo mostra quatro modelos de distribuir configuração, sempre versionada e sob code review:

1. **Mainline**: configuração no head da mainline; simples, mas cria *skew* entre o que está versionado e o que está rodando.
2. **No mesmo pacote**: binário e configuração juntos; simplifica o deploy, mas acopla os dois.
3. **Pacotes separados**: aplica o princípio hermético à configuração. Dá para trocar só uma flag sem reconstruir o binário.
4. **Store externo**: configurações que mudam com frequência ficam em **Chubby** ([lock service](https://sre.google/sre-book/production-environment/#lock-service-jWsjIlcM)) ou **Bigtable** ([storage](https://sre.google/sre-book/production-environment/#storage-jWsvt4TM)).

O ponto é que configuração é código de primeira classe, com versionamento, review e rollout próprios.

**Configuração mal gerenciada derruba tanto sistema quanto código ruim.**

## Não é só para o Google

O capítulo fecha com um lembrete: com as ferramentas certas, automação e políticas bem definidas, lançar software deveria ser **tão simples quanto apertar um botão**. Empresas de qualquer tamanho encaram as mesmas perguntas: como versionar pacotes? Build contínuo ou periódico? Com que frequência lançar? Que política de configuração usar?

E, mais importante, a engenharia de release precisa ser pensada **desde o começo** — não como algo que se encaixa depois. É mais barato colocar processo e boas práticas cedo do que corrigir um sistema legado mais tarde.

**Release engineering é investimento de fundação, não remendo de fim de projeto.**

## O que eu levo deste capítulo

Quando leio sobre engenharia de release, volto direto ao módulo **Puppet** que escrevi na **Soluti**. O sistema de emissão de certificados digitais era escrito em **PHP** e rodava no **Apache**. As versões ficavam versionadas no **Git** (GitLab), e eu desenvolvi um módulo Puppet que buscava os arquivos da aplicação pelo número da versão, comparava as diferenças com o que estava no servidor e substituía só o que mudou.

O módulo também codificava os passos de cada atualização: reiniciar o serviço, aplicar ajustes de configuração. Ou seja, o *o quê* (versão a distribuir) e o *como* (o que fazer depois de distribuir) viraram código — e qualquer servidor passou a ser provisionado do mesmo jeito.

Mas, sendo honesto, isso era uma fração do que o capítulo descreve. Eu tinha **reproducibilidade na prática** (a mesma versão do Git gerava o mesmo ambiente), mas sem o rigor hermético do Google, sem canário em etapas e sem o controle de políticas que o Rapid e o MPM oferecem. O rollout era "aplica e reza", não um rollout com Sisyphus ajustado ao perfil de risco.

O que ficou foi a semente da ideia certa: **release é um processo de engenharia, e não um passo manual**. A entrega saiu de dias para minutos porque o caminho do código à produção deixou de depender de uma pessoa seguindo um roteiro mental.

**Aprendi o essencial na prática: sem processo, "funciona na minha máquina" vira o plano de deploy.**

## Próximos capítulos

No próximo post, vou falar do **Capítulo 9: Simplicidade** (_Simplicity_). É o capítulo que defende o "chato e previsível" contra a complexidade desnecessária — e mostra por que, em operação, menos é quase sempre mais.

Acompanhe a série pela página [/series/sre/](/series/sre/).
