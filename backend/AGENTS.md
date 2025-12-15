# AGENTS.md - Backend (FastAPI)

## Package Identity
- **Purpose**: REST API backend with async PostgreSQL and Redis
- **Framework**: FastAPI + SQLAlchemy 2.0 async + Pydantic v2
- **Package Manager**: uv (Astral)

## Setup & Run
```bash
# Install dependencies
cd backend && uv sync

# Run dev server (from project root)
make dev-backend
# Or directly:
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Run tests
uv run pytest -v

# Lint & format
uv run ruff check .
uv run ruff format .

# Type check
uv run mypy app/

# Database migrations
uv run alembic upgrade head
uv run alembic revision --autogenerate -m "description"
```

## Patterns & Conventions

### File Organization
```
app/
├── api/           # Route handlers (one file per resource)
│   ├── __init__.py  # Router aggregation
│   ├── auth.py      # Auth endpoints
│   └── health.py    # Health check
├── core/          # Application core
│   ├── config.py    # Settings (Pydantic BaseSettings)
│   ├── database.py  # Async session factory
│   ├── deps.py      # FastAPI dependencies
│   └── security.py  # JWT, password hashing
├── models/        # SQLAlchemy ORM models
├── schemas/       # Pydantic request/response schemas
└── services/      # Business logic (DB operations)
```

### Patterns to Follow
- ✅ **Routes**: Copy pattern from `app/api/health.py`
- ✅ **Models**: Copy pattern from `app/models/user.py`
- ✅ **Schemas**: Copy pattern from `app/schemas/user.py`
- ✅ **Services**: Copy pattern from `app/services/user.py`
- ✅ **Dependencies**: Use `DBSession` and `CurrentUser` from `app/core/deps.py`

### Naming Conventions
- **Files**: `snake_case.py`
- **Classes**: `PascalCase` (models, schemas)
- **Functions**: `snake_case` (routes, services)
- **Routes**: Use plural nouns (`/users`, `/items`)

### Anti-Patterns
- ❌ **DON'T** put business logic in route handlers
- ❌ **DON'T** use sync database operations
- ❌ **DON'T** hardcode secrets (use `settings.SECRET_KEY`)
- ❌ **DON'T** return SQLAlchemy models directly (use Pydantic schemas)

## Touch Points / Key Files
```
app/main.py           # FastAPI app, middleware, lifespan
app/core/config.py    # All settings (env vars)
app/core/database.py  # DB session, Base class
app/core/deps.py      # Reusable dependencies (DBSession, CurrentUser)
app/core/security.py  # JWT creation, password hashing
pyproject.toml        # Dependencies, tool config
alembic/env.py        # Migration config
```

## JIT Index Hints
```bash
# Find all route handlers
rg -n "^@router\.(get|post|put|delete)" app/api/

# Find all models
rg -n "class \w+\(Base\)" app/models/

# Find all schemas
rg -n "class \w+\(BaseModel\)" app/schemas/

# Find service functions
rg -n "^async def" app/services/

# Find settings usage
rg -n "settings\.\w+" app/

# Find dependencies
rg -n "Depends\(" app/
```

## Common Gotchas
- Database URL must use `postgresql+asyncpg://` for async
- Always use `async with` for database sessions
- Alembic needs models imported in `alembic/env.py`
- Redis DB number (0-15) is per-project in shared instance

## Pre-PR Checks
```bash
cd backend && uv run ruff check . && uv run ruff format --check . && uv run pytest -v
```

## Bug Fix Protocol (MANDATORY)
1. **Reproduce**: Run failing test first
2. **Fix**: Implement solution
3. **Verify**: Run `uv run pytest -v` and **paste output**
4. **Report**: Show test results proving fix works

**NEVER say "it should work" - PROVE it with test output**
