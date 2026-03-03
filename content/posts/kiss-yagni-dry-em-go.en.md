---
date: '2026-03-02T21:13:45Z'
draft: false
title: 'KISS, YAGNI, and DRY in Go: when to simplify, when to postpone, and when to abstract'
translationKey: kiss-yagni-dry-em-go
tags: [post, go, architecture, design, principles, kiss, yagni, dry]
image: /images/kiss-yagni-dry-go.jpg
---

## KISS, YAGNI, and DRY in Go

Just as SOLID organizes principles aimed at object-oriented design, **KISS, YAGNI, and DRY help guide day-to-day architectural decisions**.

They do not define structure by themselves. They help guide mindset and decision-making.

In this post, I share what I have been learning about design and architecture best practices, especially in Go.

In Go — a language designed for simplicity, clarity, and composition — these principles become more evident in practice.

Here, the goal is to explore together:

* The conceptual origin of these principles
* A quick decision map for daily work
* Practical examples in Go
* Maturity and warning signs
* Real trade-offs

---

## Quick Decision Map

Before the examples, here is a summary you can use day to day:

|Principle|Key question|Practical goal|Common anti-pattern|
|---|---|---|---|
|**KISS**|Is there a simpler way to solve this?|Reduce accidental complexity|“Pass-through” layers|
|**YAGNI**|Does this solve a real problem today?|Avoid premature investment|Hypothetical extensibility|
|**DRY**|Is the same domain rule repeated?|Preserve consistency|Generic abstraction too early|

Remember these principles are not rigid rules, but guides for reflection. Context always matters.

> **KISS simplifies structure. YAGNI protects time. DRY protects knowledge.**

---

## Historical Context

### KISS — “Keep It Simple, Stupid”

