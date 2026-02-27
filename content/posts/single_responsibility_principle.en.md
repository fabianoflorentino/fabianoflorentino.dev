---
date: '2026-02-03T16:04:33Z'
draft: false
title: 'Single Responsibility Principle (SRP)'
translationKey: single_responsibility_principle
tags: [post, go, architecture, solid, srp]
series: SOLID
image: /images/SRP.jpg
---

This post is part 1 of a SOLID series. Follow the other articles via the tag [/solid](/en/tags/solid/).

The **Single Responsibility Principle (SRP)**, popularized by [Robert C. Martin (Uncle Bob)](http://cleancoder.com/products), sounds simple in its definition:

> **A class should have only one reason to change.**

Simple, right?

In practice, though, SRP is often misapplied, resulting in:

* too many “artificial” structs
* interfaces with no clear purpose
* code more complex than the original problem

In Go, applying SRP does not mean creating dozens of tiny structs. It means ensuring **each part of the code has a clear, single reason to change**.

> In Go you don’t have [classes](https://en.wikipedia.org/wiki/Class_(computer_programming)) like in traditional languages. The closest structure is a `struct`, which resembles a class in the sense that it groups data and behavior.

---

## An HTTP handler that does everything

Imagine a REST API written only with Go’s builtin modules (`net/http` and `encoding/json`), with an endpoint that returns system info:

```go
func ReportHandler(w http.ResponseWriter, r *http.Request) {
  data := map[string]int{
    "active_users": 120,
    "errors":       3,
  }

  response, err := json.Marshal(data)
  if err != nil {
    return errors.New("failed to build response")
  }

  w.Header().Set("Content-Type", "application/json")
  w.Write(response)
}
```

This code works, but it can change for **different reasons**:

* the **business rule** changes (new data, new rules)
* the **response format** changes (JSON today, XML tomorrow)
* the **transport** changes (HTTP now, gRPC later)

When everything is in the same place, the code ends up with multiple reasons to change — exactly what SRP tries to avoid.

---

## Applying SRP

Let’s do a small refactor and apply SRP **explicitly**.

The idea is simple:

* the HTTP handler handles **transport only**
* business logic stays outside `net/http`
* response formatting becomes someone else’s responsibility

This makes it clear **who changes for which reason**.

---

### Business rule: system data

```go
type SystemReport struct {
  ActiveUsers int `json:"active_users"`
  Errors      int `json:"errors"`
}

type ReportService struct{}

func (s *ReportService) Generate() SystemReport {
  return SystemReport{
    ActiveUsers: 120,
    Errors:      3,
  }
}
```

This code changes **only** if business logic changes.

---

### Formatting: isolated responsibility

```go
type Formatter interface {
  Format(SystemReport) ([]byte, error)
}
```

JSON implementation:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
  return json.Marshal(report)
}
```

If tomorrow you need XML, YAML, or another format, you add another implementation without changing the rest of the code.

---

### HTTP handler: transport only

```go
type ReportHandler struct {
  Service   *ReportService
  Formatter Formatter
}

func (h *ReportHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
  report := h.Service.Generate()

  output, err := h.Formatter.Format(report)
  if err != nil {
    http.Error(w, err.Error(), http.StatusInternalServerError)
    return
  }

  w.Header().Set("Content-Type", "application/json")
  w.WriteHeader(http.StatusOK)
  w.Write(output)
}
```

Now the handler changes **only** if HTTP transport changes.

---

### Use case: orchestrating business flow

In production-ready systems, it’s common to have an intermediate layer between the handler and business logic: the **use case**.

A use case coordinates the application flow without knowing HTTP details or any specific output format.

```go
type GenerateReportUseCase struct {
  Service *ReportService
}

func (u *GenerateReportUseCase) Execute() SystemReport {
  return u.Service.Generate()
}
```

This component changes only if the **use case flow** changes.

---

### HTTP handler (with use case)

```go
type ReportHandler struct {
  UseCase   *GenerateReportUseCase
  Formatter Formatter
}

func (h *ReportHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
  report := h.UseCase.Execute()

  output, err := h.Formatter.Format(report)
  if err != nil {
    http.Error(w, err.Error(), http.StatusInternalServerError)
    return
  }

  w.Header().Set("Content-Type", "application/json")
  w.WriteHeader(http.StatusOK)
  w.Write(output)
}
```

Now the handler is still responsible **only for HTTP transport**.

---

### Explicit composition in `main`

```go
func main() {
  service := &ReportService{}
  useCase := &GenerateReportUseCase{Service: service}
  formatter := &JSONFormatter{}

  handler := &ReportHandler{
    UseCase:   useCase,
    Formatter: formatter,
  }

  http.ListenAndServe(":8080", handler)
}
```

---

### Go Playground

Example implementation: [https://go.dev/play/p/nBaa_i4iQT9](https://go.dev/play/p/nBaa_i4iQT9)

---

This composition makes it clear how responsibilities connect — without frameworks, without tight coupling.

> In larger applications, composition can be extracted to a bootstrap, container, or initialization module.
> Here it remains in `main` to make responsibilities and dependencies explicit.

---

## SRP in Go often starts with small interfaces

In Go, SRP tends to show up naturally when you create **minimal interfaces**, each with one well-defined role.

In our example, one clear responsibility is **formatting the API response**.

```go
type Formatter interface {
  Format(Data) ([]byte, error)
}
```

This interface doesn’t know:

* whether the format is JSON or XML
* who will consume the result
* whether it will be sent via HTTP, written to a file, or published to a queue

It has a single goal: **transform data into a representation**.

---

## Concrete implementation: JSONFormatter

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(data Data) ([]byte, error) {
  return json.Marshal(data)
}
```

A key Go detail here:

* interfaces are implemented **implicitly**
* there is no `implements`
* it’s enough that a struct has the method with the correct signature

That reduces coupling without adding complexity.

---

## What if I need another format?

That’s exactly the scenario SRP helps with.

If tomorrow the API must respond in XML, you just add another implementation:

```go
type XMLFormatter struct{}

func (x *XMLFormatter) Format(data Data) ([]byte, error) {
  return xml.Marshal(data)
}
```

No other part of the system needs to change:

* business logic stays the same
* handler stays the same
* use case stays the same

Each formatter changes for one reason: **the output format**.

---

## What usually goes wrong

A common mistake is to put all formats into a single struct and use conditionals:

```go
type Formatter struct {
  Format string
}

func (f *Formatter) Format(data Data) ([]byte, error) {
  switch f.Format {
  case "json":
    return json.Marshal(data)
  case "xml":
    return xml.Marshal(data)
  default:
    return nil, errors.New("unsupported format")
  }
}
```

Now this code has many reasons to change:

* a new format
* rule changes
* validation
* error handling behavior

That violates **SRP** and tends to grow out of control.

---

## SRP is not “one struct per method”

In Go, SRP works best when you stop thinking in terms of “classes” and start thinking in terms of **reasons to change**.

That often translates into:

* simple structs
* small interfaces
* composition in the use case or in `main`
* low coupling between layers

---

## A practical rule that works

> **If a struct needs to import `net/http` and `encoding/json` at the same time, it probably has more than one responsibility.**

This simple heuristic solves more SRP issues day-to-day than a lot of theory.

---

## Conclusion

SRP in Go is not about following OOP dogma.
It’s about reducing coupling, making responsibilities clear, and enabling local changes without side effects.

With small interfaces, simple structs, and explicit composition, that’s usually more than enough.

In the next post in the series we can explore how SRP connects to larger HTTP handlers or how it fits into a hexagonal architecture in Go.

## References

* [Clean Coder blog](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
* [Wikipedia - SRP](https://en.wikipedia.org/wiki/Single-responsibility_principle)
* [Wikipedia - Classes](https://en.wikipedia.org/wiki/Class_(computer_programming))
* [But Uncle Bob](http://www.butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)
* [Structs vs Classes](https://ttemporin.dev/diferencas-entre-structs-e-classes/)
* [Paper - SRP: The Single Responsibility Principle](https://drive.google.com/file/d/0ByOwmqah_nuGNHEtcU5OekdDMkk/view?resourcekey=0-AbuGpXQzwZcUGExkktKt0g)

## And what if…?

What if the API needs to support multiple formats at the same time? That kind of problem is a great lead-in to the next principle.

See you there!
