#!/usr/bin/env bash

CONTAINER_NAME='sql-modules'

ADMIN_USER='admin'
ADMIN_PASSWORD='admin_password'

DATABASE='sqlmodules'
USER='melty'
PASSWORD='puffs'
HOST='localhost'
PORT=5434

PSQL_ADMIN_LOGIN="PGPASSWORD=$ADMIN_PASSWORD psql -U $ADMIN_USER -d $DATABASE -h $HOST -p $PORT"
PSQL_USER_LOGIN="PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT"

function startDocker() {
  if [ $(docker ps -q -a -f name=$CONTAINER_NAME) ]; then
    echo "Starting Postgres docker container"
    docker start $CONTAINER_NAME
  else
    echo "Installing Postgres docker container"
    docker run \
      --detach \
      --name $CONTAINER_NAME \
      --publish "$PORT:5432" \
      --env POSTGRES_USER=$ADMIN_USER \
      --env POSTGRES_PASSWORD=$ADMIN_PASSWORD \
      --env POSTGRES_DB=$DATABASE \
      postgres:12
  fi
}

function stopDocker() {
  echo "Stopping Postgres docker container"
  docker stop $CONTAINER_NAME
}

function destroyDocker() {
  echo "Destroying Postgres docker container"
  docker rm $(docker stop $CONTAINER_NAME)
}

function createUserWithAdminUser() {
  echo "Creating postgres user"
  local addUser=" \
    create role $USER with password '$PASSWORD'; \
    alter role $USER login createrole; \
    grant all privileges on database $DATABASE to $USER; \
  "
  eval $PSQL_ADMIN_LOGIN -c \"$addUser\"
}

function resetDb() {
  echo "Resetting postgres schema"
  local resetSchema=" \
    drop schema if exists $DATABASE cascade; \
    create schema $DATABASE; \
    alter role $USER set search_path to $DATABASE; \
  "
  eval $PSQL_USER_LOGIN -c \"$resetSchema\"
  # eval $PSQL_USER_LOGIN < database/schema.sql

  # echo "Seeding postgres data"
  # eval $PSQL_USER_LOGIN < database/seed.sql
}

function runPsql() {
  eval $PSQL_USER_LOGIN
}

function usage() {
  echo "Usage: docker <command>"
  echo "Available commands:"
  echo "start"
  echo "stop"
  echo "destroy"
  echo "create-user"
  echo "reset"
  echo "pqsl"
  exit 1
}

case "$1" in
  start) startDocker;;
  stop) stopDocker;;
  destroy) destroyDocker;;
  create-user) createUserWithAdminUser;;
  reset) resetDb;;
  seed) seedDb;;
  psql) runPsql;;
  *) usage;;
esac
