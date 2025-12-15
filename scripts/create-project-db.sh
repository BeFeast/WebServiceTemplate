#!/bin/bash
set -e

# Creates database and user in ok-shared-infra PostgreSQL on DevBox

PROJECT_NAME="${1:?Project name required}"
DB_PASS="${2:?Database password required}"

DEVBOX_HOST="god@10.10.0.13"
POSTGRES_CONTAINER="ok-shared-infra-postgres-1"

echo "Creating database '$PROJECT_NAME' in ok-shared-infra PostgreSQL..."

# Create user and database
ssh "$DEVBOX_HOST" "docker exec $POSTGRES_CONTAINER psql -U postgres -c \"
DO \\\$\\\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$PROJECT_NAME') THEN
        CREATE USER $PROJECT_NAME WITH PASSWORD '$DB_PASS';
    END IF;
END
\\\$\\\$;

SELECT 'User created or already exists' AS status;

DROP DATABASE IF EXISTS $PROJECT_NAME;
CREATE DATABASE $PROJECT_NAME OWNER $PROJECT_NAME;
GRANT ALL PRIVILEGES ON DATABASE $PROJECT_NAME TO $PROJECT_NAME;
\""

echo ""
echo "Database created successfully!"
echo "Connection string:"
echo "  postgresql+asyncpg://${PROJECT_NAME}:${DB_PASS}@10.10.0.13:5432/${PROJECT_NAME}"
