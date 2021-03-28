# This file will be called by docker-compose using the 'build' command
# All this does is creates an image
# For this project, this image simply copies the requirements.txt and entrypoint.sh files over to the image
# The docker-compose file will actually make the django app available to the container (via volumes)

# So if the below command is run, to start a nanga (nude, in the sense without docker-compose adding env file) django server
# (we first have to add `COPY ./djangoguninginx /opt/djangoguninginx`)
# it will default to a db.sqlite3 backend
# docker run -p 8001:8000 \
# -e "SECRET_KEY=please_change_me" -e "DEBUG=1" -e "DJANGO_ALLOWED_HOSTS=*" \
# hello_django python /opt/djangoguninginx/manage.py runserver 0.0.0.0:8000


# Pull base python image
FROM python:3.8.3-alpine

# Set a work dir
WORKDIR /opt/djangoguninginx

# Environ variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update && \
    apk add postgresql-dev gcc python3-dev musl-dev

# Copy our Django app dir (in the same dir) and make it available under /opt
COPY ./djangoguninginx /opt/djangoguninginx
COPY ./requirements.txt /opt/djangoguninginx/requirements.txt
COPY ./entrypoint.sh /opt/djangoguninginx/entrypoint.sh
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Entrypoint; [] is the exec form; binary executables will be PID 1
#               vs in the string form, shell will be PID1
# In exec form, the executable is run as is vs in the shell form, run as though in a shell environment
ENTRYPOINT [ "/opt/djangoguninginx/entrypoint.sh" ]