ARG PYTHON_VERSION=3.7
FROM python:$PYTHON_VERSION-alpine

MAINTAINER Kyle Wilcox <kyle@axds.com>
MAINTAINER Sam Merry <sam@getpolymorph.com>

ARG LUIGI_VERSION=2.8.3
ENV LUIGI_VERSION ${LUIGI_VERSION}
ENV PYTHON_VERSION ${PYTHON_VERSION}
ENV LUIGI_CONFIG_DIR /etc/luigi/
ENV LUIGI_CONFIG_PATH /etc/luigi/luigi.conf
ENV LUIGI_STATE_DIR /luigi/state

RUN apk add --no-cache --virtual .build-deps \
      build-base \
      py-mysqldb \
      gcc \
      libc-dev \
      libffi-dev \
      mariadb-dev && \
    apk add --no-cache --virtual \
      postgresql-dev && \
    pip install \
      luigi==${LUIGI_VERSION} \
      sqlalchemy \
      psycopg2 \
      mysqlclient && \
    apk add --virtual mariadb-client-libs && \
    apk del .build-deps && \
    mkdir -p ${LUIGI_CONFIG_DIR} && \
    mkdir -p ${LUIGI_STATE_DIR}

COPY logging.conf ${LUIGI_CONFIG_DIR}
COPY luigi.conf ${LUIGI_CONFIG_DIR}
VOLUME ["${LUIGI_CONFIG_DIR}", "${LUIGI_STATE_DIR}"]

EXPOSE 8082/TCP

COPY luigid.sh /bin/run
ENTRYPOINT ["/bin/run"]
