---
date: '2026-02-05T02:31:46Z'
draft: false
title: 'Open/Closed Principle'
tags: [post, go, arquitetura, solid, ocp]
series: SOLID
image: /images/OCP.jpg
---

No post anterior falamos sobre o **[Single Responsibility Principle (SRP)](https://fabianoflorentino.dev/posts/single_responsibility_principle/)** e como ele ajuda a reduzir acoplamento, deixar responsabilidades explícitas e facilitar mudanças locais no código.

O texto terminou com uma provocação:

> *E se a API precisar suportar vários formatos ao mesmo tempo?*

Essa pergunta surge naturalmente quando pensamos em sistemas reais, em produção — e é exatamente o tipo de problema que **não deve ser resolvido com `if`, `switch` espalhados ou duplicação de código**.

É aqui que entramos no próximo princípio da série: o **Open/Closed Principle (OCP)**.

---

## O que é o Open/Closed Principle (OCP)?

Em 1988, [Bertrand Meyer](https://en.wikipedia.org/wiki/Bertrand_Meyer) definiu o princípio com a seguinte afirmação:

> Um módulo deve estar **aberto para extensão**, mas **fechado para modificação**.

Isso não significa “nunca mais tocar no código” nem sair criando abstrações complexas prematuramente.

Em Go, o OCP aparece de forma muito mais pragmática: **interfaces pequenas, contratos claros e composição explícita**.

---

## No exemplo do post anterior

No **[post sobre SRP](https://fabianoflorentino.dev/posts/single_responsibility_principle/)**, começamos com um handler HTTP que fazia tudo:

* interpretava a requisição
* executava regra de negócio
* formatava a resposta

Depois da refatoração, o desenho ficou mais claro:

* o handler ficou responsável apenas pelo transporte HTTP
* a regra de negócio foi isolada em um service / use case
* a formatação da resposta foi extraída para uma interface

Um dos pontos centrais foi o `Formatter`:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

Naquele momento o foco era **SRP** — separar responsabilidades. Mas, sem perceber, já deixamos o sistema **aberto para extensão**.

---

## Novos formatos de dados

Voltando à pergunta do final do post anterior:

> *E se a API precisar suportar vários formatos ao mesmo tempo?*

Por exemplo:

* XML
* YAML
* CSV

Se a lógica de formatação estivesse dentro do handler ou do use case, **cada novo formato exigiria modificar código existente**, aumentando [acoplamento](https://pt.wikipedia.org/wiki/Acoplamento_(programa%C3%A7%C3%A3o_de_computadores)) e risco de, sem querer, quebrar algo que já funcionava antes.

Como o contrato já está definido, e não correr o risco com grandes problemas, a solução correta não é modificar — é **estender**.

---

## Estendendo sem modificar

A implementação atual suporta JSON:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

Agora precisamos suportar XML:

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Nenhuma mudança é necessária em:

* handlers HTTP
* use cases
* services (caso existam)

O sistema permanece **fechado para modificação** e **aberto para extensão**.

---

## OCP em Go

Diferente de linguagens fortemente orientadas a herança, em Go o OCP aparece quando conseguimos **adicionar comportamento novo** sem alterar código já existente.

Até aqui, mostramos apenas **substituição** de dependência (trocar JSON por XML).

Vamos agora deixar o OCP ainda mais explícito mostrando um **fluxo real de mudança**, onde múltiplos comportamentos coexistem.

---

## Múltiplos formatos ao mesmo tempo

Agora suponha que a API precise responder em **JSON ou XML**, dependendo do header HTTP `Accept`.

> Importante: **não queremos modificar o handler nem o use case a cada novo formato**.

---

### Mantendo o contrato

O contrato continua exatamente o mesmo:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

Nenhuma alteração na interface.

---

### Extensão por adição

As implementações continuam independentes:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

Novo formato:

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Até aqui, apenas **adição de código**.

---

### Criando um componente de composição

Em vez de espalhar `if` ou `switch` pelo handler, criamos um novo componente responsável apenas por **organizar e escolher** os formatters disponíveis:

```go
type FormatterRegistry struct {
    formatters map[string]Formatter
}

func NewFormatterRegistry() *FormatterRegistry {
    return &FormatterRegistry{
        formatters: map[string]Formatter{
            "application/json": &JSONFormatter{},
            "application/xml":  &XMLFormatter{},
        },
    }
}

func (r *FormatterRegistry) Get(contentType string) Formatter {
    return r.formatters[contentType]
}
```

Esse componente é **novo**. Nenhum código existente precisou ser alterado.

> **Nota arquitetural**
>
> O `FormatterRegistry` **não faz parte do domínio nem da regra de negócio**.
> Ele existe apenas para **compor o sistema**, agrupando extensões possíveis e conectando implementações concretas.
>
> Na prática, esse tipo de código costuma viver em camadas mais externas da aplicação, como:
>
> * o `main` / bootstrap
> * a camada de infraestrutura
> * ou um módulo específico de composição
>
> Essa separação mantém o domínio estável e reforça a ideia central do OCP:
> **mudanças externas não devem forçar mudanças no core do sistema**.

---

### Composição explícita no `main`

É aqui que o OCP fica mais visível:

```go
func main() {
    service := NewReportService()
    registry := NewFormatterRegistry()

    useCase := NewGenerateReportUseCase(service, registry)
    handler := NewReportHandler(useCase)

    http.ListenAndServe(":8080", handler)
}
```

Nenhum handler ou use case precisou mudar.

> Em aplicações maiores, essa composição pode ser extraída para um bootstrap, container ou módulo de inicialização.
> Aqui ela permanece no `main` para deixar explícitas as responsabilidades e dependências.

Se amanhã precisarmos suportar YAML ou qualquer outro formato, o fluxo é o mesmo:

* criar uma nova implementação
* registrá-la na composição

---

## Onde está o OCP nesse fluxo?

* novos comportamentos são **adicionados**
* código existente permanece intacto
* o ponto de variação está isolado
* a composição acontece em um único lugar

O sistema cresce por **extensão**, não por modificação.

Trocar comportamento é simples, mas **adicionar comportamento sem interferir no que já funciona** é o verdadeiro ganho do OCP.

---

## Conclusão

O Open/Closed Principle não exige frameworks nem arquiteturas complexas.

No exemplo que começou no SRP, ele surge como consequência natural de um bom design:

* responsabilidades bem definidas
* contratos claros
* composição explícita

Com isso, o sistema cresce por adição — não por modificação.

---

## Próximo passo

Agora que já conseguimos estender o sistema com segurança, surge outra pergunta:

> *Qualquer implementação pode realmente substituir outra sem causar efeitos colaterais?*

No próximo post da série, vamos falar sobre o **Liskov Substitution Principle (LSP)** e mostrar onde muitas abstrações aparentemente corretas começam a falhar.

Até lá.

---

## Referências

* [https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html](https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html)
* [https://pt.wikipedia.org/wiki/Princ%C3%ADpio_do_aberto/fechado](https://pt.wikipedia.org/wiki/Princ%C3%ADpio_do_aberto/fechado)
* [https://schembri.me/solid-the-open-closed-principle-ocp/](https://schembri.me/solid-the-open-closed-principle-ocp/)