The KISS principle emerged in military engineering in the 1960s, associated with U.S. Navy system design ([source](https://en.wikipedia.org/wiki/KISS_principle)).

The core idea was simple:

> Simple systems fail less.

In software engineering, this means reducing unnecessary complexity.

---

### YAGNI — “You Aren’t Gonna Need It”

YAGNI gained traction within the Extreme Programming (XP) movement in the 1990s ([source](https://martinfowler.com/bliki/Yagni.html)).

The proposal was straightforward:

> Do not implement today what is not yet a real requirement.

Excessive anticipation creates waste.

---

### DRY — “Don’t Repeat Yourself”

DRY was formalized in *The Pragmatic Programmer* ([source](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)).

Its more precise definition is:

> Every piece of knowledge must have a single, unambiguous representation within a system.

It is not about repeating code. It is about repeating business rules.

---

## The Problem: Accidental Complexity

Architecture is about trade-offs — and this becomes clearer with practice.

When we overdo abstraction, we usually pay with:

* too many types
* unnecessary indirection
* harder debugging
* slower onboarding

Go was designed to reduce structural friction. When we ignore this, we end up creating **accidental complexity**.

---

## KISS — Keep It Simple, Stupid

If two solutions solve the same problem, the simpler one is usually the better choice.

### Example with unnecessary complexity

```go
// Generic repository, designed for multiple data sources
type UserRepository interface {
    FindByID(id string) (User, error)
}

// Current implementation, with no real variations
type UserService interface {
    GetUser(id string) (User, error)
}

// Concrete implementation that only forwards the call
type userService struct {
    repository UserRepository
}

// Today there is only one real implementation, but we already created interface and struct
func NewUserService(repository UserRepository) UserService {
    return &userService{repository: repository}
}

// Method that only forwards the call, with no additional logic
func (service *userService) GetUser(id string) (User, error) {
    return service.repository.FindByID(id)
}
```

This is a *pass-through architecture*: multiple types just forwarding calls.

### Simpler version

```go
// Direct implementation, without unnecessary abstraction
type UserRepository struct{}

// Today there is only one real implementation, without a generic interface
func (repository *UserRepository) FindByID(id string) (User, error) {
    // ...query...
    return User{}, nil
}

// Direct service, without generic interface
type UserService struct {
    repository *UserRepository
}

// Direct constructor, without forwarding indirection
func NewUserService(repository *UserRepository) *UserService {
    return &UserService{repository: repository}
}

// Direct method, no extra logic
func (service *UserService) GetUser(id string) (User, error) {
    return service.repository.FindByID(id)
}
```

Less indirection, same functionality.

### When should you use an interface?

* Multiple real implementations today
* External boundary (infrastructure, SDK, integration)
* Explicit isolation for tests

### Warning signs (KISS)

* You navigate through 3 or more types to find a trivial rule
* A simple change requires touching too many files

### Maturity signs (KISS)

* The main flow can be explained in a few steps
* Reading reveals intent before technical details

### Trade-off (KISS)

KISS helps when it reduces accidental coupling, but hurts when it becomes naive simplification and ignores real requirements (observability, security, infrastructure isolation).

---

## YAGNI — You Aren’t Gonna Need It

A recurring lesson: do not build solutions for problems that do not exist yet.

### Example of premature abstraction

```go
// Pricing strategy, anticipating future variations
type PriceStrategy interface {
    Calculate(base float64) float64
}

// Current implementation, with no real variations
type DefaultPriceStrategy struct{}

// Today there is only one pricing behavior, but we already created interface and struct
func (DefaultPriceStrategy) Calculate(base float64) float64 {
    return base
}

// Imagining a future variation, but with no concrete scenario
type BlackFridayStrategy struct{}

// Hypothetical implementation, with no evidence of real need
func (BlackFridayStrategy) Calculate(base float64) float64 {
    return base * 0.7
}
```

If today there is only one real behavior, this structure may be premature.

### More pragmatic version

```go
// Direct implementation, without anticipatory abstraction
func CalculatePrice(base float64) float64 {
    return base
}
```

When a second real and stable variation appears, then extracting a strategy can make sense.

### Warning signs (YAGNI)

* “Let’s prepare for the future” without a concrete scenario
* Many hypothetical extension points, but no real usage

### Maturity signs (YAGNI)

* Code evolves in small iterations
* Extensions emerge from observed requirements

### Trade-off (YAGNI)

YAGNI avoids waste. Misapplied, it can become myopia: ignoring requirements already signaled by business or external contracts.

---

## DRY — Don’t Repeat Yourself

DRY is not “never repeat lines”; it is avoiding duplication of the same domain rule in different places.

### Example with duplicated rule

```go
// Password validation rule, repeated in two places
func CreateUser(input CreateUserInput) error {
    if len(input.Password) < 8 {
        return errors.New("password must be at least 8 characters")
    }
    // ...creation...
    return nil
}

// Same rule repeated in another context
func ResetPassword(input ResetPasswordInput) error {
    if len(input.Password) < 8 {
        return errors.New("password must be at least 8 characters")
    }
    // ...reset...
    return nil
}
```

The domain rule is duplicated.

### Version with centralized rule

```go
// Centralized function to validate password
func ValidatePassword(password string) error {
    if len(password) < 8 {
        return errors.New("password must be at least 8 characters")
    }
    return nil
}

// Password validation using centralized function
func CreateUser(input CreateUserInput) error {
    if err := ValidatePassword(input.Password); err != nil {
        return err
    }
    // ...creation...
    return nil
}

// Same rule reused without duplication
func ResetPassword(input ResetPasswordInput) error {
    if err := ValidatePassword(input.Password); err != nil {
        return err
    }
    // ...reset...
    return nil
}
```

Now the rule has a single maintenance point.

### Warning signs (DRY)

* Same rule copied across handlers, services, and jobs
* A bug fixed in one place but forgotten in another

### Maturity signs (DRY)

* Core rules live in cohesive functions/modules
* Names reflect domain intent, not technical detail

### Trade-off (DRY)

DRY preserves consistency; applied too early, it can create poor generic abstractions and increase coupling between contexts that should stay separate.

---

## How to balance KISS, YAGNI, and DRY in daily work

How can we apply these principles in practice without falling into dogma or implementation traps?

1. **Start simple (KISS)**
2. **Implement only what is needed now (YAGNI)**
3. **When a rule truly repeats, consolidate it (DRY)**

When in doubt, ask:

* Does this abstraction remove real complexity or just move complexity around? ([source](https://www.oreilly.com/library/view/a-philosophy-of/9781491924136/))
* Is there evidence of variation now, or is it just a hypothesis? ([source](https://martinfowler.com/bliki/Yagni.html))
* Am I centralizing knowledge or coupling different concerns? ([source](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction))

---

## Conclusion

KISS, YAGNI, and DRY do not compete with each other.
They complement each other.

Over time, the pattern becomes clearer:

* **KISS** reduces accidental complexity
* **YAGNI** avoids premature investment
* **DRY** protects domain consistency

In Go, these principles stand out because the language favors clarity and composition.
And in practice, learning is continuous: less about following dogma, more about making good trade-off decisions in the right context.

## References

* [KISS Principle - Wikipedia](https://en.wikipedia.org/wiki/KISS_principle)
* [YAGNI - Martin Fowler](https://martinfowler.com/bliki/Yagni.html)
* [DRY - The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)
* [A Philosophy of Software Design - O’Reilly](https://www.oreilly.com/library/view/a-philosophy-of/9781491924136/)
* [The Wrong Abstraction - Sandi Metz](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction/)
