# {{PROJECT_NAME}}

Full-stack web application built with FastAPI and Next.js for DevBox deployment.

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | FastAPI + SQLAlchemy 2.0 async + uv |
| **Frontend** | Next.js 14 + TypeScript + bun |
| **Styling** | Tailwind CSS + shadcn/ui |
| **State** | TanStack Query + React Context |
| **Forms** | React Hook Form + Zod |
| **Testing** | pytest + Playwright |
| **Database** | PostgreSQL 18 (ok-shared-infra) |
| **Cache** | Redis 7 (ok-shared-infra) |

## Quick Start

### 1. Initialize Project

```bash
# Clone and initialize from template
./scripts/init-project.sh
```

This will:
- Prompt for project configuration
- Replace all placeholders
- Create database in ok-shared-infra
- Setup subdomain (optional)

### 2. Development

```bash
# Start full stack with Docker
make dev

# Or start individually:
make dev-backend   # Backend at http://localhost:8000
make dev-frontend  # Frontend at http://localhost:3000
```

### 3. Deploy to DevBox

```bash
make deploy
```

## Directory Structure

```
{{PROJECT_NAME}}/
├── .devcontainer/     # VS Code remote development
├── backend/           # FastAPI application
│   ├── app/
│   │   ├── api/       # Route handlers
│   │   ├── core/      # Config, security, deps
│   │   ├── models/    # SQLAlchemy models
│   │   ├── schemas/   # Pydantic schemas
│   │   └── services/  # Business logic
│   └── pyproject.toml
├── frontend/          # Next.js application
│   ├── src/
│   │   ├── app/       # App Router pages
│   │   ├── components/# React components
│   │   └── lib/       # Utilities, API client
│   └── package.json
├── docker/            # Docker configurations
├── scripts/           # Automation scripts
└── Makefile
```

## Development Access

| Method | Target | Use Case |
|--------|--------|----------|
| SSH + VS Code Remote | `god@10.10.0.13:/opt/projects/{{PROJECT_NAME}}` | Direct dev on DevBox |
| SMB Mount | `smb://god@10.10.0.13/DevBox` | Local edit, remote Docker |
| code-server | `https://code.oklabs.uk` | Browser-based |

## Commands

```bash
make help          # Show all commands
make dev           # Start development environment
make test          # Run all tests
make lint          # Run linters
make deploy        # Deploy to DevBox
make db-migrate    # Run database migrations
make clean         # Clean build artifacts
```

## Environment Variables

Copy `docker/.env.example` to `.env` and configure:

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `SECRET_KEY` | JWT secret key |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |

## Infrastructure

- **Development**: `/opt/projects/{{PROJECT_NAME}}/`
- **Deployment**: `/opt/stacks/{{PROJECT_NAME}}/`
- **Database**: ok-shared-infra PostgreSQL (10.10.0.13:5432)
- **Cache**: ok-shared-infra Redis (10.10.0.13:6379)
- **URL**: https://{{PROJECT_SUBDOMAIN}}.oklabs.uk
