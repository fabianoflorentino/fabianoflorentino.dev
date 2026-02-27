---
date: '2026-02-26T15:33:49Z'
draft: false
title: 'Dependency Inversion Principle'
translationKey: dependency_inversion_principle
tags: [post, go, architecture, solid, dip]
series: SOLID
image: /images/DIP.jpg
---

This post is part 5 of a SOLID series. Follow the other articles via the tag [/solid](/en/tags/solid/).

## Dependency Inversion Principle

The **Dependency Inversion Principle (DIP)** is the last SOLID principle — and possibly the most challenging when we talk about architecture.

> High-level modules should not depend on low-level modules. Both should depend on abstractions.
> Abstractions should not depend on details. Details should depend on abstractions.

At first glance, it sounds like “another principle about interfaces”. But what it really aims to solve is deeper: **protect what is stable (business rules) from what is volatile (infrastructure)**.

---

## Understanding high-level vs low-level

* **High-level** → business rules (use cases, domain)
* **Low-level** → database, HTTP, queue, file system, framework
* **Abstraction** → in Go, usually an interface

Traditionally, systems were structured like this:

```txt
UserService → Database
```

The business logic depends directly on the technology.

DIP proposes inverting that direction:

```txt
UserService → Interface ← Database
```

Infrastructure depends on the high-level domain, while the domain depends on an abstraction. That’s the “inversion”.

---

## Traditional structure

```go
package main

import "database/sql"

type UserService struct {
    db *sql.DB
}

func (s *UserService) Create(name string) error {
    _, err := s.db.Exec("INSERT INTO users (name) VALUES ($1)", name)
    return err
}
```

## What DIP is trying to solve

* The domain depends directly on the database
* Testing requires infrastructure
* Swapping databases breaks code
* Business rules are coupled to implementation details

Here the high-level module (`UserService`) depends directly on the low-level module (`sql.DB`).

The problem isn’t “just” coupling. The problem is depending on something **less stable** than your business rules. Databases change, frameworks change, drivers change.

Business rules should change less.

---

## Applying DIP

### Create an abstraction

```go
type UserRepository interface {
    Save(name string) error
}
```

We create an abstraction representing *what* needs to be done — save a user — without saying *how*.

### The service depends on the abstraction

```go
type UserService struct {
    repo UserRepository
}

func (s *UserService) Create(name string) error {
    return s.repo.Save(name)
}
```

Now the domain doesn’t know whether it’s Postgres, MongoDB, memory, or an external API. It only knows there’s something that can save users.

It depends on something more stable than a database driver.

---

### Infrastructure depends on the abstraction

```go
type PostgresUserRepository struct {
    db *sql.DB
}

func (r *PostgresUserRepository) Save(name string) error {
    _, err := r.db.Exec("INSERT INTO users (name) VALUES ($1)", name)
    return err
}
```

Now the detail depends on the abstraction; the domain depends on the abstraction; the domain does not depend on the detail. That’s the inversion DIP proposes.

---

### Testing

```go
type InMemoryUserRepository struct {
    users []string
}

func (r *InMemoryUserRepository) Save(name string) error {
    r.users = append(r.users, name)
    return nil
}
```

Now we can test business logic without any external dependency. That’s one of the biggest gains from DIP: **testability and domain isolation**.

---

## DIP is not “use interfaces for everything”

A common mistake is to think DIP means:

> "Always create an interface"

Not quite.

DIP is about the **direction of dependency** and about **depending on something more stable**.

You create abstractions when there is an external dependency, expected variation, and you want to protect something important. Creating interfaces everywhere leads to unnecessary complexity and overengineering. DIP is not a dogma — it’s a strategy.

---

## DIP in Go

Go makes DIP feel natural because interfaces are implicit, small, behavior-oriented, and can be defined where they are used. A powerful Go practice is:

> Define the interface where it’s used, not where it’s implemented.

This keeps the domain in control of its own dependencies.

---

## Conclusion

DIP protects your business rules from infrastructure. It ensures your domain depends on something more stable than a database, a framework, or an external API. It improves testability, flexibility, and domain isolation.

> Your domain should not know the outside world exists.

But don’t turn this into dogma. If there’s no instability, no variation, no risk — maybe you don’t need an abstraction yet.

When you do, refactor.

If you followed the series up to here, you now have more than five principles — you have an architectural lens to make decisions with more clarity, less coupling, and a lot more predictability.

And in the real world, that matters.

---

## References

* [Wikipedia](https://pt.wikipedia.org/wiki/Princ%C3%ADpio_da_invers%C3%A3o_de_depend%C3%AAncia)
* [Object Mentor](http://objectmentor.com/resources/articles/dip.pdf)
* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
