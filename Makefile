# ============================================================================
# Hugo Blog - Makefile
# ============================================================================
# Gerenciamento do ambiente de desenvolvimento do blog Hugo com Docker
# ============================================================================

.PHONY: help build up down restart logs shell clean rebuild status new-post \
	new-draft new-post-pt new-post-en list-content build-prod generate check-deps info watch url \
	dev quick-start quick-stop logs-tail health prune \
	clean-hugo regen check-images

# ============================================================================
# Variáveis
# ============================================================================

COMPOSE_FILE := docker-compose.yml
SERVICE_NAME := blog
CONTAINER_NAME := blog
MELANGE_FILE := melange.yaml
DOCKER_COMPOSE := $(shell if docker compose version >/dev/null 2>&1; then echo "docker compose"; else echo "docker-compose"; fi)


# ============================================================================
# Cores para output
# ============================================================================

RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# ============================================================================
# Default target
# ============================================================================

.DEFAULT_GOAL := help

##@ Ajuda

help: ## Mostra esta mensagem de ajuda
	@echo ""
	@echo -e "$(BLUE)╔══════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(BLUE)║          Hugo Blog - Comandos Disponíveis                ║$(NC)"
	@echo -e "$(BLUE)╚══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Desenvolvimento

build: ## Faz o build da imagem Docker
	@echo -e "$(BLUE)🔨 Building Docker image...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build --no-cache
	@echo -e "$(GREEN)✓ Build concluído!$(NC)"

up: ## Inicia o servidor de desenvolvimento
	@echo -e "$(BLUE)🚀 Iniciando servidor de desenvolvimento...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo -e "$(GREEN)✓ Servidor iniciado!$(NC)"
	@echo -e "$(YELLOW)📝 Blog disponível em: http://localhost:1313$(NC)"

down: ## Para o servidor de desenvolvimento
	@echo -e "$(BLUE)🛑 Parando servidor...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down
	@echo -e "$(GREEN)✓ Servidor parado!$(NC)"

restart: down up ## Reinicia o servidor

logs: ## Mostra os logs do container
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

logs-tail: ## Mostra as últimas 100 linhas dos logs
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs --tail=100 $(SERVICE_NAME)

shell: ## Abre um shell no container
	@echo -e "$(BLUE)🐚 Abrindo shell no container...$(NC)"
	@docker exec -it $(CONTAINER_NAME) sh

##@ Gerenciamento

status: ## Mostra o status dos containers
	@echo -e "$(BLUE)📊 Status dos containers:$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

ls: status ## Alias para status

health: ## Verifica a saúde do container
	@echo -e "$(BLUE)🏥 Verificando saúde do container...$(NC)"
	@docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "Container não está rodando"

rebuild: clean build up ## Reconstrói tudo do zero

clean: ## Remove containers, volumes e imagens
	@echo -e "$(YELLOW)🧹 Limpando ambiente...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v --remove-orphans
	@docker rmi fabianoflorentino/blog:v0.0.1 2>/dev/null || true
	@echo -e "$(GREEN)✓ Ambiente limpo!$(NC)"

clean-hugo: ## Remove artefatos gerados pelo Hugo (public, resources/_gen e lock)
	@echo -e "$(YELLOW)🧹 Limpando artefatos do Hugo...$(NC)"
	@rm -rf public resources/_gen .hugo_build.lock
	@echo -e "$(GREEN)✓ Artefatos removidos!$(NC)"

prune: ## Remove todos os recursos Docker não utilizados (cuidado!)
	@echo -e "$(RED)⚠️  Isso vai remover TODOS os recursos Docker não utilizados!$(NC)"
	@echo -e "$(YELLOW)Pressione Ctrl+C para cancelar, ou Enter para continuar...$(NC)"
	@read confirm
	@docker system prune -af --volumes
	@echo -e "$(GREEN)✓ Limpeza completa!$(NC)"

##@ Conteúdo

new-post: ## Cria um novo post (uso: make new-post TITLE="Meu Post")
	@if [ -z "$(TITLE)" ]; then \
		echo -e "$(RED)❌ Erro: Informe o título do post$(NC)"; \
		echo -e "$(YELLOW)Uso: make new-post TITLE=\"Meu Título\"$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)📝 Criando novo post...$(NC)"
	@docker exec $(CONTAINER_NAME) hugo new posts/$(shell echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | tr ' ' '_').md
	@echo -e "$(GREEN)✓ Post criado!$(NC)"

new-post-pt: ## Cria um novo post em PT (uso: make new-post-pt TITLE="..." [KEY="..."])
	@if [ -z "$(TITLE)" ]; then \
		echo -e "$(RED)❌ Erro: Informe o título do post$(NC)"; \
		echo -e "$(YELLOW)Uso: make new-post-pt TITLE=\"Meu Título\" [KEY=\"minha-chave\"]$(NC)"; \
		exit 1; \
	fi
	@key="$(KEY)"; \
	if [ -z "$$key" ]; then \
		key=$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$$//'); \
	fi; \
	file="content/posts/$${key}.pt.md"; \
	echo -e "$(BLUE)📝 Criando novo post (pt): $${key}...$(NC)"; \
	docker exec $(CONTAINER_NAME) hugo new "posts/$${key}.pt.md"; \
	if [ -f "$$file" ] && ! grep -q '^translationKey:' "$$file"; then \
		sed -i "/^title:/a translationKey: $${key}" "$$file"; \
	fi; \
	echo -e "$(GREEN)✓ Post criado: $$file$(NC)"

