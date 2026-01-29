+++
date = '2026-01-28T19:47:11-03:00'
draft = true
title = 'SOLID em Go: princípios ou dogmas?'

showMetadata = false
showPublishedDate = false
showReadingTime = false
showTags = false
showAuthors = false
showCategories = false
+++

Isso soa familiar?

"Go não é orientado a objetos"

ou

"SOLID é coisa de Java / C#"

Essas afirmações não são totalmente falsas; mas também existem outras formas de entender e talvez aplicar os
princípios SOLID em outras linguagens que não sejam orientadas a objetos.

Bora entender melhor?:

## SOLID faz sentido em Go?

A resposta curta é: sim, mas não como idealizado em linguagens orientada a objetos.

---

[SOLID](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod) é uma sigla que representa cinco princípios de design de software propostos por [Robert C. Martin](http://cleancoder.com/products), também conhecido como "Uncle Bob". Esses princípios são amplamente utilizados no desenvolvimento de software orientado a objetos para criar sistemas mais robustos, flexíveis e fáceis de manter.

- **Single Responsibility Principle** (Princípio da Responsabilidade Única)
- **Open/Closed Principle** (Princípio Aberto/Fechado)
- **Liskov Substitution Principle** (Princípio da Substituição de Liskov)
- **Interface Segregation Principle** (Princípio da Segregação de Interfaces)
- **Dependency Inversion Principle** (Princípio da Inversão de Dependência)

Os cinco princípios sugerem um contexto fortemente baseado em classes, herança e polimorfismo explícito, características que não estão presentes em Go.

Então... porque SOLID em Go?

## Go não é OO clássico; isso é intencional

Go não tem herança, não possui classes e não gosta de muita hierarquias profundas. O que temos então?

- **Composição em vez de herança**
- **Interfaces implícitas**
- **Structs simples**
- **Funções de primeira classe**

Essas características mudam como SOLID se aplica em Go.

Entender o problema que cada princípio resolve é como funciona a implementação em Go.

## O Erro: tentar escrever Go como se fosse uma linguagem OO clássica

| criar abstrações antes mesmo de existir um problema concreto.

### Exemplo comum

```go
type UserService interface {
  CreateUser(name string) error
}
```

Em Go abstrações precisam existir, não planejada prematuramente. Sem múltiplas implementações concretas, sem uma necessidade real
Sem ganho claro da abstração.

## Novamente; então por que SOLID em Go?

### 1. Interfaces pequenas são naturais em Go

```go
type Reader interface {
  Read(p []byte) (n int, err error)
}
```

Esse tipo de interface implementação carrega bastante do princípio de Segregação de Interfaces (ISP).

### 2. Composição resolve resolve mais do que herança

O uso de composição em Go conversa diretamente com o princípio da Responsabilidade Única (SRP),
o Princípio da Inversão de Dependência (DIP) e o Princípio Aberto/Fechado (OCP), assim não temos hierarquias frágeis.

### 3. Dependência explícita

É intuitivo em Go escrever código mais explícito simples, sem container ou reflexão, isso deixa o princípio de inversão de dependência (DIP)
quase que natural.

```go
func NewService(repo Repository) *Service {
  return &Service{repo: repo}
}
```

---

## SOLID em GO é mais sobre definir limitese do que seguir padrões

Em Go, aplicar SOLID e tipo:

- Definir limites claros de responsabilidade
- Proteger contratos simples
- Reduzir acoplamento entre pacotes
- Facilitar testes e mudanças

o que significa não fazer:

- Criar árvores de abstrações
- Introduzir complexidade desnecessária
- Antecipar extensões que talvez nunca existam

## Referências

- [ArticleS.UncleBob.PrinciplesOfOod](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)
