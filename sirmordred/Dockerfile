FROM python:3.5.3
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

RUN mkdir -p /sirmordred/conf
RUN pip install --no-cache-dir sirmordred==0.2.20

WORKDIR /sirmordred/conf/

CMD ["sirmordred", "-c", "setup.cfg"]
