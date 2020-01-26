#!/usr/bin/env bash

CONTAINER_NAME='sql-modules'
DATABASE='sql_modules'
USER='postgres'
PASSWORD='postgres'
HOST='localhost'
PORT=5432

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
      --env POSTGRES_USER=$USER \
      --env POSTGRES_PASSWORD=$PASSWORD \
      --env POSTGRES_DB=$DATABASE \
      postgres:12

    sleep 5
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

function usage() {
  echo "Usage: docker <start|stop|destroy>"
  exit 1
}

case "$1" in
  start) startDocker;;
  stop) stopDocker;;
  destroy) destroyDocker;;
  *) usage;;
esac
