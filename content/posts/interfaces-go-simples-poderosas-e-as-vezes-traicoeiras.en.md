---
date: '2026-04-15T01:13:45Z'
draft: false
title: 'Interfaces in Go: simple, powerful and sometimes treacherous'
description: 'A quick, didactic introduction to interfaces in Go: what they are, when to use them and how to avoid common pitfalls.'
translationKey: interfaces-go-simples-poderosas-e-as-vezes-traicoeiras
tags: [post, go, architecture, backend, best-practices]
image: /images/go-interface.png
---

## Introduction

If you come from languages like Java or C#, you probably expect interfaces to be explicit, verbose and tightly coupled to class hierarchies.

In Go it's exactly the opposite.

Interfaces are simple, implicit and extremely powerful, but they also hide some particularities that can generate premature complexity and unnecessary overengineering.

So, what's the path to use interfaces effectively in Go?

* understand the concept of interface and implicit implementation
* keep interfaces small and focused
* use interfaces to decouple layers, not to build complex hierarchies

---

## TL;DR

* Interfaces in Go describe behavior (methods), not structure.
* Prefer small interfaces (1–3 methods) and define them on the side that consumes them.
* Don't extract interfaces until you have two implementations or a clear need for testing/abstraction.
* Watch receivers (value vs pointer) and interfaces that hold pointer nils.
* Use `any` sparingly — prefer explicit contracts.

---

## What is an interface?

An interface in Go defines a set of behaviors. It is composed of one or more methods but has no implementation. It helps create behavioral contracts between different parts of the code without direct coupling.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

Any type that implements this method automatically satisfies this interface. Without special keywords, this is the "magic of interfaces in Go": implementation is implicit.

---

## Implicit implementation

```go
type File struct{}

func (f File) Read(p []byte) (int, error) {
    return 0, nil
}
```

Here, `File` already implements `Reader` — even without any declaration. This model reduces coupling and allows more flexible code. But it can be confusing if not used carefully, especially for people used to more declarative languages.

Careful: **don't create interfaces too early**. Start with concrete types and extract interfaces only when there's a real need for abstraction.

---

## Interfaces have no package scope

One of the most powerful characteristics of Go interfaces is that they do not belong to the package where they are defined.

Any type, in any package of the project or even external modules, can satisfy an interface — as long as it has exactly the set of required methods.

```go
// io package (standard lib)
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

```go
// your package, anywhere in your project
type MyReader struct{}

func (m MyReader) Read(p []byte) (int, error) {
    return 0, nil
}
```

`MyReader` satisfies `io.Reader` without any explicit declaration.

**Note: the signature must match `io.Reader` exactly.**

The same method name is not sufficient. If you define:

```go
func (m MyReader) Read(s string) (string, error) { ... }
```

That method does **not** satisfy `io.Reader`. Name + parameters + return types must match the interface contract.

### Exception: unexported methods

If an interface contains an unexported method (lowercase), only types from the same package can implement it. This technique is called a "sealed interface" and is used to deliberately restrict who can satisfy that interface.

```go
// Example of a "sealed" interface:
// only types in the same package can implement the interface because
// it requires an unexported method.
package repo

type sealed interface { // illustrative name; normally the interface is exported but contains an unexported method
    doInternal()
}

type impl struct{}

func (impl) doInternal() {}

// impl implements sealed only inside package repo
```

---

## Small interfaces

A good practice in Go is to keep interfaces as lean as possible. Interfaces with many methods are harder to maintain; they increase the risk of unnecessary coupling and can cause more problems than a simple, robust solution.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Small interfaces are easier to implement, test and reuse. You can compose larger interfaces when necessary:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

---

## Using interfaces

The main point of an interface appears when a function does not need to know the concrete type, only the behavior.

In this example, `Process` does not need to know if the data comes from a file, a network connection or an in-memory buffer. It only needs something that can read.

```go
package main

import (
    "bytes"
    "fmt"
    "io"
)

// Process accepts an io.Reader — anything that implements Read([]byte) (int, error)
func Process(r io.Reader) error {
    buf := make([]byte, 1024)
    n, err := r.Read(buf)
    if err != nil && err != io.EOF {
        return fmt.Errorf("error reading: %w", err)
    }

    fmt.Println("bytes read:", n)
    return nil
}

func main() {
    // simple example: use an in-memory buffer as the source
    r := bytes.NewBufferString("example")
    _ = Process(r)
}
```

This is the practical gain: the function is decoupled from the concrete implementation. Instead of depending on a specific type such as `File`, it depends only on the `Reader` contract.

Safe pattern to start:

* think first about the behavior the function needs
* accept the interface as a parameter
* call the method
* handle errors explicitly

Now any type that implements `Read` can be used:

* files
* network connections
* in-memory buffers
* mocks in tests

---

## Pointers vs values

A common question for people new to interfaces in Go is: when does a type satisfy the interface? It depends on how the method is declared — value receiver or pointer receiver.

```go
package main

import "fmt"

// Struct with method defined with pointer receiver
type Service struct{}

// Method with pointer receiver
func (s *Service) Do() { fmt.Println("pointer Do") }

// Interface that expects a Do method
type Executor interface {
    Do()
}

func main() {
    // this works: *Service has Do in its method set
    var d Executor = &Service{}
    d.Do()

    // this DOES NOT compile (uncomment to see the error):
    // var d2 Executor = Service{} // compile error: Service does not implement Executor (Do method has pointer receiver)
}
```

Practical rule:

* if the method has a value receiver, both value and pointer can satisfy the interface
* if the method has a pointer receiver, only the pointer satisfies the interface

---

## The nil problem in interfaces

```go
var s *Service = nil
var d Executor = s

