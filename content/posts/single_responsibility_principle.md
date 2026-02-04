---
date: '2026-02-03T16:04:33Z'
draft: false
title: 'Single Responsibility Principle (SRP)'
tags: [post, go, arquitetura, solid, srp]
series: SOLID
image: /images/SRP.jpg
---

Princípio de Resposabilidade única (Single Responsability Principle) a.k.a (SRP) criada por [Robert C. Matrin (Uncle Bob)](http://cleancoder.com/products) parece simples em sua definição;

> **Uma classe deve ter apenas um motivo para mudar.**  

Simples, não?

Na prática, porém, esse princípio muitas vezes acaba sendo aplicado de forma errada, resultando em:

* structs artificiais demais
* interfaces sem propósito claro
* código mais complexo do que o problema original

Em Go aplicar SRP não significa criar dezenas de structs pequenas. Significa garantir que **cada parte do código tenha uma razão clara e única para mudar**.

> Em Go você não tem [classes](https://pt.wikipedia.org/wiki/Classe_(programa%C3%A7%C3%A3o)) como nas linguagens de programação tradicionais, em Go a estrutura que se assemelha a uma classe é a struct, essa semelhança se da por conta da sua natureza de abstraçao de dados [TAD](https://pt.wikipedia.org/wiki/Tipo_abstrato_de_dado) conjunto de objetos com características semelhantes.

---

## Um handler HTTP que faz tudo

Imagine uma API REST, escrita com os módulos *builtin* do Go (`net/http` e `encoding/json`), com endpoint que retorna informações do sistema:

```go
func ReportHandler(w http.ResponseWriter, r *http.Request) {
  data := map[string]int{
    "active_users": 120,
    "errors":       3,
  }

  response, err := json.Marshal(data)
  if err != nil {
    return errors.New("problema em recuperar a resposta")
  }

  w.Header().Set("Content-Type", "application/json")
  w.Write(response)
}
```

Esse código funciona, mas ele pode mudar por **motivos diferentes**:

* a **regra de negócio** muda (novos dados, novas regras)
* o **formato da resposta** muda (JSON hoje, XML amanhã)
* o **transporte** muda (HTTP agora, gRPC depois)

Quando tudo está no mesmo lugar, o código passa a ter múltiplas razões para mudar — exatamente o que o SRP tenta evitar.

---

## Aplicando SRP

Vamos fazer uma pequena refatoração, o exemplo anterior aplicando o **Single Responsibility Principle de forma explícita**.

A ideia é simples:

* o handler HTTP cuida **apenas do transporte**
* a regra de negócio fica fora do `net/http`
* a formatação da resposta é responsabilidade de outro componente

Isso deixa claro **quem muda por qual motivo**.

---

### Regra de negócio: dados do sistema

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

Esse código muda **apenas** se a regra de negócio mudar.

---

### Formatação: responsabilidade isolada

```go
type Formatter interface {
  Format(SystemReport) ([]byte, error)
}
```

Implementação JSON:

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(report SystemReport) ([]byte, error) {
  return json.Marshal(report)
}
```

Se amanhã for necessário XML, YAML ou outro formato, cria-se outra implementação sem alterar o restante do código.

---

### Handler HTTP: apenas transporte

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

Agora o handler muda **somente** se o transporte HTTP mudar.

---

### Use case: orquestrando a regra de negócio

Em sistemas "production-ready", é comum existir uma camada intermediária entre o handler e a regra de negócio: o **use case**.

O use case coordena o fluxo da aplicação, sem conhecer detalhes de HTTP ou de formatação específica.

```go
type GenerateReportUseCase struct {
  Service *ReportService
}

func (u *GenerateReportUseCase) Execute() SystemReport {
  return u.Service.Generate()
}
```

Esse componente muda apenas se o **fluxo do caso de uso** mudar.

---

### Handler HTTP

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

Agora o handler continua responsável **somente pelo transporte HTTP**.

---

### Composição explícita no `main`

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

Essa composição deixa claro como as responsabilidades se conectam — sem frameworks, acoplamento forte.

> Em aplicações maiores, essa composição pode ser extraída para um bootstrap, container ou módulo de inicialização.  
> Aqui ela permanece no `main` para deixar explícitas as responsabilidades e as dependências.

---

## SRP em Go começa com interfaces pequenas

Em Go, o SRP aparece de forma natural quando você cria **interfaces mínimas**, cada uma com um único papel bem definido.

No nosso exemplo, uma responsabilidade clara é **formatar a resposta da API**.

```go
type Formatter interface {
  Format(Data) ([]byte, error)
}
```

Essa interface não sabe:

* se o formato é JSON ou XML
* quem vai usar o resultado
* se isso será enviado via HTTP, arquivo ou fila

Ela tem um único objetivo: **transformar dados em uma representação**.

---

## Implementação concreta: JSONFormatter

```go
type JSONFormatter struct{}

func (f *JSONFormatter) Format(data Data) ([]byte, error) {
  return json.Marshal(data)
}
```

Aqui vale destacar um ponto importante do Go:

* interfaces são implementadas **implicitamente**
* não existe `implements`
* basta que a struct tenha o método com a assinatura correta

Isso reduz acoplamento sem adicionar complexidade.

---

## E se eu precisar de outro formato?

Esse é exatamente o cenário que o SRP tenta facilitar.

Se amanhã a API precisar responder em XML, basta criar outra implementação:

```go
type XMLFormatter struct{}

func (x *XMLFormatter) Format(data Data) ([]byte, error) {
  return xml.Marshal(data)
}
```

Nenhuma outra parte do sistema precisa mudar:

* a regra de negócio continua a mesma
* o handler continua o mesmo
* o use case continua o mesmo

Cada formatter muda por um único motivo: **o formato da resposta**.

---

## O que geralmente dá errado

Um erro comum é concentrar todos os formatos em uma única struct, usando condicionais:

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
    return nil, errors.New("formato não suportado")
  }
}
```

Esse código passa a ter vários motivos para mudar:

* novo formato
* mudanças de regra
* validação
* controle de erro

Isso viola o **SRP** e tende a crescer sem controle.

---

## SRP não é criar uma struct por método

Em Go, o SRP funciona melhor quando você deixa de pensar em *classes* e passa a pensar em **razões para mudar**.

Em Go, isso geralmente se traduz em:

* structs simples
* interfaces pequenas
* composição no use case ou no `main`
* baixo acoplamento entre camadas

---

## Uma regra prática que funciona

> **Se uma struct precisa importar `net/http` e `encoding/json` ao mesmo tempo, provavelmente ela tem mais de uma responsabilidade.**

Essa regra simples resolve mais problemas de SRP no dia a dia do que muita teoria.

---

## Conclusão

O SRP em Go não é sobre seguir dogmas de orientação a objetos.
É sobre reduzir acoplamento, deixar claras as responsabilidades de cada parte do código e permitir mudanças locais sem efeitos colaterais.
Com interfaces pequenas, structs simples e composição explícita, normalmente isso é mais do que suficiente.
No próximo post da série, podemos explorar como o SRP se conecta com handlers HTTP maiores ou com uma arquitetura hexagonal aplicada em Go.

## Referências

* [Blog cleancode](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
* [Wikipedia - SRP](https://en.wikipedia.org/wiki/Single-responsibility_principle)
* [Wikipedia - Classes](https://pt.wikipedia.org/wiki/Classe_(programa%C3%A7%C3%A3o))
* [Wikipedia - TAD](https://pt.wikipedia.org/wiki/Tipo_abstrato_de_dado)
* [But uncle Bob](http://www.butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod)
* [Structs vs Classes](https://ttemporin.dev/diferencas-entre-structs-e-classes/)
* [Paper - SRP: The Single Responsibility Principle](https://drive.google.com/file/d/0ByOwmqah_nuGNHEtcU5OekdDMkk/view?resourcekey=0-AbuGpXQzwZcUGExkktKt0g)

## E se?

A API precisar suportar vários formatos ao mesmo tempo? Esse tipo de problema podemos responder com o outro princípio

Até lá!
