# Overview
Following this awesome [tutorial](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/) to host a Django app fronted with nginx and gunicorn.

I've changed the layout of the files (like having the .env and .yml) outside the app folder.


## Deployment

### Directory layout
```
|_____
      |--- djangoguninginx              // The Django project directory
      |           |
      |           |--- djangoguninginx  // The app directory
      |
      |--- nginx                        // Dockerfile for the nginx container; nginx config file
      |       |--- Dockerfile
      |       |--- nginx.conf
      |
      |--- db.prd.env                   // For a Prod environment, have the psql DB container read creds
      |--- djangoguninginx.env          // Dev environment for our Django app, holds DB credentials and other settings
      |--- djangoguninginx.prd.env      // Prod environment for our Django app, holds DB credentials and other settings
      |--- docker-compose.prd.yml       // Prod docker-compose file, defines services and other settings
      |--- docker-compose.yml           // Dev docker-compose file minus the db service definition
      |--- Dockerfile                   // Dev Dockerfile
      |--- Dockerfile.prd               // Prod Dockerfile with two stage builds to save on image size
      |--- entrypoint.prd.sh            // Prod file to sync DB container access after app container comes up
      |--- envrypoint.sh                // Dev version of the above file
      |--- README.md
      |--- requirements.prd.txt         // Python dependencies needed for the prod setup
      |--- requirements.txt             // Python dependencies needed for the dev setup
```

### Dev setup:
1x django app container (Running with the default dev app server)
1x postgresql container

- Set the DB parameters in the `docker-compose.yml` file - username, password and the database name via `POSTGRES_USER`, `POSTGRES_PASSWORD` and `POSTGRES_DB` respectively.
- Update the credentials (from the previous step) that our app will use to access the DB in the `djangoguninginx.env` file via `DB_USER`, `DB_PASSWORD` and `DATABASE`. The `DB_HOST` parameter is the 'service name' in the `docker-compose.yml` file.
- Update the `SECRET_KEY` with a secure string.
- `cd app-docker`
- Ensure the docker daemon is running as applicable to the OS.
- `docker-compose -f docker-compose.yml up -d --build`
- Access http://localhost:8000

### Prod setup:
- 1x django app container (Running with the gunicorn app server)
- 1x nginx container
- 1x postgresql DB container

- Set the DB parameters in the `db.prd.env` file - username, password and the database name via `POSTGRES_USER`, `POSTGRES_PASSWORD` and `POSTGRES_DB` respectively.
- Update the credentials (from the previous step) that our app will use to access the DB in the `djangoguninginx.prd.env` file via `DB_USER`, `DB_PASSWORD` and `DATABASE`. The `DB_HOST` parameter is the 'service name' in the `docker-compose.prd.yml` file.
- Update the `SECRET_KEY` with a secure string in the `djangoguninginx.prd.env`.
- `cd app-docker`
- Ensure the docker daemon is running as applicable to the OS.
- `docker-compose -f docker-compose.prd.yml up -d --build`
- Access http://localhost:8000


### Troubleshooting:
- From the `app-docker` dir, run `docker-compose -f <prod or dev docker-compose file> ps` to check the status of the containers.
```
dev example:
            Name                          Command               State           Ports
----------------------------------------------------------------------------------------------
app-docker_djangoguninginx_1   /opt/djangoguninginx/entry ...   Up      0.0.0.0:8000->8000/tcp
app-docker_postgresql_1        docker-entrypoint.sh postgres    Up      5432/tcp

```
- From the `app-docker` dir, run `docker-compose -f <prod or dev docker-compose file> exec -it <container name/id> bash` to get a BASH tty to the container.
- From the `app-docker` dir, run `docker-compose -f <prod or dev docker-compose file> logs -f --tail=5 <container name/id>` to read STDOUT/STDERR from the container with scrolling.

### Teardown:
- From the `app-docker` dir, run `docker-compose -f docker-compose.yml stop && docker-compose -f docker-compose.yml down -v --rmi all` to stop the containers and delete volumes and images.