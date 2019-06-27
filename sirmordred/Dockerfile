FROM python:3.5.3
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

RUN mkdir -p /sirmordred/conf
RUN pip install --no-cache-dir sirmordred==0.2.17

CMD ["sirmordred", "-c", "/sirmordred/conf/setup.cfg"]
