FROM ubuntu:16.04

# based off of:
# https://github.com/riptano/cassandra-dtest/blob/1cc4941916a3df199821f974e47acd667f65c2b8/INSTALL.md

# define our default directories
ENV WORKDIR /usr/src/cstar
ENV CASSANDRA_DIR ${WORKDIR}/cassandra
WORKDIR ${WORKDIR}

# install prerequisites: git, python
RUN apt-get update \
    && apt-get install -y \
        git \
        python \
        python-setuptools \
        python-dev \
        python-pip

# install Java 8
RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
    && add-apt-repository ppa:webupd8team/java \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true \
        | /usr/bin/debconf-set-selections \
    && echo oracle-java8-installer shared/accepted-oracle-licence-v1-1 boolean true \
        | /usr/bin/debconf-set-selections \
    && apt-get update \
    && apt-get install -y \
        ant \
        ant-optional \
        oracle-java8-installer \
        oracle-java8-set-default \
    && java -version

# setup Java 7 and 8 paths to enable upgrade tests
# TODO: Java 7 is now hard to find. Once found, we can run the upgrade tests.
#ENV JAVA7_HOME /usr/lib/jvm/java-7-oracle/bin
ENV JAVA8_HOME /usr/lib/jvm/java-8-oracle/bin

# install CCM (Cassandra Cluster Manager)
RUN git clone git://github.com/pcmanus/ccm.git \
    && apt-get update \
    && apt-get install -y \
        libyaml-dev \
    && pip install -e \
        ccm \
    && pip install pyyaml

# install the Cassandra driver
RUN apt-get update \
    && apt-get install -y \
        gcc \
        libev4 \
        libev-dev \
        python-dev \
        python-snappy \
    && pip install \
        lz4 \
        scales \
    && pip install \
        git+git://github.com/datastax/python-driver@cassandra-test \
    && pip install --pre \
        cassandra-driver

# install Python packages and upgrade Pip to silence warnings
RUN pip install --upgrade \
    cql \
    decorator \
    docopt \
    enum \
    flaky \
    parse \
    pip \
    pycassa

# install Python test framework
RUN apt-get update \
    && apt-get install -y \
        python-nose

# may be needed to get junit working
RUN apt-get update \
    && apt-get install -y \
        ant-optional

# add a non-root user to allow Cassandra to start up
RUN groupadd -r cassandra \
    && useradd --no-log-init -r -g cassandra cassandra \
    && chown -R cassandra:cassandra ${WORKDIR}

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
