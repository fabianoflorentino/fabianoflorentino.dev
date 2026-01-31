+++
date = '2026-01-31'
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

**"Go não é orientado a objetos"** ou **"SOLID é coisa de Java / C#"**...

Se você já ouviu isso em discussões de code review, em threads no Twitter ou até dentro do time, não está sozinho.

Essas afirmações não são totalmente falsas — mas também não contam a história toda. Existem outras formas de entender e aplicar os princípios SOLID em linguagens que não seguem o modelo clássico de orientação a objetos.

Bora entender melhor?

## SOLID faz sentido em Go?

A resposta curta é: **sim** — desde que você entenda SOLID como **princípios de design**, e não como padrões de implementação.

Em Go, SOLID não aparece na forma de hierarquias complexas ou abstrações profundas, mas como decisões simples e conscientes de design.

---

[SOLID](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod) é uma sigla que representa cinco princípios de design de software propostos por [Robert C. Martin](http://cleancoder.com/products), o Uncle Bob. Eles surgiram em um contexto fortemente orientado a objetos, com foco em classes, herança e polimorfismo explícito.

Os princípios são:

* **Single Responsibility Principle (SRP)** — Princípio da Responsabilidade Única
* **Open/Closed Principle (OCP)** — Princípio Aberto/Fechado
* **Liskov Substitution Principle (LSP)** — Princípio da Substituição de Liskov
* **Interface Segregation Principle (ISP)** — Princípio da Segregação de Interfaces
* **Dependency Inversion Principle (DIP)** — Princípio da Inversão de Dependência

Nada disso é incompatível com Go. O que muda é *como* esses princípios se manifestam.

Então… se Go não é OO clássico, por que falar de SOLID?

## Go não é OO clássico — e isso é intencional

Go não tem herança, não possui classes e evita hierarquias profundas. Em vez disso, a linguagem incentiva:

* **Composição em vez de herança**
* **Interfaces implícitas**
* **Structs simples**
* **Funções como cidadãos de primeira classe**

Essas características mudam completamente a forma como os princípios SOLID são aplicados.

O ponto central não é copiar soluções de outras linguagens, mas entender **qual problema cada princípio tenta resolver** — e como resolvemos esse problema de forma idiomática em Go.

## O erro clássico: escrever Go como se fosse Java

O erro mais comum ao tentar aplicar SOLID em Go é criar abstrações antes mesmo de existir um problema real.

### Exemplo comum

```go
type UserService interface {
  CreateUser(name string) error
}
```

Criar interfaces “por precaução” raramente traz benefícios em Go. Sem múltiplas implementações concretas ou sem um motivo claro para desacoplar, a abstração só adiciona complexidade e indireção.

Em Go, **interfaces devem surgir do uso**, não de uma intenção futura.

---

## Então… por que SOLID em Go?

Porque, quando aplicados com moderação, os princípios ajudam a escrever código mais simples, testável e fácil de evoluir.

### 1. Interfaces pequenas são naturais em Go

```go
type Reader interface {
  Read(p []byte) (n int, err error)
}
```

Esse tipo de interface não nasceu para “seguir SOLID”, mas acaba refletindo perfeitamente o **Princípio da Segregação de Interfaces (ISP)**: contratos pequenos, focados e fáceis de implementar.

### 2. Composição resolve mais do que herança

O uso de composição em Go conversa diretamente com vários princípios:

* **SRP**, ao manter responsabilidades bem definidas
* **OCP**, ao permitir extensão por composição
* **DIP**, ao depender de comportamentos, não de implementações concretas

Sem herança, evitamos hierarquias frágeis e efeitos colaterais difíceis de prever.

### 3. Dependências explícitas

Em Go, dependências geralmente são passadas de forma direta, sem containers, reflexão ou mágica escondida:

```go
func NewService(repo Repository) *Service {
  return &Service{repo: repo}
}
```

Isso torna o código mais legível, facilita testes e deixa claro *do que* cada componente realmente depende.

---

## SOLID em Go é mais sobre limites do que sobre padrões

Em Go, aplicar SOLID é mais sobre:

* Definir limites claros de responsabilidade
* Proteger contratos simples e explícitos
* Reduzir acoplamento entre pacotes
* Facilitar testes e mudanças

E menos sobre:

* Criar árvores de abstrações
* Antecipar extensões que talvez nunca existam
* Introduzir complexidade sem ganho real

## E quando SOLID não faz sentido?

Em código pequeno, estável e com apenas uma implementação concreta, abstrações extras raramente ajudam.

Go costuma preferir **simplicidade prática** a elegância teórica.

## Próximos passos

Nos próximos posts, vamos explorar cada princípio SOLID usando Go como linguagem de exemplo:

* Onde faz sentido
* Onde não faz sentido
* Como aplicar de forma idiomática

## Conclusão

SOLID em Go não é uma receita pronta — é um conjunto de [heurísticas](https://pt.wikipedia.org/wiki/Heur%C3%ADstica).

Quando aplicado com moderação, ajuda a escrever código:

* mais testável
* mais legível
* mais resiliente a mudanças

Quando aplicado sem necessidade real, só adiciona complexidade desnecessária.

Em Go, SOLID não é um conjunto de regras — é um filtro para decisões de design.

Até lá.

## Referências

* [But Uncle Bob](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)
* [Aprenda Golang](https://aprendagolang.com.br/o-que-e-solid/)
* [Wikipedia](https://pt.wikipedia.org/wiki/SOLID)
* [Blog cleancoder](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
