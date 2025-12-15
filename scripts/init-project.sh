#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Service Template Project Initializer  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get project configuration
read -p "Project name (lowercase, no spaces): " PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

read -p "Backend port [8000]: " BACKEND_PORT
BACKEND_PORT=${BACKEND_PORT:-8000}

read -p "Frontend port [3000]: " FRONTEND_PORT
FRONTEND_PORT=${FRONTEND_PORT:-3000}

read -p "Redis DB number (0-15) [1]: " REDIS_DB_NUM
REDIS_DB_NUM=${REDIS_DB_NUM:-1}

# Generate secrets
SECRET_KEY=$(openssl rand -hex 32)
DB_PASS=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Project Name: $PROJECT_NAME"
echo "  Frontend URL: https://${PROJECT_NAME}.oklabs.uk (port $FRONTEND_PORT)"
echo "  Backend URL:  https://${PROJECT_NAME}-api.oklabs.uk (port $BACKEND_PORT)"
echo "  Redis DB: $REDIS_DB_NUM"
echo ""

read -p "Continue with these settings? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo -e "${GREEN}Replacing placeholders...${NC}"

# Find and replace all placeholders in files (Linux sed)
find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.md" -o -name "*.sh" -o -name "*.env*" -o -name "Dockerfile*" -o -name "Makefile" \) \
    -not -path "./.git/*" \
    -exec sed -i \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{BACKEND_PORT}}/$BACKEND_PORT/g" \
    -e "s/{{FRONTEND_PORT}}/$FRONTEND_PORT/g" \
    -e "s/{{REDIS_DB_NUM}}/$REDIS_DB_NUM/g" \
    -e "s/{{SECRET_KEY}}/$SECRET_KEY/g" \
    -e "s/{{DB_PASS}}/$DB_PASS/g" \
    {} \;

# Create .env file from example
cp docker/.env.example .env

echo -e "${GREEN}Creating environment file...${NC}"

# Setup database in ok-shared-infra?
echo ""
read -p "Create database in ok-shared-infra PostgreSQL? [Y/n]: " CREATE_DB
CREATE_DB=${CREATE_DB:-Y}
if [[ "$CREATE_DB" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running database setup...${NC}"
    ./scripts/create-project-db.sh "$PROJECT_NAME" "$DB_PASS"
fi

# Setup NPM proxy hosts?
echo ""
read -p "Setup NPM proxy hosts for ${PROJECT_NAME}.oklabs.uk? [Y/n]: " SETUP_NPM
SETUP_NPM=${SETUP_NPM:-Y}
if [[ "$SETUP_NPM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setting up NPM proxy hosts...${NC}"
    ./scripts/setup-npm-hosts.sh "$PROJECT_NAME" "$FRONTEND_PORT" "$BACKEND_PORT"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Project initialized successfully!     ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Access URLs:"
echo -e "  Frontend: ${YELLOW}https://${PROJECT_NAME}.oklabs.uk${NC}"
echo -e "  Backend:  ${YELLOW}https://${PROJECT_NAME}-api.oklabs.uk${NC}"
echo -e "  API Docs: ${YELLOW}https://${PROJECT_NAME}-api.oklabs.uk/docs${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Run: ${YELLOW}/dev-run${NC} to start development servers"
echo -e "  2. Run: ${YELLOW}/dev-deploy${NC} to deploy Docker stack"
echo ""
echo -e "Credentials saved in .env:"
echo -e "  Database Password: ${YELLOW}${DB_PASS}${NC}"
echo -e "  Secret Key: ${YELLOW}${SECRET_KEY:0:16}...${NC}"
