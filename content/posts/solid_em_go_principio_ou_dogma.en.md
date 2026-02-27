---
date: '2026-01-31T02:52:52-03:00'
draft: false
title: 'SOLID in Go: principle or dogma?'
translationKey: solid_em_go_principio_ou_dogma
tags: [post, go, architecture, solid]
series: SOLID
image: /images/SOLID.jpg
---

Does this sound familiar?

**"Go is not object-oriented"** or **"SOLID is a Java / C# thing"**...

If you’ve heard this in code reviews, Twitter threads, or even inside your team, you’re not alone.

These statements aren’t entirely false — but they also don’t tell the whole story. There are other ways to understand and apply SOLID in languages that don’t follow the classic object-oriented model.

Let’s dig in.

## Does SOLID make sense in Go?

The short answer is: **yes** — as long as you understand SOLID as **design principles**, not as implementation patterns.

In Go, SOLID doesn’t show up as complex hierarchies or deep abstractions, but as simple, intentional design decisions.

---

[SOLID](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod) is an acronym for five software design principles proposed by [Robert C. Martin](http://cleancoder.com/products) (Uncle Bob). They were popularized in a strongly object-oriented context, focused on classes, inheritance, and explicit polymorphism.

The principles are:

* **Single Responsibility Principle (SRP)**
* **Open/Closed Principle (OCP)**
* **Liskov Substitution Principle (LSP)**
* **Interface Segregation Principle (ISP)**
* **Dependency Inversion Principle (DIP)**

None of this is incompatible with Go. What changes is *how* these principles manifest.

So… if Go isn’t classic OOP, why talk about SOLID?

## Go isn’t classic OOP — and that’s intentional

Go has no inheritance, no classes, and avoids deep hierarchies. Instead, the language encourages:

* **Composition over inheritance**
* **Implicit interfaces**
* **Simple structs**
* **Functions as first-class citizens**

These characteristics fundamentally change how SOLID is applied.

The main point isn’t to copy solutions from other languages, but to understand **what problem each principle is trying to solve** — and how we solve it in an idiomatic Go way.

## It’s a mistake to write Go as if it were classic OOP

The most common mistake when trying to apply SOLID in Go is creating abstractions before there is a real problem.

### Common example

```go
type UserService interface {
  CreateUser(name string) error
}
```

Creating interfaces “just in case” rarely helps in Go. Without multiple concrete implementations or a clear reason to decouple, the abstraction only adds complexity and indirection.

In Go, **interfaces should emerge from usage**, not from a future intention.

---

## So… why SOLID in Go?

Because when applied appropriately, the principles help you write code that is simpler, more testable, and easier to maintain.

### 1. Small interfaces are natural in Go

```go
type Reader interface {
  Read(p []byte) (n int, err error)
}
```

This kind of interface wasn’t created to “follow SOLID”, but it ends up reflecting the **Interface Segregation Principle (ISP)** perfectly: small, focused contracts that are easy to implement.

### 2. Composition solves more than inheritance

Composition in Go maps naturally to several principles:

* **SRP**, by keeping responsibilities well defined
* **OCP**, by enabling extension through composition
* **DIP**, by depending on behaviors, not concrete implementations

It helps avoid fragile hierarchies and hard-to-predict side effects, even without inheritance.

### 3. Explicit dependencies

In Go, dependencies are usually passed directly:

```go
func NewService(repo Repository) *Service {
  return &Service{repo: repo}
}
```

This makes code easier to read, simplifies tests, and makes it clear what each component really depends on.

---

## SOLID in Go is more about boundaries than patterns

In Go, applying SOLID is more about:

* defining clear responsibility boundaries
* protecting simple, explicit contracts
* reducing coupling between packages
* making tests and changes easier

…and less about:

* building abstraction trees
* anticipating extensions that might never happen
* adding complexity with no real payoff

## And when doesn’t SOLID make sense?

In small, stable code with only one concrete implementation, extra abstractions rarely help.

Go often prefers **practical simplicity** over theoretical elegance.

## Next steps

In the next posts, we’ll explore each SOLID principle using Go as the example language:

* where it makes sense
* where it doesn’t
* how to apply it idiomatically

## Conclusion

SOLID in Go isn’t a ready-made recipe — it’s a set of [heuristics](https://en.wikipedia.org/wiki/Heuristic).

When applied with moderation, it helps you write code that is:

* more testable
* more readable
* more resilient to change
* easier to maintain

When applied without a real need, it only adds unnecessary complexity.

In Go, SOLID isn’t a set of rules — it’s a filter for making better design decisions.

See you in the next post.

## References

* [But Uncle Bob](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)
* [Aprenda Golang](https://aprendagolang.com.br/o-que-e-solid/)
* [Wikipedia](https://pt.wikipedia.org/wiki/SOLID)
* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
