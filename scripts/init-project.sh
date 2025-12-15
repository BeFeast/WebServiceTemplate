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

read -p "Subdomain for ${PROJECT_NAME}.oklabs.uk: " PROJECT_SUBDOMAIN
PROJECT_SUBDOMAIN=${PROJECT_SUBDOMAIN:-$PROJECT_NAME}

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
echo "  Subdomain: $PROJECT_SUBDOMAIN.oklabs.uk"
echo "  Backend Port: $BACKEND_PORT"
echo "  Frontend Port: $FRONTEND_PORT"
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

# Find and replace all placeholders in files
find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.md" -o -name "*.sh" -o -name "*.env*" -o -name "Dockerfile*" -o -name "Makefile" \) -exec sed -i '' \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{PROJECT_SUBDOMAIN}}/$PROJECT_SUBDOMAIN/g" \
    -e "s/{{BACKEND_PORT}}/$BACKEND_PORT/g" \
    -e "s/{{FRONTEND_PORT}}/$FRONTEND_PORT/g" \
    -e "s/{{REDIS_DB_NUM}}/$REDIS_DB_NUM/g" \
    -e "s/{{SECRET_KEY}}/$SECRET_KEY/g" \
    -e "s/{{DB_PASS}}/$DB_PASS/g" \
    {} \; 2>/dev/null || true

# Also handle Linux sed (without -i '')
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.md" -o -name "*.sh" -o -name "*.env*" -o -name "Dockerfile*" -o -name "Makefile" \) -exec sed -i \
        -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_SUBDOMAIN}}/$PROJECT_SUBDOMAIN/g" \
        -e "s/{{BACKEND_PORT}}/$BACKEND_PORT/g" \
        -e "s/{{FRONTEND_PORT}}/$FRONTEND_PORT/g" \
        -e "s/{{REDIS_DB_NUM}}/$REDIS_DB_NUM/g" \
        -e "s/{{SECRET_KEY}}/$SECRET_KEY/g" \
        -e "s/{{DB_PASS}}/$DB_PASS/g" \
        {} \;
fi

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

# Setup subdomain?
echo ""
read -p "Setup subdomain ${PROJECT_SUBDOMAIN}.oklabs.uk? [Y/n]: " SETUP_SUBDOMAIN
SETUP_SUBDOMAIN=${SETUP_SUBDOMAIN:-Y}
if [[ "$SETUP_SUBDOMAIN" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running subdomain setup...${NC}"
    ./scripts/setup-subdomain.sh "$PROJECT_SUBDOMAIN" "$FRONTEND_PORT"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Project initialized successfully!     ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Review and update .env file"
echo -e "  2. Run: ${YELLOW}make dev${NC} to start development"
echo -e "  3. Run: ${YELLOW}make deploy${NC} to deploy to DevBox"
echo ""
echo -e "Credentials saved:"
echo -e "  Database Password: ${YELLOW}${DB_PASS}${NC}"
echo -e "  Secret Key: ${YELLOW}${SECRET_KEY:0:16}...${NC}"
