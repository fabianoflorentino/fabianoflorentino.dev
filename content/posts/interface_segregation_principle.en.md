---
date: '2026-02-19T17:52:53Z'
draft: false
title: 'Interface Segregation Principle'
translationKey: interface_segregation_principle
tags: [post, go, architecture, solid, isp]
series: SOLID
image: /images/ISP.jpg
---

This post is part 4 of a SOLID series. Follow the other articles via the tag [/solid](/en/tags/solid/).

## Interface Segregation Principle (ISP)

The **Interface Segregation Principle** says:

> Clients should not be forced to depend on methods they do not use.

More practically:

> It’s better to have many small, specific interfaces than one big, generic interface.

If SRP talks about responsibility of **classes**, ISP talks about responsibility of **interfaces**.

In Go, we can think of interfaces as contracts that define expected behavior. ISP guides us to keep these contracts small and focused, so clients aren’t forced to implement or depend on methods that don’t make sense for them.

---

## The “do everything” interface

Imagine a simple user API. You start with something that looks convenient:

```go
type UserRepository interface {
    Save(user User) error
    FindByID(id string) (User, error)
    Delete(id string) error
    CountActiveUsers() (int, error)
    GenerateReport() ([]byte, error)
}
```

At first it looks fine. But notice what’s happening: the interface mixes multiple responsibilities:

* persistence
* querying
* metrics
* report generation

Now imagine a simple use case:

```go
type CreateUserUseCase struct {
    repo UserRepository
}
```

We already know the use case only needs `Save`, but it now also depends on:

* `Delete`
* `CountActiveUsers`
* `GenerateReport`

Those functions are not used by this use case, yet it depends on all of them being implemented just to satisfy the contract. That’s exactly what ISP tries to prevent.

---

## What problems show up with this approach?

1. Interfaces grow uncontrollably.
2. Mocks become complex and hard to maintain.
3. Changes in one method affect clients that shouldn’t be impacted.
4. Methods get implemented only to satisfy the contract.
5. You end up with the classic `panic("not implemented")`.

These are clear signs of an ISP violation.

---

## How do we apply ISP in practice?

Let’s segregate responsibilities:

```go
// Persistence interface
type UserSaver interface {
    Save(user User) error
}

// Query interface
type UserFinder interface {
    FindByID(id string) (User, error)
}

// Metrics interface
type UserCounter interface {
    CountActiveUsers() (int, error)
}
```

This way responsibilities are separated and each use case depends only on what it actually needs:

```go
type CreateUserUseCase struct {
    saver UserSaver
}
```

Now we get:

* lower coupling
* simpler tests
* smaller, clearer mocks
* isolated changes
* more cohesive code

---

## In Go, ISP is almost natural

Here’s an interesting point: in Go, **the consumer defines the interface**.

That naturally favors ISP.

Classic standard library example:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

* small
* specific
* easy to compose

Go’s philosophy encourages small, focused interfaces, making ISP quite organic in the ecosystem.

---

## Go Playground

You can see a complete working example on Go Playground:

[https://go.dev/play/p/FrRi7U2KwuE](https://go.dev/play/p/FrRi7U2KwuE)

Notice how `CreateUserUseCase` doesn’t even know methods like `Delete`, `GenerateReport`, or `CountActiveUsers` exist. It depends exclusively on what it needs.

That’s ISP in practice.

---

## What if a new “entity” shows up?

A common question when applying ISP is:

> "If I now need a new entity, should I create another separate interface?"

The answer is: **it depends on who is consuming the interface**.

ISP is not about the number of methods.
It’s about avoiding a client depending on behaviors it doesn’t use.

---

### Scenario 1 — Admin is just a kind of User

If “Admin” is just a `User` with a different role, nothing structural changes.

You can keep using a small interface:

```go
type UserSaver interface {
    Save(user User) error
}
```

And the use case:

```go
type CreateAdminUseCase struct {
    saver UserSaver
}
```

ISP is respected because the use case depends only on what it needs.

---

### Scenario 2 — Admin has new behaviors

Now imagine admins can:

* suspend users
* generate reports
* list all users

A common mistake is creating a huge interface based on the entity:

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

That’s not automatically wrong.

The violation happens when a use case depends on the whole interface but only uses one method.

Example:

```go
type SuspendUserUseCase struct {
    repo AdminRepository
}
```

If it only uses `SuspendUser`, then it’s depending on methods it doesn’t use.

---

## The idiomatic Go approach

In Go, it’s more common to define interfaces based on consumption:

```go
type UserSuspender interface {
    SuspendUser(id string) error
}
```

And the use case:

```go
type SuspendUserUseCase struct {
    suspender UserSuspender
}
```

Now the interface is small, specific, and aligned with what the client actually needs.

---

## Conclusion

Don’t create a new interface just because a new “type” of user appeared.

Create a new interface when a new set of behaviors is required by a specific client.

ISP is consumer-oriented, not entity-oriented.

* Large interfaces are an architectural smell.
* Prefer small, specific interfaces.
* The consumer defines the interface.
* If you’re writing `panic("not implemented")`, you probably violated ISP.
* In Go, applying ISP is often the natural path.

---

## References

* [Wikipedia](https://en.wikipedia.org/wiki/Interface_segregation_principle)
* [Schembri blog](https://schembri.me/solid-interface-segregation-principle-isp/)
* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
