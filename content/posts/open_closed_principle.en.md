---
date: '2026-02-05T02:31:46Z'
draft: false
title: 'Open/Closed Principle'
translationKey: open_closed_principle
tags: [post, go, architecture, solid, ocp]
series: SOLID
image: /images/OCP.jpg
---

This post is part 2 of a SOLID series. Follow the other articles via the tag [/solid](/en/tags/solid/).

In the previous post we talked about the **[Single Responsibility Principle (SRP)](/en/posts/single_responsibility_principle/)** and how it helps reduce coupling, make responsibilities explicit, and enable local changes in the code.

That post ended with a provocation:

> *What if the API needs to support multiple formats at the same time?*

This question naturally appears when we think about real production systems — and it’s exactly the kind of problem that **should not be solved with `if`/`switch` scattered around or code duplication**.

That’s where we move on to the next principle in the series: the **Open/Closed Principle (OCP)**.

---

## What is the Open/Closed Principle (OCP)?

In 1988, [Bertrand Meyer](https://en.wikipedia.org/wiki/Bertrand_Meyer) defined the principle with the following statement:

> A module should be **open for extension**, but **closed for modification**.

That doesn’t mean “never touch the code again”, nor does it mean creating complex abstractions prematurely.

In Go, OCP shows up in a much more pragmatic way: **small interfaces, clear contracts, and explicit composition**.

---

## Back to the previous example

In the **[SRP post](/en/posts/single_responsibility_principle/)** we started with an HTTP handler that did everything:

* parsed the request
* executed business logic
* formatted the response

After refactoring, the design became clearer:

* the handler became responsible only for HTTP transport
* business logic was isolated in a service / use case
* response formatting was extracted into an interface

One of the key parts was the `Formatter`:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

At that moment the focus was **SRP** — separating responsibilities. But without noticing, we already made the system **open for extension**.

---

## New data formats

Back to the question at the end of the previous post:

> *What if the API needs to support multiple formats at the same time?*

For example:

* XML
* YAML
* CSV

If formatting logic lived inside the handler or the use case, **each new format would require modifying existing code**, increasing [coupling](https://en.wikipedia.org/wiki/Coupling_(computer_programming)) and the risk of accidentally breaking something that already worked.

With a contract already defined, the correct solution is not to modify — it’s to **extend**.

---

## Extending without modifying

The current implementation supports JSON:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

Now we need to support XML:

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

No changes are required in:

* HTTP handlers
* use cases
* services (if any)

The system remains **closed for modification** and **open for extension**.

---

## OCP in Go

Unlike languages that heavily rely on inheritance, in Go OCP appears when we can **add new behavior** without changing existing code.

So far, we only showed **substitution** (swap JSON for XML). Now let’s make OCP even more explicit with a **real change flow**, where multiple behaviors coexist.

---

## Multiple formats at the same time

Now suppose the API must respond with **JSON or XML**, depending on the HTTP `Accept` header.

> Important: **we don’t want to change the handler or the use case every time a new format is added**.

---

### Keeping the contract

The contract remains exactly the same:

```go
type Formatter interface {
    Format(SystemReport) ([]byte, error)
}
```

No changes to the interface.

---

### Extension by addition

The implementations remain independent:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
    return json.Marshal(report)
}
```

New format:

```go
type XMLFormatter struct{}

func (f *XMLFormatter) Format(report SystemReport) ([]byte, error) {
    return xml.Marshal(report)
}
```

So far, it’s only **adding code**.

---

### Creating a composition component

Instead of spreading `if`/`switch` across the handler, we create a new component responsible only for **organizing and selecting** the available formatters:

```go
type FormatterRegistry struct {
    formatters map[string]Formatter
}

func NewFormatterRegistry() *FormatterRegistry {
    return &FormatterRegistry{
        formatters: map[string]Formatter{
            "application/json": &JSONFormatter{},
            "application/xml":  &XMLFormatter{},
        },
    }
}

func (r *FormatterRegistry) Get(contentType string) Formatter {
    return r.formatters[contentType]
}
```

This component is **new**. No existing code had to be changed.

> **Architectural note**
>
> `FormatterRegistry` is **not part of the domain**.
> It exists only to **compose the system**, collecting possible extensions and wiring concrete implementations.
>
> In practice, this kind of code usually lives in outer layers, such as:
>
> * `main` / bootstrap
> * infrastructure
> * a dedicated composition module
>
> This separation keeps the domain stable and reinforces OCP’s core idea:
> **external changes should not force changes in the core of the system**.

---

### Explicit composition in `main`

This is where OCP becomes most visible:

```go
func main() {
    service := NewReportService()
    registry := NewFormatterRegistry()

    useCase := NewGenerateReportUseCase(service, registry)
    handler := NewReportHandler(useCase)

    http.ListenAndServe(":8080", handler)
}
```

No handler or use case had to change.

> In larger applications, composition can be extracted to a bootstrap layer, container, or initialization module.
> Here it stays in `main` to keep responsibilities and dependencies explicit.

If tomorrow we need to support YAML (or any other format), the flow is the same:

* create a new implementation
* register it in composition

---

## Where is OCP in this flow?

* new behaviors are **added**
* existing code stays intact
* the variation point is isolated
* composition happens in one place

The system grows through **extension**, not modification.

Swapping behavior is nice, but **adding behavior without interfering with what already works** is the real win of OCP.

---

## Conclusion

The Open/Closed Principle doesn’t require frameworks or complex architectures.

In the example that started with SRP, it emerges as a natural consequence of good design:

* well-defined responsibilities
* clear contracts
* explicit composition

With that, the system grows by addition — not by modification.

---

## Next principle

Now that we can safely extend the system, another question arises:

> *Can any implementation really substitute another without causing side effects?*

In the next post we’ll talk about the **Liskov Substitution Principle (LSP)** and show where many “apparently correct” abstractions start to fail.

See you there.

---

## References

* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html)
* [Wikipedia](https://pt.wikipedia.org/wiki/Princ%C3%ADpio_do_aberto/fechado)
* [Schembri blog](https://schembri.me/solid-the-open-closed-principle-ocp/)
