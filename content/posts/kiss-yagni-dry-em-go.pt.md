---

date: '2026-03-02T21:13:45Z'
draft: false
title: 'KISS, YAGNI e DRY em Go: quando simplificar, quando adiar e quando abstrair'
translationKey: kiss-yagni-dry-em-go
tags: [post, go, arquitetura, design, principios, kiss, yagni, dry]
image: /images/kiss-yagni-dry-go.jpg
---

## KISS, YAGNI e DRY em Go

Assim como o SOLID organiza princípios voltados para orientação a objetos, **KISS, YAGNI e DRY formam a base comportamental das decisões arquiteturais**.

Eles não definem estrutura.
Eles definem postura.

Em Go — uma linguagem projetada para simplicidade, clareza e composição — esses princípios ficam bem evidentes.

Aqui nesse post vamos falar um pouco sobre:

* A origem conceitual desses princípios
* Um mapa rápido de decisão para o dia a dia
* Exemplos práticos em Go
* Sinais de maturidade e de alerta
* Trade-offs reais

---

## Mapa Rápido de Decisão

Antes dos exemplos, um resumo para usar no dia a dia:

| Princípio | Pergunta-chave                             | Objetivo prático               | Anti-padrão comum              |
| --------- | ------------------------------------------ | ------------------------------ | ------------------------------ |
| **KISS**  | Existe um caminho com menos partes móveis? | Reduzir complexidade acidental | Camadas “pass-through”         |
| **YAGNI** | Isso resolve um problema real de hoje?     | Evitar investimento prematuro  | Extensibilidade hipotética     |
| **DRY**   | A mesma regra de domínio está repetida?    | Preservar consistência         | Abstração genérica cedo demais |

Se você lembrar só de uma coisa:

> **KISS simplifica a estrutura. YAGNI protege o tempo. DRY protege o conhecimento.**

---

## Contexto Histórico

### KISS — “Keep It Simple, Stupid”

O princípio KISS surgiu na engenharia militar dos anos 1960, associado ao design de sistemas da Marinha dos Estados Unidos.

A ideia central era simples:

> Sistemas simples falham menos.

Na engenharia de software, isso significa reduzir complexidade desnecessária.

---

### YAGNI — “You Aren’t Gonna Need It”

YAGNI ganhou força dentro do movimento Extreme Programming (XP) nos anos 1990.

A proposta era direta:

> Não implemente hoje algo que ainda não é requisito real.

Antecipação excessiva gera desperdício.

---

### DRY — “Don’t Repeat Yourself”

DRY foi formalizado no livro *The Pragmatic Programmer*.

A definição mais precisa é:

> Cada pedaço de conhecimento deve ter uma única representação no sistema.

Não é sobre repetir código.
É sobre repetir regra de negócio.

---

## O Problema: Complexidade Acidental

Arquitetura é sobre trade-offs.

Quando exageramos na abstração, pagamos com:

* excesso de tipos
* indireção desnecessária
* dificuldade de debug
* onboarding mais lento

Go foi desenhada para reduzir fricção estrutural. Quando ignoramos isso, criamos **complexidade acidental**.

---

## KISS — Keep It Simple, Stupid

Se duas soluções resolvem o mesmo problema, escolha a mais simples.

### Exemplo com complexidade desnecessária

```go
type UserRepository interface {
  FindByID(id string) (User, error)
}

type UserService interface {
  GetUser(id string) (User, error)
}

type userService struct {
  repository UserRepository
}

func NewUserService(repository UserRepository) UserService {
  return &userService{repository: repository}
}

func (service *userService) GetUser(id string) (User, error) {
  return service.repository.FindByID(id)
}
```

Isso é uma *pass-through architecture*.
Múltiplos tipos apenas repassando chamada.

### Versão mais simples

```go
type UserService struct {
  repository *UserRepository
}

func NewUserService(repository *UserRepository) *UserService {
  return &UserService{repository: repository}
}

func (service *UserService) GetUser(id string) (User, error) {
  return service.repository.FindByID(id)
}
```

Menos indireção.
Mesma funcionalidade.

### Quando usar interface?

* Múltiplas implementações reais hoje
* Boundary externa (infraestrutura, SDK, integração)
* Isolamento explícito para testes

### Sinais de alerta (KISS)

* Você navega por 3 ou mais tipos para achar uma regra trivial
* Uma mudança simples exige tocar arquivos demais

### Sinais de maturidade (KISS)

* O fluxo principal pode ser explicado em poucos passos
* A leitura revela intenção antes de detalhes técnicos

### Trade-off (KISS)

KISS ajuda quando reduz acoplamento acidental.

KISS atrapalha quando vira simplificação ingênua e ignora requisitos reais (observabilidade, segurança, isolamento de infraestrutura).

---

## YAGNI — You Aren’t Gonna Need It

Não construa extensibilidade antes da variação existir.

### Exemplo de abstração antecipada