fmt.Println(d == nil) // false
```

This happens because an interface in Go is composed of:

* a type
* a value

Even if the value is nil, the type still exists.

How to avoid this problem in real code:

* avoid returning pointer nil as an interface
* if the value does not exist, return nil itself

```go
// Example of a function that correctly returns nil when there is no implementation
func NewExecutor(s *Service) Executor {
    if s == nil {
        return nil
    }

    return s
}
```

---

## The empty interface (any)

`any` is an alias for `interface{}` — the interface with no methods. That means any type in Go satisfies this interface. Although it's flexible, using `any` should be done carefully because you lose type safety and contract clarity.

```go
var x any = 10
x = "now a string"
x = struct{ Name string }{"Go"}
```

It's useful in specific situations where the concrete type cannot be known at compile time:

* heterogeneous structures: `map[string]any` for data with varied types (e.g. deserialized JSON)
* functions that accept any type by design: `fmt.Println`, `fmt.Sprintf`
* implementations of generic containers before generics arrived

**Cautions when using `any`:**

* you give up compile-time type checking — errors show up only at runtime
* to use the value you must do a type assertion, which can panic if done without checking
* code becomes harder to understand and maintain because the type contract disappears
* it can encourage overengineering: if you use `any` in many places, it's often a sign that the wrong abstraction was chosen

Prefer interfaces with defined behavior. Use `any` as a last resort.

---

## Type assertion

When you receive a value of type `any` (or a more generic interface) and need the concrete type, use a type assertion. Always prefer the form that returns the second value (`ok`) to avoid panics:

```go
package main

import "fmt"

func main() {
    var x any = 10

    // safe assertion
    v, ok := x.(int)
    if ok {
        fmt.Println("int", v)
    } else {
        fmt.Println("not int")
    }
}
```

Use type assertion when you have confidence about the expected type or when you have a safe fallback.

---

## Type switch

If you need to handle several possible types coming from an interface, use a type switch. It's cleaner and safer than multiple assertions:

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
        fmt.Printf("other type: %T\n", v)
    }
}

func main() {
    printAny(10)
    printAny("text")
    printAny(3.14)
}
```

---

## Go doesn't have override

Go doesn't have inheritance in the Java or C# sense. What Go offers is **embedding** (composition): a type can include another. The outer type's method hides the embedded type's method (*method shadowing*), but both remain accessible:

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
fmt.Println(c.Hello())       // "child" — method of the concrete type
fmt.Println(c.Base.Hello())  // "base"  — still accessible directly
```

This is different from override because there is no automatic polymorphism by hierarchy. Behavior is resolved by the static type, not dynamically.

Polymorphism in Go is exclusively via interfaces:

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

`Base` and `Child` are independent types that satisfy the same interface — no inheritance, no override.

---

## Interfaces vs Generics

With the arrival of generics in Go, a common question emerged: when to use each?

Use interfaces when:

* you want to abstract behavior
* you need to decouple layers (e.g. hexagonal architecture)

Use generics when:

* you want to reuse algorithms
* you need compile-time type safety

---

## Interfaces in practice (Hexagonal Architecture)

Interfaces are ideal to represent ports:

```go
type UserRepository interface {
    Save(user User) error
}
```

The concrete implementation can vary (Postgres, memory, etc.), but the domain doesn't need to know.

Important rule:

> Define interfaces on the side that consumes them, not on the side that implements them.

### Example test with a fake

```go
// Note: package path and types are illustrative; adapt `yourapp/service` and service.User to your project.
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
    svc := service.NewUserService(repo) // accepts UserRepository interface

    if err := svc.Create(service.User{ID: "1", Name: "A"}); err != nil {
        t.Fatal(err)
    }

    if len(repo.saved) != 1 {
        t.Fatalf("expected 1 saved user, got %d", len(repo.saved))
    }
}
```

---

## When NOT to use interfaces

Some situations where interfaces bring more cost than benefit:

* You have a single implementation and don't plan to vary — don't extract an interface yet.
* Using `any` as a substitute for typed design purely for convenience.
* Extracting a huge interface (10+ methods) instead of composing small interfaces.

In these cases, start with concrete types and extract abstractions when a real need appears.

---

## Common mistake: overengineering

Avoid creating interfaces too early:

```go
type UserService interface {
    Create()
    Update()
    Delete()
}
```

If you have only one implementation, you probably don't need the interface yet.

Start simple and extract later.

---

## Conclusion

Interfaces in Go are a powerful tool — precisely because they are simple.

When used well they allow you to build decoupled, testable systems that are easy to evolve.

But the secret is balance:

* small interfaces
* create them at the right time
* focus on behavior, not structure

Quick checklist for using interfaces correctly:

* start with the needed behavior
* define the interface on the consuming side
* keep few methods
* handle errors in examples and real code
* beware typed nil (interfaces holding pointer nils)

---

If you want to go deeper, in the next post we can explore:

* how interfaces work internally (itab, fat pointer)
* performance impact
* advanced patterns (decorators, middleware, real-world io.Reader usage)

---

## Resources & recommended reading

* Go blog - Interfaces: https://research.swtch.com/interfaces
* Spec (Method sets): https://go.dev/ref/spec#Method_sets
* io.Reader package: https://pkg.go.dev/io#Reader
* FAQ about nil interfaces: https://go.dev/doc/faq#nil_error
