---
date: '2026-02-05T02:31:46Z'
draft: true
title: 'Open/Closed Principle'
tags: [post, go, arquitetura, solid, ocp]
series: SOLID
image: /images/OCP.jpg
---

No post anterior falamos sobre o **Single Responsibility Principle (SRP)** e como ele ajuda a reduzir acoplamento, deixar responsabilidades explícitas e facilitar mudanças locais no código.

O texto terminou com uma provocação:

> *E se a API precisar suportar vários formatos ao mesmo tempo?*

Essa pergunta vem naturalmente quando se pensa em um ambiente produtivo, e é exatamente o tipo de problema que não deve ser resolvido apenas com condicionais ou duplicação de código.

É aqui que entramos no próximo princípio da série: o **Open/Closed Principle (OCP)**.

---

## O que o Open/Closed Principle (OCP)?

O OCP afirma que:

> Um módulo deve estar **aberto para extensão**, mas **fechado para modificação**.

Isso não significa “não tocar mais no código”, nem sair criando abstrações complexas. Em Go, o OCP aparece de forma muito mais simples: **composição explícita e interfaces pequenas**.

---

## No exemplo do post anterior

No **[post sobre SRP](https://fabianoflorentino.dev/posts/single_responsibility_principle/)**, começamos com um handler HTTP que faz tudo:

* interpretava a requisição
* executava regra de negócio
* formatava a resposta

E então refatoramos para algo mais claro:

* o handler ficou responsável apenas pelo transporte HTTP
* a lógica de negócio foi movida para um service / use case
* a formatação da resposta foi isolada em uma interface

Um dos pontos centrais foi o `Formatter`:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

Naquele momento, o objetivo era **SRP**: separar responsabilidades.
Mas, sem perceber, já criamos a oportunidade estudar e aplicar **OCP**.

---

## Novos formatos de dados

No exemplo o sistema inicou com o suporte a dados em JSON.

E se amanhã, eu precise de:

* XML
* YAML
* CSV

Se a formatação estivesse embutida no handler ou no use case, cada novo formato exigiria modificar código existente — aumentando risco e acoplamento.

Com o contrato já definido, a solução é apenas **estender**.

---

## Estendendo o sistema sem modificá-lo

A implementação atual pode ser algo como:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

Agora, para suportar XML:

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Nenhuma mudança é necessária em:

* handlers HTTP
* use cases
* services

O sistema está **fechado para modificação**, mas **aberto para extensão**.

---

## Como funciona o OCP em Go

Diferente de linguagens orientadas a objetos que suportam herança, em Go o OCP surge quando conseguimos **adicionar comportamento novo** sem alterar o código que já existe.

Até aqui, o exemplo mostrou apenas **substituição** de dependência. Vamos deixar isso mais explícito mostrando o fluxo real de mudança.

---

## Múltiplos formatos ao mesmo tempo

Suponha que a API precise responder em **JSON ou XML**, dependendo de um header HTTP (`Accept`).

OBS: **não queremos modificar o handler nem o use case a cada novo formato**.

### Mante o contrato

O contrato continua o mesmo:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

Nenhuma mudança na interface.

---

### Novos formatos (extensão)

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Até agora, só **adição de código**.

---

### Criar um componente de composição

Ao invés de usar `if` ou `switch` no handler, criamos um novo componente responsável por **escolher** o formatter (JSON/XML):

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

Esse componente é novo. Nada existente foi modificado.

---

### Composição explícita no `main`

É aqui que o OCP fica mais claro:

```go
func main() {
    service := NewReportService()
    registry := NewFormatterRegistry()

    useCase := NewGenerateReportUseCase(service, registry)

    handler := NewReportHandler(useCase)

    http.ListenAndServe(":8080", handler)
}
```

Se amanhã precisarmos suportar YAML:

```go
type YAMLFormatter struct{}

func (y *YAMLFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

```go
type FormatterRegistry struct {
    formatters map[string]Formatter
}

func NewFormatterRegistry() *FormatterRegistry {
    return &FormatterRegistry{
        formatters: map[string]Formatter{
            "application/json": &JSONFormatter{},
            "application/xml":  &XMLFormatter{},
            "application/yaml": &YAMLFormatter{}, // Novo formato
        },
    }
}

func (r *FormatterRegistry) Get(contentType string) Formatter {
    return r.formatters[contentType]
}
```

Nenhum handler ou use case precisa mudar.

> Novamente, em aplicações maiores, essa composição pode ser extraída para um bootstrap, container ou módulo de inicialização.  
> Aqui ela permanece no main para deixar explícitas as responsabilidades e as dependências.
---

## Onde está o OCP nesse fluxo?

* novos formatos são **adicionados**
* código existente permanece intacto
* o ponto de variação está isolado
* a composição acontece em um único lugar

O sistema cresce por extensão, não por modificação.

Trocar comportamento é simples, mas **adicionar comportamento sem interferência ao comportamento existente** é o verdadeiro ganho do OCP.

---

## SRP e OCP trabalham juntos

Uma forma simples de enxergar essa relação:

* **SRP** define *onde* separar responsabilidades
* **OCP** define *como* essas partes evoluem sem quebrar o sistema

Sem SRP, o OCP vira abstração prematura.
Sem OCP, o SRP gera código correto, mas rígido.

---

## Conclusão

O Open/Closed Principle não exige frameworks nem arquiteturas complexas. No exemplo que já usamos no SRP, ele surge como consequência natural de um bom design:

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
