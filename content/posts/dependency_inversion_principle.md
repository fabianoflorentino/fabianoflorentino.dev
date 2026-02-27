---
date: '2026-02-26T15:33:49Z'
draft: false
title: 'Dependency Inversion Principle'
tags: [post, go, arquitetura, solid, dip]
series: SOLID
image: /images/DIP.jpg
---

Este post é parte 5 de uma série sobre SOLID. Acompanhe os outros artigos pela tag [/solid](https://fabianoflorentino.dev/tags/solid/).

## Dependency Inversion Principle

O **Dependency Inversion Principle (DIP)** é o último princípio do SOLID — e talvez o mais desafiador quando falamos de arquitetura.

> Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de abstrações.
> Abstrações não devem depender de detalhes. Detalhes devem depender de abstrações.

À primeira vista parece apenas mais um princípio sobre interfaces. Mas o que ele realmente tenta resolver é algo mais profundo: **proteger o que é estável (regra de negócio) do que é volátil (infraestrutura)**.

---

## Entendendo alto nível vs baixo nível

* **Alto nível** → regra de negócio (use cases, domínio)
* **Baixo nível** → banco de dados, HTTP, fila, arquivo, framework
* **Abstração** → em Go, geralmente uma interface

Tradicionalmente, sistemas eram estruturados assim:

```txt
UserService → Banco de dados
```

A regra de negócio dependia diretamente da tecnologia.

O DIP propõe inverter essa direção:

```txt
UserService → Interface ← Banco de dados
```

A infraestrutura passa a depender do domínio de alto nível, e o domínio depende de uma abstração. Essa é a “inversão”.

---

## Estrutura tradicional

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

## O que DIP tenta resolver

* O domínio depende diretamente do banco
* Testar exige infraestrutura
* Trocar o banco de dados por outro banco quebra código
* Regra de negócio acoplada à implementação

Aqui o módulo de alto nível (`UserService`) depende diretamente do módulo de baixo nível (`sql.DB`).

O problema não é apenas acoplamento. O problema é depender de algo **menos estável** do que sua regra de negócio. Banco muda, framework muda, driver muda.

Regra de negócio deveria mudar menos.

---

## Aplicando o DIP

### Criamos uma abstração

```go
type UserRepository interface {
    Save(name string) error
}
```

Criamos uma abstração que representa *o que* precisa ser feito — salvar usuário — sem dizer *como*.

### O serviço depende da abstração

```go
type UserService struct {
    repo UserRepository
}

func (s *UserService) Create(name string) error {
    return s.repo.Save(name)
}
```

Agora o domínio não sabe, se é Postgres, MongoDB, memória, API externa. Ele só sabe que existe algo que salva usuários.

Ele depende de algo mais estável do que um driver de banco.

---

### A infraestrutura depende da abstração

```go
type PostgresUserRepository struct {
    db *sql.DB
}

func (r *PostgresUserRepository) Save(name string) error {
    _, err := r.db.Exec("INSERT INTO users (name) VALUES ($1)", name)
    return err
}
```

Agora, o detalhe depende da abstração, domínio depende da abstração, domínio não depende do detalhe. Isso é inversão que DIP propõe.

---

### Testando

```go
type InMemoryUserRepository struct {
    users []string
}

func (r *InMemoryUserRepository) Save(name string) error {
    r.users = append(r.users, name)
    return nil
}
```

Agora conseguimos testar regra de negócio sem qualquer depêndencia externa. Esse é um dos maiores ganhos do DIP: **testabilidade e isolamento do domínio**.

---

## DIP não é sobre “usar interface para tudo”

Um erro comum é achar que DIP significa:

> "Sempre criar uma interface"

Não.

DIP é sobre **direção da dependência** e sobre **depender de algo mais estável**.

Você cria abstrações quando, existe dependência externa, existe variação prevista e você quer proteger algo importante. Criar interface para tudo gera complexidade desnecessária e overengineering. Não é dogma. É estratégia.

---

## DIP em Go

Go torna o DIP natural porque, interfaces são implícitas, são pequenas, são orientadas a comportamento e são definidas onde são usadas Uma prática poderosa em Go é:

> Definir a interface onde ela é usada, não onde ela é implementada.

Isso mantém o domínio no controle das suas próprias dependências.

---

## Conclusão

O DIP protege sua regra de negócio da infraestrutura. Ele garante que seu domínio dependa de algo mais estável do que um banco de dados, um framework ou uma API externa. Ele promove testabilidade, flexibilidade e isolamento do domínio.

> Seu domínio não deve saber que o mundo lá fora existe.

Mas não transforme isso em dogma. Se não há instabilidade, não há variação, não há risco — talvez você não precise de abstração ainda.

Quando precisar, refatore.

Se você acompanhou a série até aqui, agora você não tem apenas cinco princípios — você tem uma lente arquitetural para tomar decisões com mais clareza, menos acoplamento e muito mais previsibilidade.

E isso, no mundo real, faz diferença.

---

## Referencias

* [Wikipedia](https://pt.wikipedia.org/wiki/Princ%C3%ADpio_da_invers%C3%A3o_de_depend%C3%AAncia)
* [Object Mentor](http://objectmentor.com/resources/articles/dip.pdf)
* [Blog cleancoder](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html)
