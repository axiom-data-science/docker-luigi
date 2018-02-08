FROM python:3.7-rc-alpine

MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
MAINTAINER Sam Merry <sam@getpolymorph.com>

ENV LUIGI_VERSION 2.7.1

# Install compile time dependencies
# install sqlalchemy
# Delete compile time dependencies
RUN apk add --no-cache --virtual .build-deps \
      build-base \
      py-mysqldb \
      gcc \
      libc-dev \
      libffi-dev \
      mariadb-dev && \
    pip install \
      luigi==$LUIGI_VERSION \
      sqlalchemy \
      mysqlclient && \
    apk add --virtual mariadb-client-libs && \
    apk del .build-deps


ENV LUIGI_CONFIG_DIR /etc/luigi/
COPY logging.conf $LUIGI_CONFIG_DIR
COPY luigi.conf $LUIGI_CONFIG_DIR
ENV LUIGI_CONFIG_PATH /etc/luigi/luigi.conf
VOLUME $LUIGI_CONFIG_DIR

RUN mkdir -p /luigi/state
VOLUME /luigi/state

EXPOSE 8082/TCP

COPY luigid.sh /bin/run
ENTRYPOINT ["/bin/run"]

