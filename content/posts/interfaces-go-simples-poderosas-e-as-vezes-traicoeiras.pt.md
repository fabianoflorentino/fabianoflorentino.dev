---
date: '2026-04-15T01:13:45Z'
draft: false
title: 'Interfaces em Go: simples, poderosas e às vezes traiçoeiras'
description: 'Introdução rápida e didática sobre interfaces em Go: o que são, quando usar e como evitar armadilhas comuns.'
translationKey: interfaces-go-simples-poderosas-e-as-vezes-traicoeiras
tags:  [post, go, arquitetura, backend, boas-praticas]
image: /images/go-interface.png
---

## Introdução

Se você vem de linguagens como Java ou C#, provavelmente espera que interfaces sejam algo explícito, verboso e fortemente acoplado à hierarquia de classes.

Em Go, é exatamente o contrário.

Interfaces são simples, implícitas e extremamente poderosas, mas também escondem algumas particularidades que podem gerar complexidade prematura e overengineering desnecessário.

Então, qual é o caminho para usar interfaces de forma eficaz em Go?

* entender o conceito de interface e implementação implícita
* manter interfaces pequenas e focadas
* usar interfaces para desacoplar camadas, não para criar hierarquias complexas

## TL;DR

* Interfaces em Go descrevem comportamento (métodos), não estrutura.
* Prefira interfaces pequenas (1–3 métodos) e defina-as no lado que as consome.
* Não extraia interfaces até ter duas implementações ou necessidade clara de teste/abstração.
* Cuidado com receivers (valor vs ponteiro) e com interfaces que armazenam ponteiros nil.
* Use `any` com parcimônia — prefira contratos explícitos.

---

## O que é uma interface?

Uma interface em Go define um conjunto de comportamentos. Elas são compostas por um ou mais métodos, mas não têm implementação própria. Elas também ajudam a criar contratos de comportamento entre diferentes partes do código, sem acoplamento direto.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

Qualquer tipo que implemente esse método automaticamente satisfaz essa interface. Sem palavras-chave especiais, essa é a "**mágica das interfaces em Go**": a implementação é implícita.

---

## Implementação implícita

```go
type File struct{}

func (f File) Read(p []byte) (int, error) {
    return 0, nil
}
```

Aqui, `File` já implementa `Reader` — mesmo sem declarar nada. Esse modelo reduz o acoplamento e permite escrever código mais flexível. Mas também pode levar a confusão se não for usado com cuidado, especialmente para quem está acostumado com linguagens mais declarativas.

Cuidado: **não crie interfaces antes da hora**. Comece com tipos concretos e extraia interfaces apenas quando houver necessidade real de abstração.

---

## Interfaces não têm escopo de pacote

Uma das características mais poderosas das interfaces em Go é que elas não pertencem ao pacote onde foram definidas.

Qualquer tipo, em qualquer pacote do projeto ou até em módulos externos, pode satisfazer uma interface — desde que tenha exatamente o conjunto de métodos exigidos.

```go
// pacote io (padrão da linguagem)
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

```go
// seu pacote, em qualquer lugar do projeto
type MeuReader struct{}

func (m MeuReader) Read(p []byte) (int, error) {
    return 0, nil
}
```

`MeuReader` satisfaz `io.Reader` sem nenhuma declaração explícita.

**Atenção: a assinatura deve corresponder exatamente à interface `io.Reader`.**

O mesmo nome de método não é suficiente. Se você definir:

```go
func (m MeuReader) Read(s string) (string, error) { ... }
```

Esse método **não** satisfaz `io.Reader`. Nome + parâmetros + tipos de retorno precisam ser idênticos ao contrato da interface.

### Exceção: métodos não exportados

Se uma interface contém um método com letra minúscula (não exportado), apenas tipos do mesmo pacote conseguem implementá-la. Essa técnica é chamada de "interface selada" e serve para restringir deliberadamente quem pode satisfazer aquela interface.

```go
// Exemplo de "interface selada" (sealed):
// apenas tipos do pacote podem implementar a interface porque
// ela exige um método não exportado.
package repo

type sealed interface { // nome ilustrativo; normalmente a interface será exportada com método não exportado
    doInternal()
}

type impl struct{}

func (impl) doInternal() {}

