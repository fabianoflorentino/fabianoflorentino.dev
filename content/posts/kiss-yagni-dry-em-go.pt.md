---
date: '2026-03-02T21:13:45Z'
draft: false
title: 'KISS, YAGNI e DRY em Go: quando simplificar, quando adiar e quando abstrair'
translationKey: kiss-yagni-dry-em-go
tags: [post, go, arquitetura, design, principios, kiss, yagni, dry]
image: /images/kiss-yagni-dry-go.jpg
---

## KISS, YAGNI e DRY em Go

Assim como o SOLID organiza princípios voltados para orientação a objetos, **KISS, YAGNI e DRY ajudam a guiar decisões arquiteturais no dia a dia**.

Eles não definem estrutura por si só. Eles ajudam a orientar postura e tomada de decisão.

Neste post, compartilho o que venho aprendendo sobre boas práticas de design e arquitetura, especialmente em Go.

Em Go — uma linguagem projetada para simplicidade, clareza e composição — esses princípios ficam mais evidentes na prática.

Aqui, a proposta é explorarmos juntos:

* A origem conceitual desses princípios
* Um mapa rápido de decisão para o dia a dia
* Exemplos práticos em Go
* Sinais de maturidade e de alerta
* Trade-offs reais

---

## Mapa Rápido de Decisão

Antes dos exemplos, um resumo para usar no dia a dia:

|Princípio|Pergunta-chave|Objetivo prático|Anti-padrão comum|
|---|---|---|---|
|**KISS**|Há uma forma mais simples de resolver isso?|Reduzir complexidade acidental|Camadas “pass-through”|
|**YAGNI**|Isso resolve um problema real de hoje?|Evitar investimento prematuro|Extensibilidade hipotética|
|**DRY**|A mesma regra de domínio está repetida?|Preservar consistência|Abstração genérica cedo demais|

Lembre que esses princípios não são regras rígidas, mas guias para reflexão. O contexto sempre importa.

> **KISS simplifica a estrutura. YAGNI protege o tempo. DRY protege o conhecimento.**

---

## Contexto Histórico

### KISS — “Keep It Simple, Stupid”

