FROM phusion/baseimage:0.11
CMD ["/sbin/my_init", "--quiet"]

LABEL maintainer="Kyle Wilcox <kyle@axds.com>"

ARG DEBIAN_FRONTEND="noninteractive"

ARG PYTHON_VERSION="3.7"

ARG CONDA_VERSION="4.8.2"
ARG CONDA_PY_VERSION="37"
ARG CONDA_MD5="87e77f097f6ebb5127c77662dfc3165e"
ARG CONDA_DIR="/opt/conda"

ARG LUIGI_VERSION="2.8.13"
ARG LUIGI_CONFIG_DIR="/etc/luigi/"
ARG LUIGI_CONFIG_PATH="/etc/luigi/luigi.conf"
ARG LUIGI_STATE_DIR="/luigi/state"

ENV PATH="$CONDA_DIR/bin:$PATH"
ENV LANG="C.UTF-8"
ENV LUIGI_VERSION="${LUIGI_VERSION}"

RUN echo "**** install binary packages ****" && \
    install_clean \
        bash \
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
    \
    echo "**** install miniconda ****" && \
    mkdir -p "$CONDA_DIR" && \
    wget "https://repo.anaconda.com/miniconda/Miniconda3-py${CONDA_PY_VERSION}_${CONDA_VERSION}-Linux-x86_64.sh" -O miniconda.sh && \
    echo "$CONDA_MD5  miniconda.sh" | md5sum -c && \
    \
    bash miniconda.sh -f -b -p "$CONDA_DIR" && \
    echo "export PATH=$CONDA_DIR/bin:\$PATH" > /etc/profile.d/conda.sh && \
    \
    conda update --all --yes && \
    conda config \
        --set auto_update_conda False \
        --set always_yes yes \
        --set changeps1 no \
        --set show_channel_urls True \
        && \
    conda config \
        --add channels conda-forge \
        && \
    \
    echo "**** install python packages ****" && \
    conda install --yes --freeze-installed \
        python=="${PYTHON_VERSION}*" \
        luigi=="${LUIGI_VERSION}" \
        sqlalchemy \
        psycopg2 \
        mysql-connector-python \
        mysqlclient \
        prometheus_client \
        && \
    \
    echo "**** cleanup ****" && \
    rm -rf /root/.cache /tmp/* /var/tmp/* && \
    rm -f miniconda.sh && \
    conda clean --all --force-pkgs-dirs --yes && \
    find "$CONDA_DIR" -follow -type f \( -iname '*.a' -o -iname '*.pyc' -o -iname '*.js.map' \) -delete && \
    \
    echo "**** finalize ****" && \
    mkdir -p "${LUIGI_CONFIG_DIR}" && \
    mkdir -p "${LUIGI_STATE_DIR}"

COPY logging.conf "${LUIGI_CONFIG_DIR}"
COPY luigi.conf "${LUIGI_CONFIG_DIR}"
VOLUME ["${LUIGI_CONFIG_DIR}", "${LUIGI_STATE_DIR}"]

EXPOSE 8082/TCP

RUN mkdir /etc/service/luigid
COPY luigid.sh /etc/service/luigid/run
