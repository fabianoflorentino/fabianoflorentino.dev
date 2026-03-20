---
date: '2026-03-19T00:00:00Z'
draft: false
title: 'Você conhece o strace?'
translationKey: stracectl_introducao
tags: [strace, linux, sistema operacional]
image: /images/strace-banner.jpg
---

Na primeira semana de março, a **[LinuxTips](https://linuxtips.io/)**, junto com o **[Jefferson](https://www.linkedin.com/in/jefersonfernando/)**, organizaram um evento online 100% gratuito sobre DevOps e tudo que permeia essa área: a **[Semana DevOps](https://linuxtips.io/semana-devops)**.

O evento contou com palestras de diversos profissionais, e no primeiro dia o Jefferson apresentou sobre o profissional de TI na era Cloud Native.

Já no segundo dia, ele falou sobre como construir infraestrutura com Linux e Terraform. Em certo momento da palestra, ele comentou sobre como os antigos administradores de sistemas (Sysadmins) dominavam diversas ferramentas de troubleshooting — e que, se você não conhecia o `strace`, você não era um “verdadeiro Sysadmin”.

Ele não falou exatamente isso… mas foi assim que eu me senti 😅

Na hora, me peguei pensando no quão pouco eu usei essa ferramenta ao longo da minha carreira. E, como um excelente professor, ele deu uma breve introdução ao `strace`, mostrando o quão poderoso ele pode ser para entender o que está acontecendo com um processo.

Depois da palestra, abri um terminal e rodei o `strace`. E aí entendi o motivo de nunca ter usado tanto.

A saída é extremamente verbosa. É o tipo de ferramenta que exige prática — e um bom entendimento de como o sistema operacional funciona — para realmente extrair valor.

Logo em seguida, lembrei de um papo do **[Fábio Akita](https://akitaonrails.com/)** com o **[Mano Dayvin](https://manodeyvin.com.br/)** sobre criar coisas com AI e o tal do *vibe coding*. Vale conferir o papo, ***[A farsa acabou: Akita, Montano e Deyvin se assumiram vibe coders](https://www.youtube.com/live/G_8uG1Ot0yo?si=naIXW1A7mjNL41Ud)***

E aí veio a ideia:

Se a bolha dev só fala de **AI**, por que não usar essa mesma abordagem para aprender melhor o `strace` — e, de quebra, explorar e aprender o processo de como é construir uma ferramenta do zero?

---

## stracectl?

Por que ***stracectl***?

Seguindo o padrão de várias ferramentas escritas em Go que usam `ctl` no nome (`kubectl`, `etcdctl`, `consulctl`, etc), o `stracectl` é uma tentativa de tornar o uso do `strace` mais acessível.

O `strace` é poderoso — mas a experiência de uso não ajuda. Você recebe um volume enorme de informações, sem muita estrutura, e precisa fazer um certo esforço e conhecer o sistema operacional e também o processo monitorado para transformar a saída em entendimento.

A proposta do `stracectl` é simples:

> transformar um fluxo bruto de syscalls, processos e threads em algo amigável.

Um wrapper em Go que executa o `strace` e transforma sua saída em algo mais legível, organizado e mais amigável.

---

## O projeto

O desenvolvimento começou com o objetivo de criar um wrapper simples para o `strace`, e uma TUI (Text User Interface) para visualizar as syscalls e os processos de forma mais amigável que o `strace` tradicional.

Mas, lembrando das palestras do Jefferson, sobre Cloud Native e infraestrutura, comecei a pensar como poderia usar o `stracectl` para analisar aplicações rodando em Kubernetes.

E aí surgiu a ideia do modo sidecar, onde o `stracectl` roda como um container auxiliar, coletando dados e expondo via HTTP API e a dashboard web acabou virando uma parte natural do projeto.

O projeto acabou ganhando muita informação e funcionalidades, mas a ideia central sempre foi a mesma: tornar o `strace` mais acessível e útil, especialmente para quem não tem tanta experiência com ele.

Assim nasceu a ideia de criar um site com documentação e exemplos de como usar o `stracectl` em diferentes cenários, desde o uso local até a análise de containers como sidecar dentro de um cluster Kubernetes.

Então o projeto acabou virando um pequeno ecossistema:

* Uma **TUI interativa (estilo htop)** para explorar syscalls em tempo real
* Um **modo sidecar HTTP**, pensado para Kubernetes
* Um **site com documentação e exemplos de uso**
* Um **README bem completo**, que funciona quase como um guia de aprendizado
* Fluxos documentados (live tracing, attach, replay, sidecar, etc)

Durante o processo de desenvolvimento, percebi que não basta só construir a ferramenta. É necessário também criar uma experiência de aprendizado, documentação clara e exemplos práticos para que as pessoas possam realmente usar o `stracectl` e entender o valor que ele traz.

---

## Como funciona

Em vez de mostrar cada syscall ou processo em execução isoladamente, o `stracectl` faz agregações em tempo de execução, mostrando:

* Quantas vezes cada syscall foi chamada
* Quanto tempo elas levam (latência)
* Taxa de erro
* Classificação por categoria (I/O, FS, NET, MEM, PROC)

Tudo isso aparece em um dashboard interativo, onde você consegue navegar, ordenar e abrir detalhes.

A ideia é sair de:

> “um log gigante impossível de ler”

para:

> “um mapa do comportamento do processo”

---

A partir daqui vale explorar com mais calma cada parte do `stracectl`. Vou deixar um resumo rápido, mas vocês podem dar uma olhada na documentação completa no site do projeto — lá tem exemplos mais visuais e fluxos bem explicados.

---

### TUI interativa

A interface em terminal é provavelmente o primeiro contato com o `stracectl`.

Ela funciona como um “htop de syscalls”, permitindo navegar, ordenar e abrir detalhes em tempo real.

**Tela principal:**

![TUI 1](/images/tui_1.jpg)

**Detalhes:**

![TUI 2](/images/tui_2.jpg)

**Logs:**

![TUI 3](/images/tui_3.jpg)

**Arquivos abertos:**

![TUI 4](/images/tui_4.jpg)

---

### Agregação de syscalls

Em vez de lidar com linhas infinitas de log, o projeto agrupa chamadas por tipo e mostra métricas relevantes como latência, volume e erros.

Isso muda completamente a forma de leitura.

---

### Modo sidecar (HTTP + Web)

O `stracectl` pode rodar como um sidecar e expor dados via HTTP.

Isso inclui:

* API JSON
* WebSocket para streaming
* Dashboard web
* Métricas Prometheus

---

### Dashboard web

Além da TUI, existe uma interface web que consome os dados do modo sidecar.

Ela facilita visualização e compartilhamento das análises.

**Dashboard web:**

![Dashboard web](/images/dashweb_1.png)

**Detalhes do processo:**

![Dashboard web detalhes](/images/dashweb_5.png)

**Live tracing:**

![Live tracing](/images/dashweb_2.png)

**API:**

![API](/images/dashweb_3.png)

![API](/images/dashweb_6.png)

**Arquivos abertos:**

![Arquivos abertos](/images/dashweb_4.png)

---

### Report / análise post-mortem

Você pode pegar um log gerado com `strace` e reproduzir a análise depois.

Isso é útil para investigações offline ou compartilhamento de contexto.

**Report:**

![Report](/images/report.png)

---

### Métricas Prometheus

As métricas expostas permitem integrar com ferramentas de observabilidade.

![Prometheus](/images/metrics.png)

---

### Um parenteses aqui

A ideia do eBPF veio de uma sugestão do **[Mateus Prado](https://www.linkedin.com/in/mateusprado)**. Estou participando da mentoria dele sobre System Design e acabei pedindo a opinião dele sobre o projeto e então veio a sugestão de usar eBPF para coletar os dados, e depender menos do strace. Ah, quem quiser conhecer a mentoria fica a dica: ***[Mentoria System Design com Mateus Prado](https://www.skool.com/kyukoda/about)***

### Backend com eBPF

O suporte a eBPF permite coletar dados com menos overhead em alguns cenários.

Mas mais do que isso, abre portas para entender melhor o kernel e observabilidade moderna.

---

### Sidecar e observabilidade

Um dos pontos mais interessantes do projeto é o modo sidecar. Em vez de depender de um terminal, o `stracectl` pode expor tudo via HTTP API:

* JSON
* Métricas Prometheus

Isso permite, por exemplo:

* Analisar um container rodando em Kubernetes sem precisar anexar um terminal
* Integrar com dashboards e ferramentas de observabilidade
* Compartilhar a análise com outras pessoas em tempo real

## Mais do que código

Uma coisa que ficou clara ao longo do processo. Não basta só construir a ferramenta.

Foi necessário também:

* Criar um **site** para explicar o projeto
* Escrever documentação para diferentes cenários
* Organizar fluxos de uso (live, replay, sidecar, attach)
* Pensar na experiência de quem nunca usou `strace`

Isso acabou sendo tão importante quanto o código em si. O projeto não está pronto, tudo esta sendo parte de um experimento de aprendizado e construção, mas a ideia é que ele seja acessível e útil para quem quiser usar — e isso passa por criar uma boa experiência de aprendizado, não só uma ferramenta.

---

## Casos de uso

Na prática, o `stracectl` ajuda em situações como:

* Diagnosticar gargalos de I/O
* Entender padrões de erro (ex: `ENOENT` recorrente)
* Explorar o comportamento de aplicações em runtime
* Depurar containers de forma menos invasiva

Mas talvez o uso mais interessante seja:

> aprender como o sistema operacional realmente funciona

---

## Conclusão

O `stracectl` começou como uma tentativa de entender melhor o `strace`. No meio do caminho, virou:

* um projeto modelo de como construir uma ferramenta do zero nesse hype de AI
* um laboratório de aprendizado
* e um exercício de construir ferramenta + documentação + experiência

Menos sobre “ferramenta perfeita”… Mais sobre tornar visível algo que sempre esteve ali — mas era difícil de enxergar.

Convido a acessar o site do projeto para conhecer mais detalhes, exemplos e documentação: ***[https://fabianoflorentino.github.io/stracectl/](https://fabianoflorentino.github.io/stracectl/)***

E, claro, o código está aberto no GitHub: ***[https://github.com/fabianoflorentino/stracectl](https://github.com/fabianoflorentino/stracectl)***

Espero seu feedback, sugestões e contribuições para tornar o `stracectl` cada vez mais útil e acessível para a comunidade! 🚀
