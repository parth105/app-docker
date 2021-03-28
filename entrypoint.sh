#!/bin/sh

# This is only run when the docker build command is executed
# This simply ensures that if its a fresh DB (which it will be if the containers are being rebuild), run migrations

if [ "$DATABASE" = "postgres" ]
then
  echo "Verifying DB connectivity.."

  while ! nc -z $DB_HOST $DB_PORT; do
    sleep 0.1
  done

  echo "DB connectivity verified."
fi

# "Removes all data from the database and re-executes any post-synchronization handlers.
# The table of which migrations have been applied is not cleared.""
python manage.py flush --no-input   # suppress output

# If you would rather start from an empty database and re-run all migrations, 
#  you should drop and recreate the database and then run migrate instead.
python manage.py migrate

python manage.py collectstatic --no-input --clear

# https://docs.docker.com/engine/reference/builder/#understand-how-cmd-and-entrypoint-interact
# As per explanation it will anyways be "entrypoint_exec" "entrypoint_param" "cmd_exec" "cmd_param",
# meaning cmd executable and param will be appended to entrypoint. This will ensures that
# echo "Finalmente entrypoint params: $@"  >> 'Finalmente entrypoint params: python manage.py runserver 0.0.0.0:8000'

exec "$@"
