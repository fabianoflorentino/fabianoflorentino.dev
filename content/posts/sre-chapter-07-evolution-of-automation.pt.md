---
date: '2026-11-25T00:00:00Z'
draft: true
title: 'Site Reliability Engineering: A evolução da automação no Google'
translationKey: sre_chapter_07_evolution_of_automation
tags: [post, sre, google-sre]
series: SRE
image: /images/sre-07.png
translation:
  url: /en/posts/sre-chapter-07-evolution-of-automation/
  text: English version
---

Este é o sétimo post da série sobre o livro [_Site Reliability Engineering: How Google Runs Production Systems_](https://sre.google/sre-book/table-of-contents/). Depois de falar de toil e de monitoramento, o livro olha para a ferramenta que promete resolver os dois: automação. O [capítulo 7](https://sre.google/sre-book/automation-at-google/) começa com uma correção importante: **automação é multiplicador de força, não panaceia**.

## Automação é multiplicador, não panaceia

O capítulo não vende automação como sinônimo de maturidade. Ele mostra o valor real:

- **Consistência**: humanos fazem a mesma tarefa de formas ligeiramente diferentes; máquinas não.
- **Plataforma**: uma correção no código vale para todos; um erro também fica centralizado e visível.
- **Reparo mais rápido**: automação de falhas comuns reduz o MTTR e libera tempo.
- **Ação mais rápida**: failover e troca de tráfego não deveriam esperar alguém apertar um botão.
- **Economia de tempo**: o ganho não é só de quem escreveu a automação; é de todo mundo que passa a executar a tarefa sem precisar entendê-la por dentro.

O último ponto é o mais subestimado. Automatizar **desacopla o operador da operação**. Uma tarefa que exigia uma pessoa com acesso e contexto passa a ser executável por qualquer pessoa autorizada — ou por nenhuma, se o sistema souber se cuidar sozinho.

Mas o capítulo também é honesto: automatizar sem entender só multiplica o erro na mesma direção. E a melhor solução nem sempre é automatizar o manual; às vezes é **redesenhar o sistema para não precisar daquela tarefa**.

**Automação sem entendimento é só um jeito mais rápido de errar em escala.**

## A escada da automação

O capítulo organiza a evolução em cinco níveis:

1. **Sem automação**: o failover do banco é feito à mão.
2. **Automação específica, mantida externamente**: alguém tem um script de failover na home.
3. **Automação genérica, mantida externamente**: o time adiciona suporte ao banco em um script genérico.
4. **Automação específica, mantida internamente**: o próprio banco traz seu script de failover.
5. **Sistemas que não precisam de automação**: o banco detecta o problema e faz failover sozinho.

A maioria das empresas para no nível 2 ou 3. O nível 4 já exige que o time que opera seja dono da automação. O nível 5 é o sistema autônomo: ele se monitora, se corrige e só chama humano quando realmente precisa.

O capítulo chama isso de **autonomia**, não de automação. A diferença não é semântica: automação executa uma receita; autonomia toma decisões dentro de limites seguros. E, como o próprio texto lembra, autonomia é difícil de adaptar depois em sistemas grandes. É mais fácil projetar desde o começo.

**O objetivo não é automatizar o manual; é desenhar o sistema para não precisar de cola externa.**

## Automação é software

Ferramentas como Puppet, Chef, cfengine e até Perl oferecem níveis diferentes de abstração. Quanto mais alta a abstração, mais fácil raciocinar — e mais grave quando ela vaza. O exemplo do capítulo é simples: subir um binário parece atômico, mas a rede pode cair no meio, a máquina pode falhar, o cluster pode ficar com metade da versão antiga e metade da nova.

Automação também **envelhece**. Scripts criados para um cenário viram dívida quando o sistema muda e ninguém atualiza o script. O capítulo mostra o **Prodtest**, que usava testes de produção para detectar configurações inconsistentes. A evolução natural foi combinar cada teste com uma correção **idempotente**: rodar de novo não piora o estado, e o processo pode ser repetido com segurança.

Só que essa abordagem também tinha armadilhas: testes instáveis, correções que não eram idempotentes de verdade e a tentação de centralizar tudo em um time de “turnup”. Quando a automação sai das mãos de quem opera o serviço, os incentivos ficam errados: o time de turnup quer velocidade agora, mas não sofre a dívida técnica depois. A lição foi mover a automação para quem é dono do serviço, com APIs, permissões e auditoria.

**Automação que não é tratada como software vira dívida técnica com cron.**

## Quando a automação vira risco

O capítulo tem um exemplo que deveria assombrar qualquer pessoa que já escreveu um script de limpeza. Uma automação de descomissionamento de racks apagava os discos das máquinas. Depois de uma falha, o processo foi reiniciado; a etapa de apagar discos recebeu um conjunto vazio de máquinas. Só que, naquela implementação, o conjunto vazio era interpretado como “tudo”. Resultado: a automação começou a apagar discos de praticamente toda a CDN do Google.

O sistema sobreviveu porque havia capacidade planejada e réplicas, mas o episódio mostra o padrão: **automação pode habilitar falhas em escala**. A correção veio com verificações de sanidade, limites de taxa e idempotência.

Tem outro custo menos óbvio: atrofia humana. Quanto mais a automação cobre, menos as pessoas praticam a operação manual. Quando ela falha, ninguém lembra como agir. Por isso o capítulo defende introspecção, visibilidade e drills regulares. Automação boa não esconde o sistema; ela deixa o sistema mais fácil de entender quando algo dá errado.

**Confiabilidade é a característica fundamental — e automação só ajuda se não tirar o freio.**

## O que eu levo deste capítulo

Na **Soluti**, a administração começou com **ShellScript e CronJobs**. Funcionava para um ambiente pequeno, mas não para um parque que saiu de pouco mais de **20 servidores para 100 e depois 150**. O processo de entrega seguia requisitos de conformidade do órgão regulador e era manual; cada ambiente levava dias.

Com **Puppet**, o processo virou código. Desenvolvi módulos versionados no GitLab para configuração, conformidade e release de uma aplicação PHP/Apache, incluindo verificação de diferenças, configuração do servidor e restart de serviços. O tempo de entrega caiu de dias para minutos. Mas, olhando pela escada do capítulo, isso era **nível 4 em partes**: automação específica, mantida internamente, ainda dependente de humano para decidir quando rodar.

Na **2Com Consulting**, o caminho foi parecido — e diferente. Comecei com scripts Shell para entregar monitoramento. Testei **Puppet**, mas o modelo servidor-agente, a infraestrutura dedicada e a dependência de conexão estável pesaram contra. A escolha foi **Ansible**: sem agente, declarativo, SSH/WinRM. Com roles e playbooks versionados no GitLab, a entrega caiu de dias para **30–40 minutos**, a fila de chamados encolheu **mais de 60%** e o backlog de entrega foi zerado, atendendo uma base de aproximadamente **700 clientes**.

O que eu não tinha era o nível 5. Nem perto. Eu automatizava tarefas; não construía sistemas que se corrigiam sozinhos. E, no começo, também não tratava a automação como software: versão, README, idempotência e teste vieram pela dor, não por método.

Hoje, trabalhando em uma plataforma de automação em Go, vejo o mesmo padrão em outra escala: o difícil não é executar a tarefa. É manter contrato, versão, observabilidade e segurança para que uma mudança não quebre tudo.

**Meu próximo nível não é escrever mais playbooks; é desenhar sistemas que precisem de menos cola.**

## Próximos capítulos

No próximo post, vou falar do **Capítulo 8: Engenharia de release** (_Release Engineering_). É o capítulo que mostra por que “funciona na minha máquina” não é um processo de entrega — e o que separa um deploy de um release confiável.

Acompanhe a série pela página [/series/sre/](/series/sre/).
