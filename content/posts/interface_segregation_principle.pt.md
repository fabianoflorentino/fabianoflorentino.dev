---
date: '2026-02-19T17:52:53Z'
draft: false
title: 'Interface Segregation Principle'
translationKey: interface_segregation_principle
tags: [post, go, arquitetura, solid, isp]
series: SOLID
image: /images/ISP.jpg
---

Este post é parte 4 de uma série sobre SOLID. Acompanhe os outros artigos pela tag [/solid](/tags/solid/).

## Interface Segregation Principle (ISP)

O **Interface Segregation Principle** diz:

> Clientes não devem ser forçados a depender de métodos que não utilizam.

Em termos mais práticos:

> É melhor ter várias interfaces pequenas e específicas do que uma interface grande e genérica.

Se o SRP fala sobre responsabilidade de **classes**, o ISP fala sobre responsabilidade de **interfaces**.

Fazendo um paralelo com Go, podemos pensar em interfaces como contratos que definem o comportamento esperado. O ISP nos orienta a manter esses contratos enxutos e focados, evitando que clientes sejam obrigados a implementar ou depender de métodos que não fazem sentido para eles.

---

## A interface "faz tudo"

Imagine uma API simples de usuários. Você começa com algo aparentemente conveniente:

```go
type UserRepository interface {
    Save(user User) error
    FindByID(id string) (User, error)
    Delete(id string) error
    CountActiveUsers() (int, error)
    GenerateReport() ([]byte, error)
}
```

No começo parece normal. Mas observe o que está acontecendo aqui: essa interface mistura várias responsabilidades:

* Persistência
* Consulta
* Métrica
* Geração de relatório

Agora imagine um caso de uso simples:

```go
type CreateUserUseCase struct {
    repo UserRepository
}
```

Foi determinado anteriormente que o caso de uso só precisa de `Save`, mas ele depende também de:

* `Delete`
* `CountActiveUsers`
* `GenerateReport`

Essas funções não são utilizadas por esse caso de uso, e mesmo assim ele depende que todas sejam implementadas para satisfazer o contrato da interface. Esse é exatamente o comportamento que o ISP tenta evitar.

---

## Quais problemas surgem com essa implementação?

1. Interfaces crescem de forma descontrolada.
2. Mocks ficam complexos e difíceis de manter.
3. Mudanças em um método afetam clientes que não deveriam ser impactados.
4. Métodos são implementados apenas para satisfazer o contrato.
5. Surge o clássico: `panic("not implemented")`.

Esses são sinais claros de violação do ISP.

---

## Como aplicar o ISP na prática?

Vamos segregar as responsabilidades:

```go
// Interface para persistência
type UserSaver interface {
    Save(user User) error
}

// Interface para consulta
type UserFinder interface {
    FindByID(id string) (User, error)
}

// Interface para métricas
type UserCounter interface {
    CountActiveUsers() (int, error)
}
```

Dessa forma, as responsabilidades ficam separadas e cada caso de uso depende apenas do que realmente precisa:

```go
type CreateUserUseCase struct {
    saver UserSaver
}
```

Agora temos:

* Baixo acoplamento
* Testes mais simples
* Mocks menores e mais claros
* Mudanças isoladas
* Código mais coeso

---

## Em Go, o ISP é quase natural

Existe um ponto interessante aqui: em Go, **quem consome define a interface**.

Isso favorece naturalmente o ISP.

Exemplo clássico da standard library:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

* Pequena
* Específica
* Fácil de compor

A própria filosofia da linguagem incentiva interfaces pequenas e focadas, tornando a aplicação do ISP algo bastante orgânico no ecossistema Go.

---

## Go Playground

Você pode ver um exemplo completo funcionando no Go Playground:

[https://go.dev/play/p/FrRi7U2KwuE](https://go.dev/play/p/FrRi7U2KwuE)

Observe que o `CreateUserUseCase` não sabe que existem métodos como `Delete`, `GenerateReport` ou `CountActiveUsers`. Ele depende exclusivamente do que precisa.

Isso é ISP na prática.

---

## E quando surge uma nova "entidade"?

Uma dúvida comum ao aplicar ISP é:

> "Se agora eu preciso criar uma nova entidade, devo criar outra interface separada?"

A resposta é: **depende de quem está consumindo a interface**.

O ISP não é sobre quantidade de métodos.
É sobre evitar que um cliente dependa de comportamentos que não utiliza.

---

### Cenário 1 — Administrador é apenas um tipo de User

Se "Administrador" é apenas um `User` com uma role diferente, nada muda estruturalmente.

Você pode continuar usando uma interface pequena:

```go
type UserSaver interface {
    Save(user User) error
}
```

E o caso de uso:

```go
type CreateAdminUseCase struct {
    saver UserSaver
}
```

Aqui o ISP está sendo respeitado, pois o caso de uso depende apenas do que precisa.

---

### Cenário 2 — Administrador possui novos comportamentos

Agora imagine que administradores podem:

* Suspender usuários
* Gerar relatórios
* Listar todos os usuários

Um erro comum seria criar uma interface gigante baseada na entidade:

```go
type AdminRepository interface {
    Save(user User) error
    FindByID(id string) (User, error)
    Delete(id string) error
    CountActiveUsers() (int, error)
    GenerateReport() ([]byte, error)
    SuspendUser(id string) error
}
```

Isso não é automaticamente errado.

A violação ocorre quando um caso de uso depende dessa interface inteira, mas utiliza apenas um método.

Exemplo:

```go
type SuspendUserUseCase struct {
    repo AdminRepository
}
```

Se ele utiliza apenas `SuspendUser`, então está dependendo de métodos que não usa.

---

## A abordagem idiomática em Go

Em Go, é mais comum definir interfaces a partir do consumo:

```go
type UserSuspender interface {
    SuspendUser(id string) error
}
```

E o caso de uso:

```go
type SuspendUserUseCase struct {
    suspender UserSuspender
}
```

Agora a interface é pequena, específica e alinhada ao que o cliente realmente precisa.

---

## Conclusão

Não crie outra interface apenas porque surgiu outro "tipo" de usuário.

Crie outra interface quando surgir um novo conjunto de comportamentos necessários para um cliente específico.

O ISP é orientado ao consumidor, não à entidade.

* Interfaces grandes são um cheiro arquitetural.
* Prefira interfaces pequenas e específicas.
* Quem consome define a interface.
* Se você está escrevendo `panic("not implemented")`, provavelmente violou o ISP.
* Em Go, aplicar ISP é quase o caminho natural.

---

## Referências

[Wikipedia](https://en.wikipedia.org/wiki/Interface_segregation_principle)
[Blog schembri](https://schembri.me/solid-interface-segregation-principle-isp/)
[Blog Cleancoder](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