// impl implementa sealed apenas dentro do pacote repo
```

---

## Quando NÃO usar interfaces

Algumas situações onde interfaces trazem mais custo que benefício:

* Você tem apenas uma implementação e não planeja variar — não extraia interface ainda.
* Usar `any` como substituto de design tipado apenas por conveniência.
* Extrair uma interface enorme (10+ métodos) em vez de compor interfaces pequenas.

Nesses casos, o recomendado é começar com tipos concretos e extrair abstrações quando surgir necessidade real.

## Interfaces pequenas

Uma boa prática em Go é manter interfaces o mais enxutas possível. Interfaces com muitos métodos podem ser difíceis de manter; existe uma grande chance de acontecer acoplamento desnecessário e causar mais problemas do que uma solução simples e robusta.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Interfaces pequenas são mais fáceis de implementar, testar e reutilizar. Você pode compor interfaces maiores quando necessário:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

---

## Usando interfaces

O ponto principal de uma interface aparece quando uma função não precisa conhecer o tipo concreto, apenas o comportamento.

Neste exemplo, `Process` não precisa saber se os dados vêm de um arquivo, de uma conexão de rede ou de um buffer em memória. Ela só precisa de algo que saiba ler.

```go
package main

import (
    "bytes"
    "fmt"
    "io"
)

// Process recebe um io.Reader — qualquer coisa que implemente Read([]byte) (int, error)
func Process(r io.Reader) error {
    buf := make([]byte, 1024)
    n, err := r.Read(buf)

    if err != nil && err != io.EOF {
        return fmt.Errorf("erro ao ler: %w", err)
    }

    fmt.Println("bytes lidos:", n)
    
    return nil
}

func main() {
    // exemplo simples: usar um buffer em memória como fonte
    r := bytes.NewBufferString("exemplo")
    _ = Process(r)
}
```

Esse é o ganho prático: a função fica desacoplada da implementação concreta. Em vez de depender de um tipo específico como `File`, ela depende apenas do contrato `Reader`.

Padrão seguro para começar:

* pense primeiro no comportamento que a função precisa
* receba a interface no parâmetro
* execute o método
* trate erros explicitamente

Agora qualquer tipo que implemente `Read` pode ser usado:

* arquivos
* conexões de rede
* buffers em memória
* mocks em testes

---

## Ponteiros vs valores

Uma dúvida comum com interfaces em Go é: quando um tipo satisfaz a interface? Isso depende de como o método foi declarado — receiver por valor ou por ponteiro.

```go
package main

import "fmt"

// Struct com método definido com receiver por ponteiro
type Service struct{}

// Método com receiver por ponteiro
func (s *Service) Do() { fmt.Println("pointer Do") }

// Interface que espera um método Do
type Executor interface {
    Do()
}

func main() {
    // isto funciona: *Service tem Do no method set
    var d Executor = &Service{}
    d.Do()

    // isto NÃO compila (descomente para ver o erro):
    // var d2 Executor = Service{} // compile error: Service does not implement Executor (Do method has pointer receiver)
}
```

Regra prática:

* se o método foi definido com receiver por valor, valor e ponteiro podem satisfazer a interface
* se o método foi definido com receiver por ponteiro, só o ponteiro satisfaz a interface

---

## O problema do nil em interfaces

```go
var s *Service = nil
var d Executor = s

fmt.Println(d == nil) // false
```

Isso acontece porque uma interface em Go é composta por:

* tipo
* valor

Mesmo que o valor seja nil, o tipo ainda existe.

Como podemos evitar esse tipo de problema:

* evite retornar ponteiros nil como interface
* se o valor não existe, retorne nil de fato

```go
// Exemplo de função que retorna nil corretamente quando não há implementação
func NewExecutor(s *Service) Executor {
    if s == nil {
        return nil
    }

    return s
}
```

---

## Interface vazia (any)

`any` é um alias para `interface{}` — a interface sem nenhum método. Isso significa que qualquer tipo em Go satisfaz essa interface. Embora seja flexível, o uso de `any` deve ser feito com cuidado, pois você perde a segurança de tipo e a clareza do contrato.

```go
var x any = 10
x = "agora sou uma string"
x = struct{ Nome string }{"Go"}
```

É útil em situações específicas onde o tipo concreto não pode ser conhecido em tempo de compilação:

* estruturas heterogêneas: `map[string]any` para dados com tipos variados (ex.: JSON desserializado)
* funções que aceitam qualquer tipo por design: `fmt.Println`, `fmt.Sprintf`
* implementações de containers genéricos antes da chegada de generics

**Cuidados ao usar `any`:**

* você abre mão da verificação de tipo em tempo de compilação — erros aparecem só em runtime
* para usar o valor, é necessário fazer type assertion, o que pode causar panic se feito sem verificação
* o código fica mais difícil de entender e manter, pois o contrato do tipo some
* facilita overengineering: se você está usando `any` em muitos lugares, provavelmente é um sinal de que a abstração errada foi implementada

Prefira sempre interfaces com comportamento definido. Use `any` como último recurso.

---

## Type assertion

Quando você recebe um valor do tipo `any` (ou uma interface mais genérica) e precisa do tipo concreto, use type assertion. Sempre prefira a forma que retorna o segundo valor (`ok`) para evitar panics:

```go
package main

