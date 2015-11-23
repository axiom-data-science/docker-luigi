FROM debian:jessie

MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

RUN apt-get update
RUN apt-get upgrade -y

# Setup CONDA (https://hub.docker.com/r/continuumio/miniconda3/~/dockerfile/)
RUN apt-get install -y \
    git \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    pwgen \
    binutils

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.10.1-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-3.10.1-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-3.10.1-Linux-x86_64.sh && \
    /opt/conda/bin/conda install --yes conda

ENV PATH /opt/conda/bin:$PATH
ENV DEBIAN_FRONTEND noninteractive
ENV LUIGI_CONFIG_PATH /etc/luigi/luigi.conf

# Install requirements
ADD requirements.txt /tmp/
RUN conda config --add channels ioos
RUN conda install --file /tmp/requirements.txt

RUN mkdir /etc/luigi
ADD logging.conf /etc/luigi/
ADD luigi.conf /etc/luigi/
VOLUME /etc/luigi

RUN mkdir -p /luigi/logs
VOLUME /luigi/logs

RUN mkdir -p /luigi/state
VOLUME /luigi/state

EXPOSE 8082

ENTRYPOINT ["luigid", "--logdir", "/luigi/logs"]
