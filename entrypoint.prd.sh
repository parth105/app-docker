#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
  echo "Waiting for DB connectivity.."

  while ! nc -z $DB_HOST $DB_PORT; do
    sleep 0.1
  done

  echo "DB connectivity established."
fi

exec "$@"