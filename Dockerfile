FROM python:3.6

RUN apt-get update
RUN apt-get install -y supervisor

# Upgrade and install basic Python dependencies
# This block added because of the trouble installing gevent on many systems
# https://hub.docker.com/r/openwhisk/dockerskeleton/~/dockerfile/
RUN apt-get install -y \
        gcc \
        libc-dev
#  && pip install --no-cache-dir gevent \
#  && apk del .build-deps

# reqs layer
ADD requirements.txt .
RUN pip3 install -U -r requirements.txt
RUN pip3 install gunicorn==19.7.1

# Bundle app source
ADD . /src

COPY ./deployment/logging.conf /src/logging.conf
COPY ./deployment/gunicorn.conf /src/gunicorn.conf

EXPOSE 5000

# Setup supervisord
RUN mkdir -p /var/log/supervisor
COPY ./deployment/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./deployment/gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

# Start processes
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]


#ENTRYPOINT ["python"]
#CMD ["src/application.py"]
