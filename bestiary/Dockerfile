FROM python:3
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

COPY src/ bestiary/
RUN pip install -r bestiary/requirements.txt
RUN pip install gunicorn

WORKDIR bestiary/django_bestiary

RUN python manage.py makemigrations
RUN python manage.py migrate

CMD ["gunicorn", "django_bestiary.wsgi", "--bind", "0.0.0.0:8000"]

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost:8000/
