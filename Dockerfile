FROM phusion/baseimage:0.9.19
# Use baseimage-docker's init system
CMD ["/sbin/my_init", "--quiet"]

MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
        binutils \
        build-essential \
        bzip2 \
        ca-certificates \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup CONDA (https://hub.docker.com/r/continuumio/miniconda3/~/dockerfile/)
ENV MINICONDA_VERSION 4.1.11
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    curl -k -o /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh && \
    /opt/conda/bin/conda config \
        --set always_yes yes \
        --set changeps1 no \
        --set show_channel_urls True \
        && \
    /opt/conda/bin/conda config \
        --add channels conda-forge \
        --add channels axiom-data-science \
        && \
    /opt/conda/bin/conda clean -a -y

ENV PATH /opt/conda/bin:$PATH

# Install requirements
COPY requirements.txt /tmp/
RUN conda install -y \
        --file /tmp/requirements.txt \
        && \
    conda clean -a -y

ENV LUIGI_VERSION 2.1.1
ENV LUIGI_CONFIG_DIR /etc/luigi/

RUN mkdir -p $LUIGI_CONFIG_DIR
COPY logging.conf $LUIGI_CONFIG_DIR
COPY luigi.conf $LUIGI_CONFIG_DIR
ENV LUIGI_CONFIG_PATH /etc/luigi/luigi.conf
VOLUME $LUIGI_CONFIG_DIR

RUN mkdir -p /luigi/state
VOLUME /luigi/state

EXPOSE 8082

RUN mkdir /etc/service/luigid
COPY luigid.sh /etc/service/luigid/run
