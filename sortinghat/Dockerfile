FROM python:3.6
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

ENV SORTINGHAT_DB_HOST "mariadb"
ENV SORTINGHAT_DB_USER "admin"
ENV SORTINGHAT_DB_PASSWORD "secret"
ENV SORTINGHAT_DB_DATABASE "sortinghat"
ENV SORTINGHAT_DB_PORT "3306"

RUN pip install --no-cache-dir sortinghat==0.7.7