import "fmt"

func main() {
    var x any = 10

    // assertion segura
    v, ok := x.(int)
    if ok {
        fmt.Println("int", v)
    } else {
        fmt.Println("não é int")
    }
}
```

Use type assertion quando você tem confiança no tipo esperado ou quando tem um fallback seguro.

---

## Type switch

Se você precisa tratar vários tipos possíveis vindos de uma interface, use um type switch. É mais limpo e seguro que múltiplas assertions:

```go
package main

import "fmt"

func printAny(x any) {
    switch v := x.(type) {
    case int:
        fmt.Println("int", v)
    case string:
        fmt.Println("string", v)
    default:
        fmt.Printf("outro tipo: %T\n", v)
    }
}

func main() {
    printAny(10)
    printAny("texto")
    printAny(3.14)
}
```

---

## Go não tem sobrescrita (override)

O Go não tem herança no estilo de Java ou C#. O que o Go oferece é **embedding** (composição): um tipo pode incluir outro. O método do tipo exterior esconde o método do tipo embutido (*method shadowing*), mas ambos continuam acessíveis:

```go
type Base struct{}

func (b Base) Hello() string { return "base" }

type Child struct {
    Base
}

func (c Child) Hello() string { return "child" }
```

```go
c := Child{}
fmt.Println(c.Hello())       // "child" — método do próprio tipo
fmt.Println(c.Base.Hello())  // "base"  — ainda acessível diretamente
```

Isso é diferente de override porque não há polimorfismo automático por hierarquia. O comportamento é resolvido pelo tipo estático, não dinâmico.

O polimorfismo em Go é exclusivamente via interfaces:

```go
type Greeter interface {
    Hello() string
}

func Print(g Greeter) {
    fmt.Println(g.Hello())
}

Print(Base{})  // "base"
Print(Child{}) // "child"
```

`Base` e `Child` são tipos independentes que satisfazem a mesma interface — sem herança, sem override.

---

## Interfaces vs Generics

Com a chegada de generics no Go, surgiu uma dúvida: quando usar cada um?

Use interfaces quando:

* você quer abstrair comportamento (ex.: contratos de métodos)
* precisa desacoplar camadas (ex.: projetos com arquitetura hexagonal)

Use generics quando:

* quer reutilizar algoritmos (ex.: funções de ordenação, estruturas de dados)
* precisa de segurança de tipo em tempo de compilação (ex.: `[]T` onde T é um tipo genérico)

---

## Interfaces na Arquitetura Hexagonal

Interfaces são ideais para representar portas (ports):

```go
type UserRepository interface {
    Save(user User) error
}
```

A implementação concreta pode variar (Postgres, memória, etc.), mas o domínio não precisa saber disso.

Regra importante:

> Defina interfaces no lado que as consome, não no que as implementa.

### Exemplo de teste com fake

```go
package service_test

import (
    "testing"
    "yourapp/service"
)

type fakeRepo struct{ saved []service.User }

func (f *fakeRepo) Save(u service.User) error {
    f.saved = append(f.saved, u)
    return nil
}

func TestCreateUser(t *testing.T) {
    repo := &fakeRepo{}
    svc := service.NewUserService(repo) // recebe interface UserRepository

    if err := svc.Create(service.User{ID: "1", Name: "A"}); err != nil {
        t.Fatal(err)
    }

    if len(repo.saved) != 1 {
        t.Fatalf("esperava 1 usuário salvo, obteve %d", len(repo.saved))
    }
}
```

---

## Conclusão

Interfaces em Go são uma ferramenta poderosa — justamente por serem simples. Quando bem utilizadas, permitem criar sistemas desacoplados, testáveis e fáceis de evoluir.

Mas o segredo está no equilíbrio:

* interfaces pequenas
* criação no momento certo
* foco em comportamento, não em estrutura

Checklist rápido para usar interface corretamente:

* comece pela necessidade de comportamento
* defina a interface no lado que a consome
* mantenha poucos métodos
* trate erros nos exemplos e no código real
* cuidado com typed nil (interfaces que guardam ponteiros nil)

---

## Recursos & leitura recomendada

* Go blog - Interfaces: [https://research.swtch.com/interfaces](https://research.swtch.com/interfaces)
* Spec (Method sets): [https://go.dev/ref/spec#Method_sets](https://go.dev/ref/spec#Method_sets)
* pacote io.Reader: [https://pkg.go.dev/io#Reader](https://pkg.go.dev/io#Reader)
* Artigo sobre nil interfaces: [https://go.dev/doc/faq#nil_error](https://go.dev/doc/faq#nil_error)
