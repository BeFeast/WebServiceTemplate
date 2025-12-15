.PHONY: help init dev dev-backend dev-frontend build deploy test lint clean

# Default target
help:
	@echo "{{PROJECT_NAME}} - Available commands:"
	@echo ""
	@echo "  init          Initialize project (replace placeholders, setup DB)"
	@echo "  dev           Start development environment (docker-compose)"
	@echo "  dev-backend   Start backend only (uvicorn with hot reload)"
	@echo "  dev-frontend  Start frontend only (next dev)"
	@echo "  build         Build Docker images"
	@echo "  deploy        Deploy to DevBox via Portainer"
	@echo "  test          Run all tests"
	@echo "  test-backend  Run backend tests (pytest)"
	@echo "  test-frontend Run frontend tests (playwright)"
	@echo "  lint          Run linters"
	@echo "  clean         Clean build artifacts"
	@echo ""

# Initialize project from template
init:
	@./scripts/init-project.sh

# Development
dev:
	cd docker && docker compose -f docker-compose.dev.yml up --build

dev-backend:
	cd backend && uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

dev-frontend:
	cd frontend && bun run dev

# Build
build:
	cd docker && docker compose build

build-backend:
	cd backend && docker build -t {{PROJECT_NAME}}-backend .

build-frontend:
	cd frontend && docker build -t {{PROJECT_NAME}}-frontend .

# Deploy
deploy:
	@./scripts/deploy-to-devbox.sh

# Testing
test: test-backend test-frontend

test-backend:
	cd backend && uv run pytest -v --cov=app

test-frontend:
	cd frontend && bun run test

# Linting
lint: lint-backend lint-frontend

lint-backend:
	cd backend && uv run ruff check . && uv run ruff format --check .

lint-frontend:
	cd frontend && bun run lint && bun run typecheck

format:
	cd backend && uv run ruff format .
	cd frontend && bun run prettier --write .

# Database
db-migrate:
	cd backend && uv run alembic upgrade head

db-revision:
	cd backend && uv run alembic revision --autogenerate -m "$(msg)"

db-setup:
	@./scripts/create-project-db.sh {{PROJECT_NAME}}

# Clean
clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .next -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name node_modules -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .venv -exec rm -rf {} + 2>/dev/null || true

# Install dependencies
install:
	cd backend && uv sync
	cd frontend && bun install
