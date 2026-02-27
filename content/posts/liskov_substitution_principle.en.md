---
date: '2026-02-10T23:29:58Z'
draft: false
title: 'Liskov Substitution Principle'
translationKey: liskov_substitution_principle
tags: [post, go, architecture, solid, lsp]
series: SOLID
image: /images/LSP.jpg
---

This post is part 3 of a SOLID series. Follow the other articles via the tag [/solid](/en/tags/solid/).

> *“If q(x) is a property provable about objects x of type T, then q(y) should be true for objects y of type S where S is a subtype of T.”*
> — Barbara Liskov

Translating that into something practical:

**if I swap one implementation for another, the system should keep working the same way.**

If the swap breaks something unexpectedly, we have a problem.

---

## Quick recap

In the **SRP** post, we organized responsibilities.

In **OCP**, we learned how to extend the system without constantly modifying existing code.

We created this interface:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

And the `ReportHandler` depends only on it:

```go
type ReportHandler struct {
    UseCase   *GenerateReportUseCase
    Formatter Formatter
}
```

So we can swap JSON for XML without touching the handler.

So far, so good.

But now comes LSP.

---

## The problem isn’t compiling

Imagine we have these implementations:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

```go
type XMLFormatter struct{}

func (x *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

Both do exactly what they promise: format the report.

Now someone decides to create this:

```go
type StrictJSONFormatter struct{}

func (f *StrictJSONFormatter) Format(report SystemReport) ([]byte, error) {
    if report.Errors > 0 {
        return nil, errors.New("cannot generate report with errors")
    }

    return json.Marshal(report)
}
```

Does it compile? Yes.
Does it implement the interface? Yes.
Does it break OCP? No.

But… it breaks LSP.

---

### Go Playground

Example implementation: [https://go.dev/play/p/LSUAutSGy2n](https://go.dev/play/p/LSUAutSGy2n)

---

## Why?

Anyone using `Formatter` expects something simple:

> “I give you a `SystemReport` and you give it back formatted.”

That’s it.

But `StrictJSONFormatter` decided to embed a business rule.

Now, depending on which implementation is chosen, the system might start failing.

And nobody using the interface was warned about that.

Substitution is no longer safe.

That’s exactly what LSP is trying to prevent.

---

## Could the rule make sense?

Maybe.

Maybe we really shouldn’t generate reports when there are errors.

But that decision should live in:

* `ReportService`
* or the `UseCase`

Not in `Formatter`.

When an implementation starts doing more than the abstraction promised, it breaks trust in the contract.

---

## LSP is about trust

SRP organizes.
OCP enables growth.
LSP ensures growth doesn’t turn into chaos.

If each new implementation requires special handling, the abstraction stopped being an abstraction.

---

## In Go this gets even more subtle

Because interfaces are implicit, any type can “fit”.

But fitting a signature doesn’t mean respecting the expected behavior.

So when you design an interface, it’s worth asking:

> If I swap this implementation tomorrow, will the rest of the system still be fine?

If the answer is “it depends”, something is off.

---

## Conclusion

LSP isn’t about inheritance.
It’s about keeping the promise of your abstraction.

If swapping implementations changes the expected behavior of the system, the contract wasn’t well defined.

And when the contract isn’t trustworthy:

* OCP loses power
* SRP starts leaking
* the architecture becomes fragile

In the next post we’ll talk about the **Interface Segregation Principle (ISP)** — which in Go often appears almost naturally when we start designing smaller, clearer interfaces.

---

## References

* [Wikipedia](https://en.wikipedia.org/wiki/Liskov_substitution_principle)
* [Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov)
* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
* [Schembri blog](https://schembri.me/solid-liskov-substitution-principle-lsp/)