new-post-en: ## Cria um novo post em EN (uso: make new-post-en TITLE="..." [KEY="..."])
	@if [ -z "$(TITLE)" ]; then \
		echo -e "$(RED)❌ Erro: Informe o título do post$(NC)"; \
		echo -e "$(YELLOW)Uso: make new-post-en TITLE=\"My Title\" [KEY=\"my-key\"]$(NC)"; \
		exit 1; \
	fi
	@key="$(KEY)"; \
	if [ -z "$$key" ]; then \
		key=$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$$//'); \
	fi; \
	file="content/posts/$${key}.en.md"; \
	echo -e "$(BLUE)📝 Criando novo post (en): $${key}...$(NC)"; \
	docker exec $(CONTAINER_NAME) hugo new "posts/$${key}.en.md"; \
	if [ -f "$$file" ] && ! grep -q '^translationKey:' "$$file"; then \
		sed -i "/^title:/a translationKey: $${key}" "$$file"; \
	fi; \
	echo -e "$(GREEN)✓ Post criado: $$file$(NC)"

new-draft: ## Cria um novo draft (uso: make new-draft TITLE="Meu Draft")
	@if [ -z "$(TITLE)" ]; then \
		echo -e "$(RED)❌ Erro: Informe o título do draft$(NC)"; \
		echo -e "$(YELLOW)Uso: make new-draft TITLE=\"Meu Título\"$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)📝 Criando novo draft...$(NC)"
	@docker exec $(CONTAINER_NAME) hugo new --kind post-bundle posts/$(shell echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
	@echo -e "$(GREEN)✓ Draft criado!$(NC)"

list-content: ## Lista todo o conteúdo do blog
	@echo -e "$(BLUE)📋 Conteúdo do blog:$(NC)"
	@docker exec $(CONTAINER_NAME) hugo list all

##@ Produção

build-prod: ## Faz build da imagem de produção
	@echo -e "$(BLUE)🔨 Building production image...$(NC)"
	@docker build --target production -t fabianoflorentino/blog:v0.0.1-prod .
	@echo -e "$(GREEN)✓ Build de produção concluído!$(NC)"

generate: ## Gera os arquivos estáticos do site
	@echo -e "$(BLUE)🏗️  Gerando site estático...$(NC)"
	@docker exec $(CONTAINER_NAME) hugo
	@echo -e "$(GREEN)✓ Site gerado em ./public$(NC)"

regen: clean-hugo generate ## Limpa e gera novamente o site (do zero)

check-images: ## Verifica se arquivos referenciados em /images existem em static/
	@echo -e "$(BLUE)🔎 Verificando referências de imagens...$(NC)"
	@missing=0; \
	paths=$$( ( \
		grep -RhoE '^image:\s*/images/[^[:space:]]+' hugo.yaml content 2>/dev/null | sed -E 's/^image:\s*//' ; \
		grep -RhoE '/images/[^\)\"\x27[:space:]]+' content 2>/dev/null \
	) | sort -u ); \
	if [ -z "$$paths" ]; then \
		echo -e "$(YELLOW)⚠️  Nenhuma referência /images encontrada$(NC)"; \
		exit 0; \
	fi; \
	for p in $$paths; do \
		f="static$${p}"; \
		if [ ! -f "$$f" ]; then \
			echo -e "$(RED)❌ Missing: $$p  (esperado: $$f)$(NC)"; \
			missing=1; \
		fi; \
	done; \
	if [ $$missing -ne 0 ]; then \
		echo -e "$(RED)Falha: existem referências de imagem quebradas.$(NC)"; \
		exit 1; \
	fi; \
	echo -e "$(GREEN)✓ Todas as imagens referenciadas existem em static/$(NC)"

##@ Utilitários

check-deps: ## Verifica se as dependências estão instaladas
	@echo -e "$(BLUE)🔍 Verificando dependências...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)❌ Docker não instalado$(NC)"; exit 1; }
	@docker compose version >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)❌ Docker Compose não instalado$(NC)"; exit 1; }
	@echo -e "$(GREEN)✓ Todas as dependências instaladas!$(NC)"

info: ## Mostra informações do ambiente
	@echo -e "$(BLUE)ℹ️  Informações do ambiente:$(NC)"
	@echo -e "$(YELLOW)Docker version:$(NC)"
	@docker --version
	@echo -e "$(YELLOW)Docker Compose version:$(NC)"
	@$(DOCKER_COMPOSE) version 2>/dev/null || $(DOCKER_COMPOSE) --version
	@echo -e "$(YELLOW)Imagens Hugo:$(NC)"
	@docker images | grep blog || echo "Nenhuma imagem encontrada"

watch: ## Monitora mudanças nos arquivos e mostra logs
	@echo -e "$(BLUE)👀 Monitorando mudanças...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

url: ## Mostra a URL do blog
	@echo -e "$(GREEN)🌐 Blog disponível em: http://localhost:1313$(NC)"

##@ Desenvolvimento Rápido

dev: check-deps build up logs ## Inicia ambiente completo de desenvolvimento

quick-start: up url ## Inicia rapidamente (sem rebuild)

quick-stop: down ## Para rapidamente

##@ Build Moderno (Melange + Apko)

melange-build: ## Builda o pacote APK do site
	@echo "📦 Building site package with melange"
	melange build $(MELANGE_FILE) --arch amd64


apko-build: ## Gera imagem OCI final com apko
	@echo "📦 Building OCI image with apko"
	apko build apko.yaml blog:prod blog.tar


apko-load: ## Carrega a imagem no Docker (opcional)
	docker load < blog.tar
