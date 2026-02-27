---
date: '2026-02-10T23:29:58Z'
draft: false
title: 'Liskov Substitution Principle'
tags: [post, go, arquitetura, solid, lsp]
series: SOLID
image: /images/LSP.jpg
---

Este post é parte 3 de uma série sobre SOLID. Acompanhe os outros artigos pela tag [/solid](https://fabianoflorentino.dev/tags/solid/).

> *“Se q(x) é uma propriedade demonstrável dos objetos x de tipo T. Então q(y) deve ser verdadeiro para objetos y de tipo S onde S é um subtipo de T”*
> — Barbara Liskov

Traduzindo isso para o mundo real:

**se eu trocar uma implementação por outra, o sistema deveria continuar funcionando do mesmo jeito.**

Se a troca quebra algo inesperadamente, temos um problema.

---

## Lembrando onde paramos

No post de **SRP**, organizamos responsabilidades.

No de **OCP**, aprendemos a estender o sistema sem sair modificando tudo.

Criamos essa interface:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

E o `ReportHandler` depende apenas dela:

```go
type ReportHandler struct {
    UseCase   *GenerateReportUseCase
    Formatter Formatter
}
```

Ou seja: podemos trocar JSON por XML sem mexer no handler.

Até aqui, lindo.

Mas é agora que entra o LSP.

---

## O problema não é compilar

Imagina que temos essas implementações:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

```go
type XMLFormatter struct{}

func (x *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Ambas fazem exatamente o que prometem: transformam o relatório.

Agora alguém decide criar isso:

```go
type StrictJSONFormatter struct{}

func (f *StrictJSONFormatter) Format(report SystemReport) ([]byte, error) {
    if report.Errors > 0 {
        return nil, errors.New("cannot generate report with errors")
    }

    return json.Marshal(report)
}
```

Compila? Sim.
Implementa a interface? Sim.
Quebra o OCP? Não.

Mas… quebra o LSP.

---

### Go Playground

Exemplo da implementação: [https://go.dev/play/p/LSUAutSGy2n](https://go.dev/play/p/LSUAutSGy2n)

---

## Por quê?

Quem usa `Formatter` espera algo simples:

> “Eu te entrego um `SystemReport` e você me devolve ele formatado.”

Só isso.

Mas `StrictJSONFormatter` resolveu colocar uma regra de negócio no meio.

Agora, dependendo da implementação escolhida, o sistema pode começar a falhar.

E ninguém que usa a interface foi avisado disso.

A substituição deixou de ser segura.

Isso é exatamente o que o LSP quer evitar.

---

## A regra pode fazer sentido?

Talvez sim.

Talvez realmente não devêssemos gerar relatórios com erro.

Mas essa decisão deveria estar no:

* `ReportService`
* ou no `UseCase`

Não no `Formatter`.

Quando uma implementação começa a fazer mais do que a abstração prometeu, ela quebra a confiança no contrato.

---

## LSP é sobre confiança

O SRP organiza.

O OCP permite crescer.

O LSP garante que o crescimento não vire bagunça.

Se cada nova implementação exige tratamento especial, a abstração deixou de ser abstração.

---

## Em Go isso fica ainda mais sutil

Como as interfaces são implícitas, qualquer tipo pode "encaixar".

Mas encaixar na assinatura não significa respeitar o comportamento esperado.

Por isso, ao criar uma interface, vale se perguntar:

> Se eu trocar essa implementação amanhã, o resto do sistema continua tranquilo?

Se a resposta for “depende”, tem algo estranho.

---

## Conclusão

O LSP não é sobre herança.
É sobre manter a promessa da sua abstração.

Se trocar uma implementação muda o comportamento esperado do sistema, o contrato não estava bem definido.

E quando o contrato não é confiável:

* o OCP perde força
* o SRP começa a vazar
* e a arquitetura fica frágil

No próximo post vamos falar de **Interface Segregation Principle (ISP)** — que em Go costuma surgir quase naturalmente quando começamos a desenhar interfaces menores e mais claras.

## Referência

* [Wikipedia](https://en.wikipedia.org/wiki/Liskov_substitution_principle)
* [Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov)
* [Blog cleancoder](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
* [Blog Schembri](https://schembri.me/solid-liskov-substitution-principle-lsp/)
