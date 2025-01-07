#!/bin/bash

set -e
set -u

function create_user_and_database() {
  local db="${1:-postgres}"
  local DB=$(printf '%s\n' "$db" | awk '{ print toupper($0) }')
  local user="${2:-postgres}"
  local password="${3:-password}"
  local schemas="${4:-""}"

  echo "  Creating database '$db' with owner '$user'"

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${POSTGRES_DB:-postgres}" <<-EOSQL
    SELECT 'CREATE ROLE $user WITH CREATEROLE LOGIN PASSWORD ''$password'''
    WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$user')\gexec
    SELECT 'CREATE DATABASE "$db" WITH OWNER $user'
    WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_database WHERE datname = '$db')\gexec
    BEGIN TRANSACTION;
    -- with grant option makes the user able to grant permissions to other users
    GRANT ALL PRIVILEGES ON DATABASE "$db" TO "${user}" WITH GRANT OPTION;
    -- This will set the default privileges for the user to future objects created,
    -- with grant option to make the user able to grant permissions to other users
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON SCHEMAS TO "${user}" WITH GRANT OPTION;
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON TABLES TO "${user}" WITH GRANT OPTION;
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON TYPES TO "${user}" WITH GRANT OPTION;
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON SEQUENCES TO "${user}" WITH GRANT OPTION;
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON FUNCTIONS TO "${user}" WITH GRANT OPTION;
    ALTER DEFAULT PRIVILEGES GRANT ALL PRIVILEGES ON ROUTINES TO "${user}" WITH GRANT OPTION;
    COMMIT TRANSACTION;
EOSQL
  echo "Database '$db' created"

  if [ -n "${schemas}" ]; then
    echo "  Creating schema(s) '$schemas' in database '$db'"
    for schema in $(echo "${schemas}" | tr ',' ' '); do
      local DB=$(printf '%s\n' "$db" | awk '{ print toupper($0) }')
      local SCHEMA=$(printf '%s\n' "$schema" | awk '{ print toupper($0) }')
      local schema_user="POSTGRES_${DB}_${SCHEMA}_USER"
      local def_schema_user="${db}_${schema}_admin"
      local schema_password="POSTGRES_${DB}_${SCHEMA}_PASSWORD"
      local def_schema_password="password"

      # Create schemas and schema users
      echo "  Creating schema '$schema' for database '$db' with authorization for '${!schema_user:-$def_schema_user}'"
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" $db <<-EOSQL
      BEGIN TRANSACTION;
      SELECT 'CREATE ROLE "${!schema_user:-$def_schema_user}" WITH LOGIN PASSWORD ''${!schema_password:-$def_schema_password}'''
      WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${!schema_user:-$def_schema_user}')\gexec
      
      GRANT "${!schema_user:-$def_schema_user}" TO "${user}" WITH ADMIN OPTION;

      GRANT ALL PRIVILEGES ON DATABASE "$db" TO "${!schema_user:-$def_schema_user}";

      CREATE SCHEMA IF NOT EXISTS "$schema" AUTHORIZATION "${!schema_user:-$def_schema_user}";
      ALTER ROLE "${!schema_user:-$def_schema_user}" SET search_path TO "$schema", public;
      ALTER SCHEMA "$schema" OWNER TO "${!schema_user:-$def_schema_user}";
      COMMIT TRANSACTION;
EOSQL
    done
  fi

}

if [ -n "${POSTGRES_MULTIPLE_DB:-}" ]; then
  echo "Creating databases(s): ${POSTGRES_MULTIPLE_DB:-}"
  dbs=$(echo "${POSTGRES_MULTIPLE_DB:-}" | tr ',' ' ')
  for db in $dbs; do
    DB=$(printf '%s\n' "$db" | awk '{ print toupper($0) }')
    user="POSTGRES_${DB}_USER"
    password="POSTGRES_${DB}_PASSWORD"
    schemas="POSTGRES_${DB}_SCHEMAS"
    create_user_and_database "$db" "${!user:-"${db}_admin"}" "${!password:-"password"}" "${!schemas:-""}"
  done
  echo "Database(s) created: ${POSTGRES_MULTIPLE_DB:-}"

  # Adding CREATEDB permission to the specified users
  if [ -n "${POSTGRES_GRANT_CREATEDB_TO:-}" ]; then
    echo "Granting CREATEDB permission to ${POSTGRES_GRANT_CREATEDB_TO}"
    for user in $(echo "${POSTGRES_GRANT_CREATEDB_TO}" | tr ',' ' '); do
      echo "  Granting CREATEDB permission to $user"
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${POSTGRES_DB:-postgres}" <<-EOSQL
      ALTER ROLE "$user" WITH CREATEDB;
EOSQL
      echo "CREATEDB permission granted to ${user}"
    done
  fi

  # Adding CREATEDB permission to the specified users
  if [ -n "${POSTGRES_GRANT_SUPERUSER_TO:-}" ]; then
    echo "Granting SUPERUSER permission to ${POSTGRES_GRANT_SUPERUSER_TO}"
    for user in $(echo "${POSTGRES_GRANT_SUPERUSER_TO}" | tr ',' ' '); do
      echo "  Granting SUPERUSER permission to $user"
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${POSTGRES_DB:-postgres}" <<-EOSQL
      ALTER ROLE "$user" WITH SUPERUSER;
EOSQL
      echo "SUPERUSER permission granted to ${user}"
    done
  fi
fi