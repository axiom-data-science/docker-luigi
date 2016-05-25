FROM phusion/baseimage:0.9.18
# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Setup CONDA (https://hub.docker.com/r/continuumio/miniconda3/~/dockerfile/)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    pwgen \
    binutils \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV MINICONDA_VERSION latest
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet -O /miniconda.sh http://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh && \
    /opt/conda/bin/conda update conda --yes
ENV PATH /opt/conda/bin:$PATH

# Install requirements
ADD requirements.txt /tmp/
RUN conda config --add channels conda-forge
RUN conda install --file /tmp/requirements.txt

ENV LUIGI_CONFIG_DIR /etc/luigi/

RUN mkdir -p $LUIGI_CONFIG_DIR
ADD logging.conf $LUIGI_CONFIG_DIR
ADD luigi.conf $LUIGI_CONFIG_DIR
ENV LUIGI_CONFIG_PATH /etc/luigi/luigi.conf
VOLUME $LUIGI_CONFIG_DIR

RUN mkdir -p /luigi/logs
VOLUME /luigi/logs

RUN mkdir -p /luigi/state
VOLUME /luigi/state

EXPOSE 8082

RUN mkdir /etc/service/luigid
COPY luigid.sh /etc/service/luigid/run
