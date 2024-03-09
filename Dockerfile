FROM golang:1.22-alpine3.19 AS go-tools-build

RUN apk add --no-cache make

WORKDIR /tmp/build

COPY tools .

RUN make build-go-tools



FROM ubuntu:23.10 AS runtime

ARG JAVA_VERSION=21.0.2.13.1 \
    ANT_VERSION=1.10.14 \
    MAVEN_VERSION=3.9.5

ENV PGDATA=/var/lib/postgresql/data \
    ORACLE_HOME=/opt/oracle \
    LD_LIBRARY_PATH=/opt/oracle \
    JAVA_HOME=/opt/java \
    LANG=en_US.UTF-8

RUN apt-get update \
    && apt-get install -y locales \
    && sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    \
    && apt-get install -y git perl libaio1 unzip wget postgresql-15 make gcc \
        libtree-dagnode-perl libxml-simple-perl libjson-perl libtext-csv-perl \
        libdate-manip-perl libdbi-perl libdbd-pg-perl libtest-nowarnings-perl \
        libmodule-install-rdf-perl libstatistics-descriptive-perl curl \
        libmodule-install-rdf-perl libstatistics-descriptive-perl \
    && apt-get clean \
    \
    && mkdir -p ${JAVA_HOME} \
    && cd ${JAVA_HOME} \
    && wget -O java.tgz https://corretto.aws/downloads/resources/${JAVA_VERSION}/amazon-corretto-${JAVA_VERSION}-linux-x64.tar.gz \
    && tar -xf java.tgz \
    && rm java.tgz \
    && mv amazon-corretto-${JAVA_VERSION}-linux-x64/* . \
    \
    && mkdir -p /opt/ant \
    && cd /opt/ant \
    && wget -O ant.tgz https://dlcdn.apache.org//ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && tar -xf ant.tgz \
    && rm ant.tgz \
    && mv apache-ant-1.10.14/* . \
    && ln -s /opt/ant/bin/ant /usr/bin/ant \
    \
    && mkdir -p /opt/maven \
    && cd /opt/maven \
    && wget -O maven.tgz https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xf maven.tgz \
    && rm maven.tgz \
    && mv apache-maven-${MAVEN_VERSION}/* . \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    \
    && mkdir -p ${ORACLE_HOME} \
    && cd ${ORACLE_HOME} \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-basic-linux.x64-21.11.0.0.0dbru.zip -O instant.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sqlplus-linux.x64-21.11.0.0.0dbru.zip -O sqlplus.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sdk-linux.x64-21.11.0.0.0dbru.zip -O sdk.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-tools-linux.x64-21.11.0.0.0dbru.zip -O tools.zip \
    && unzip instant.zip \
    && unzip sqlplus.zip \
    && unzip sdk.zip \
    && unzip tools.zip \
    && rm instant.zip sdk.zip sqlplus.zip tools.zip \
    && mv instantclient_21_11/* . \
    && rm -rf instantclient_21_11 \
    && mv -t /usr/bin/ sqlplus sqlldr \
    && cpan DBD::Oracle \
    && mkdir -p /run/postgresql \
    && chown postgres:postgres /run/postgresql

# Copy postgres config files
COPY [ \
    "pg/pg_hba.conf", \
    "pg/pg_ident.conf", \
    "pg/postgresql.conf", \
    "/etc/postgresql/15/main/" \
]

# Required variables.
ARG GUS_COMMIT_HASH=bca3334a86f9d86fde04ac38617dc40a6f9c410d \
    CBIL_COMMIT_HASH=8d91d2bc703d36b0eb6bfd8db5a4755d1d2fb99d \
    INSTALL_COMMIT_HASH=2ca76b87ca70c0b69d0576298f8c87df6f904f82\
    GUS_SCHEMA_COMMIT_HASH=5ecc2343b600c9bd3a1929ff91a9ca2fd54844f3 \
    APIDB_SCHEMA_COMMIT_HASH=9b180956e6335db3a7a96d7f32da3870df94c233 \
    LIB_INSTALL_COMMIT_HASH=c46e5949e1c25be99c0ba73b3e2633d2a499c58c


ENV GUS_HOME=/opt/veupathdb/gus_home \
    PROJECT_HOME=/opt/veupathdb/project_home \
    TEMPLATE_DB_NAME="gus_template" \
    TEMPLATE_DB_USER="someone" \
    TEMPLATE_DB_PASS="password"

ENV PATH="$PATH:${PROJECT_HOME}/install/bin:${GUS_HOME}/bin:${JAVA_HOME}/bin:/usr/lib/postgresql/15/bin"

ARG GITHUB_USERNAME \
    GITHUB_TOKEN

# Keep these separate from below so we don't need to reclone
# after each change to  build process
COPY ./build/repo-cloning.sh ./
RUN ./repo-cloning.sh

COPY [ \
    "build/build-gus-config.sh", \
    "build/build-gus-home.sh", \
    "build/db-install.sh", \
    "./" \
]

RUN ./build-gus-config.sh \
    && ./build-gus-home.sh \
    && ./db-install.sh;

COPY --from=go-tools-build /tmp/build/bin /usr/bin/

RUN curl -fsSL https://get.nextflow.io | NXF_VER=23.10.0 bash && mv nextflow /usr/bin/nextflow