O princípio KISS surgiu na engenharia militar nos anos 1960, associado ao design de sistemas da Marinha dos Estados Unidos ([fonte](https://en.wikipedia.org/wiki/KISS_principle)).

A ideia central era simples:

> Sistemas simples falham menos.

Na engenharia de software, isso significa reduzir complexidade desnecessária.

---

### YAGNI — “You Aren’t Gonna Need It”

YAGNI ganhou força dentro do movimento Extreme Programming (XP) nos anos 1990 ([fonte](https://martinfowler.com/bliki/Yagni.html)).

A proposta era direta:

> Não implemente hoje algo que ainda não é requisito real.

Antecipação excessiva gera desperdício.

---

### DRY — “Don’t Repeat Yourself”

DRY foi formalizado no livro *The Pragmatic Programmer* ([fonte](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)).

A definição mais precisa é:

> Cada pedaço de conhecimento deve ter uma única representação no sistema.

Não é sobre repetir código. É sobre repetir regra de negócio.

---

## O Problema: Complexidade Acidental

Arquitetura é sobre trade-offs — e isso fica mais claro com a prática.

Quando exageramos na abstração, geralmente pagamos com:

* excesso de tipos
* indireção desnecessária
* dificuldade de debug
* onboarding mais lento

Go foi desenhada para reduzir fricção estrutural. Quando ignoramos isso, acabamos criando **complexidade acidental**.

---

## KISS — Keep It Simple, Stupid

Se duas soluções resolvem o mesmo problema, a mais simples costuma ser a melhor escolha.

### Exemplo com complexidade desnecessária

```go
// Repositório genérico, pensando em múltiplas fontes de dados
type UserRepository interface {
    FindByID(id string) (User, error)
}

// Implementação atual, sem variações reais
type UserService interface {
    GetUser(id string) (User, error)
}

// Implementação concreta, apenas repassando chamada
type userService struct {
    repository UserRepository
}

// Hoje só existe uma implementação real, mas já criamos interface e estrutura
func NewUserService(repository UserRepository) UserService {
    return &userService{repository: repository}
}

// Método que só repassa chamada, sem lógica adicional
func (service *userService) GetUser(id string) (User, error) {
    return service.repository.FindByID(id)
}
```

Isso é uma *pass-through architecture*, múltiplos tipos apenas repassando chamada.

### Versão mais simples

```go
// Implementação direta, sem abstração desnecessária
type UserRepository struct{}

// Hoje só existe uma implementação real, sem interface genérica
func (repository *UserRepository) FindByID(id string) (User, error) {
    // ...consulta...
    return User{}, nil
}

// Serviço direto, sem interface genérica
type UserService struct {
    repository *UserRepository
}

// Método direto, sem repassar chamada
func NewUserService(repository *UserRepository) *UserService {
    return &UserService{repository: repository}
}

// Método direto, sem lógica adicional
func (service *UserService) GetUser(id string) (User, error) {
    return service.repository.FindByID(id)
}
```

Menos indireção, mesma funcionalidade.

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

KISS ajuda quando reduz acoplamento acidental, porém, atrapalha quando vira simplificação ingênua e ignora requisitos reais (observabilidade, segurança, isolamento de infraestrutura).

---

## YAGNI — You Aren’t Gonna Need It

Um aprendizado recorrente: não construir soluções para problemas que ainda não existem.

### Exemplo de abstração antecipada

```go
// Estratégia de precificação, pensando em variações futuras
type PriceStrategy interface {
    Calculate(base float64) float64
}

// Implementação atual, sem variações reais
type DefaultPriceStrategy struct{}

// Hoje só existe uma forma de calcular preço, mas já criamos a interface e a estrutura
func (DefaultPriceStrategy) Calculate(base float64) float64 {
    return base
}

// Imaginando uma variação futura, mas sem cenário concreto
type BlackFridayStrategy struct{}

// Implementação hipotética, sem evidência de necessidade real
func (BlackFridayStrategy) Calculate(base float64) float64 {
    return base * 0.7
}
```

Se hoje só existe um comportamento real, essa estrutura pode ser prematura.

### Versão mais pragmática

```go
// Implementação direta, sem abstração antecipada
func CalculatePrice(base float64) float64 {
    return base
}
```

Quando surgir uma segunda variação real e estável, aí sim pode valer extrair estratégia.

### Sinais de alerta (YAGNI)

* "Vamos preparar para o futuro" sem cenário concreto
* Muitos pontos de uso hipotético, mas nenhum real

### Sinais de maturidade (YAGNI)

* Código evolui em pequenas iterações
* Extensões surgem a partir de requisitos observados

### Trade-off (YAGNI)

YAGNI evita desperdício. Mal aplicado pode virar miopia: ignorar requisitos já sinalizados por negócio ou contrato externo.

---

## DRY — Don’t Repeat Yourself

DRY não é "nunca repetir linhas", é evitar duplicar a mesma regra de domínio em lugares diferentes.

### Exemplo com regra duplicada

```go
// Regras de validação de senha, repetidas em dois pontos
func CreateUser(input CreateUserInput) error {
    if len(input.Password) < 8 {
        return errors.New("senha deve ter no mínimo 8 caracteres")
    }
    // ...criação...
    return nil
}

// Mesma regra repetida, mas em outro contexto
func ResetPassword(input ResetPasswordInput) error {
    if len(input.Password) < 8 {
        return errors.New("senha deve ter no mínimo 8 caracteres")
    }
    // ...reset...
    return nil
}
```

A regra de domínio está repetida.

### Versão com regra centralizada

```go
// Função centralizada para validar senha
func ValidatePassword(password string) error {
    if len(password) < 8 {
        return errors.New("senha deve ter no mínimo 8 caracteres")
    }
    return nil
}

// Regras de validação de senha, usando função centralizada
func CreateUser(input CreateUserInput) error {
    if err := ValidatePassword(input.Password); err != nil {
        return err
    }
    // ...criação...
    return nil
}

// Mesma regra reutilizada, sem duplicação
func ResetPassword(input ResetPasswordInput) error {
    if err := ValidatePassword(input.Password); err != nil {
        return err
    }
    // ...reset...
    return nil
}
```

Agora a regra tem um único ponto de manutenção.

### Sinais de alerta (DRY)

* Mesma regra copiada em handlers, services e jobs
* Bug corrigido em um ponto, mas esquecido em outro

### Sinais de maturidade (DRY)

* Regras centrais em funções/módulos coesos
* Nomes refletem intenção de domínio, não detalhe técnico

### Trade-off (DRY)

DRY preserva consistência, cedo demais pode gerar abstrações genéricas ruins e aumentar acoplamento entre contextos que deveriam ser separados.

---

## Como equilibrar KISS, YAGNI e DRY no dia a dia

Como podemos usar esses princípios de forma prática, sem cair em dogmas ou armadilhas de implementação?

1. **Comece simples (KISS)**
2. **Implemente só o que é necessário agora (YAGNI)**
3. **Quando a regra se repetir de verdade, consolide (DRY)**

Se houver dúvida, vale perguntar:

* Essa abstração remove complexidade real ou só desloca complexidade? ([fonte](https://www.oreilly.com/library/view/a-philosophy-of/9781491924136/))
* Existe evidência de variação agora ou é hipótese? ([fonte](https://martinfowler.com/bliki/Yagni.html))
* Estou centralizando conhecimento ou acoplando coisas diferentes? ([fonte](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction))


---

## Conclusão

KISS, YAGNI e DRY não competem entre si.
Eles se complementam.

Com o tempo, o padrão fica mais claro:

* **KISS** reduz complexidade acidental
* **YAGNI** evita investimento prematuro
* **DRY** protege consistência do domínio

Em Go, esses princípios aparecem com força porque a linguagem favorece clareza e composição.
E, na prática, o aprendizado é contínuo: menos sobre seguir dogmas, mais sobre fazer boas escolhas de trade-off no contexto certo.