```go
type PriceStrategy interface {
  Calculate(base float64) float64
}

type DefaultPriceStrategy struct{}

func (strategy DefaultPriceStrategy) Calculate(base float64) float64 {
  return base
}

type PricingService struct {
  strategy PriceStrategy
}

func NewPricingService(strategy PriceStrategy) *PricingService {
  return &PricingService{strategy: strategy}
}

func (service *PricingService) FinalPrice(base float64) float64 {
  return service.strategy.Calculate(base)
}
```

Se só existe uma regra, isso é especulação arquitetural.

### Versão orientada à necessidade atual

```go
type PricingService struct{}

func (service *PricingService) FinalPrice(base float64) float64 {
  return base
}
```

Quando a segunda regra surgir, a abstração se tornará natural.

### Sinais de alerta (YAGNI)

* “Vamos deixar pronto para quando precisar” sem evidência real
* Abstrações sem segundo caso de uso concreto

### Sinais de maturidade (YAGNI)

* A extensão nasce quando aparece a segunda necessidade real
* Mudanças anteriores são simples e reversíveis

### Trade-off (YAGNI)

YAGNI ajuda quando evita features e pontos de extensão sem demanda.

YAGNI atrapalha quando é usado para adiar obrigações já conhecidas (requisitos legais, contratos públicos estáveis, integrações confirmadas).

---

## DRY — Don’t Repeat Yourself

Elimine duplicação de conhecimento de domínio.

### Regra duplicada

```go
func CreateUser(name, email string) error {
  if name == "" {
    return errors.New("nome é obrigatório")
  }
  if !strings.Contains(email, "@") {
    return errors.New("email inválido")
  }
  return nil
}

func UpdateUser(name, email string) error {
  if name == "" {
    return errors.New("nome é obrigatório")
  }
  if !strings.Contains(email, "@") {
    return errors.New("email inválido")
  }
  return nil
}
```

### Regra centralizada

```go
func ValidateUserInput(name, email string) error {
  if name == "" {
    return errors.New("nome é obrigatório")
  }
  if !strings.Contains(email, "@") {
    return errors.New("email inválido")
  }
  return nil
}

func CreateUser(name, email string) error {
  return ValidateUserInput(name, email)
}

func UpdateUser(name, email string) error {
  return ValidateUserInput(name, email)
}
```

### DRY além do texto

DRY não significa “não repetir nenhuma linha”.

É sobre manter **uma única fonte de verdade para regras de negócio**.

Às vezes repetir pequeno trecho de infraestrutura melhora legibilidade e isolamento.

### Sinais de alerta (DRY)

* Validações equivalentes começam a divergir
* Regras iguais passam a gerar comportamentos inconsistentes

### Sinais de maturidade (DRY)

* Alterações de regra são feitas em um único ponto
* O comportamento permanece previsível em fluxos diferentes

### Trade-off (DRY)

DRY ajuda quando evita divergência semântica.

DRY atrapalha quando força abstrações genéricas cedo demais e reduz clareza local.

---

## Mini-Casos Reais

### Caso 1 — Arquitetura em camadas para CRUD simples

Um serviço interno começou com repository, service, use case, controller e interface para tudo. O domínio era pequeno e sem variações.

Após simplificação (KISS), o time reduziu indireção e o PR médio ficou menor.

O maior ganho não foi “menos código”, mas **mais velocidade para entender impacto de mudança**.

### Caso 2 — Sistema preparado para estratégias inexistentes

Uma API de precificação criou estratégia, fábrica e registrador de plugins sem necessidade real. Durante meses, só existiu um comportamento.

Ao remover abstrações especulativas (YAGNI), o time passou a evoluir com menos risco. Quando a segunda regra chegou, a extensão foi introduzida com contexto concreto e testes focados.

---

## Quebrando Intencionalmente

Princípios não são dogmas.

Às vezes vale:

* Repetir pequeno trecho para melhorar legibilidade
* Criar abstração por exigência contratual
* Aceitar complexidade por performance ou resiliência

O importante é intenção explícita.

---

## Checklist de PR para Times Go

* Consigo explicar essa arquitetura em 1 minuto?
* Existe requisito real para essa abstração?
* A duplicação representa regra de domínio ou conveniência local?
* A solução mais simples já atende?
* Se remover uma camada, algo realmente quebra?

Dica prática: use essa checklist durante a implementação e antes do merge.

---

## Conclusão

KISS reduz peso estrutural.
YAGNI evita investimento prematuro.
DRY protege consistência.

Em Go, isso normalmente resulta em código:

* menor
* mais legível
* previsível
* evolutivo

Arquitetura madura não é sobre quantidade de camadas.

É sobre clareza de intenção.

---

## Referências

* Andrew Hunt e David Thomas — *The Pragmatic Programmer*
* Kent Beck — *Extreme Programming Explained*
* John Ousterhout — *A Philosophy of Software Design*
* Steve McConnell — *Code Complete*
* Effective Go — documentação oficial

---

## Próximo Post

Como decidir o momento certo de introduzir interfaces em Go sem cair em acoplamento acidental.
