FROM ubuntu:23.10

ENV PGDATA=/var/lib/postgresql/data \
    ORACLE_HOME=/opt/oracle \
    LD_LIBRARY_PATH=/opt/oracle

RUN apt-get update \
    && apt-get install -y git perl libaio1 unzip wget ant maven postgresql-15 \
        libtree-dagnode-perl libxml-simple-perl libjson-perl libtext-csv-perl \
        libdate-manip-perl libdbi-perl libdbd-pg-perl \
        libmodule-install-rdf-perl libstatistics-descriptive-perl \
    && apt-get clean

RUN mkdir -p ${ORACLE_HOME} \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-basic-linux.x64-21.11.0.0.0dbru.zip -O ${ORACLE_HOME}/instant.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sqlplus-linux.x64-21.11.0.0.0dbru.zip -O ${ORACLE_HOME}/sqlplus.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sdk-linux.x64-21.11.0.0.0dbru.zip -O ${ORACLE_HOME}/sdk.zip \
    && cd ${ORACLE_HOME} \
    && unzip instant.zip \
    && unzip sqlplus.zip \
    && unzip sdk.zip \
    && rm instant.zip sdk.zip sqlplus.zip \
    && mv instantclient_21_11/* . \
    && rm -rf instantclient_21_11 \
    && mv sqlplus /usr/bin/sqlplus \
    && cpan DBD::Oracle \
    && mkdir -p /run/postgresql \
    && chown postgres:postgres /run/postgresql

# # Copy postgres config files
COPY [ \
    "pg/pg_hba.conf", \
    "pg/pg_ident.conf", \
    "pg/postgresql.conf", \
    "/etc/postgresql/15/main/" \
]

# Required variables.
ARG GUS_COMMIT_HASH=bca3334a86f9d86fde04ac38617dc40a6f9c410d \
    CBIL_COMMIT_HASH=190c888a0c35653d0449178807f2e09b6ba4d871 \
    INSTALL_COMMIT_HASH=2ca76b87ca70c0b69d0576298f8c87df6f904f82\
    GUS_SCHEMA_COMMIT_HASH=5ecc2343b600c9bd3a1929ff91a9ca2fd54844f3 \
    APIDB_SCHEMA_COMMIT_HASH=0373d82318b41abfbe4f92cacc6df13d41e01e87 \
    LIB_INSTALL_COMMIT_HASH=6ce2790ef9f585e0abdad1b9cb0c75ac0a51fc11

ENV GUS_HOME=/opt/veupathdb/gus_home \
    PROJECT_HOME=/opt/veupathdb/project_home \
    TEMPLATE_DB_NAME="template" \
    TEMPLATE_DB_USER="someone" \
    TEMPLATE_DB_PASS="password"
ENV PATH="$PATH:${GUS_HOME}/bin"

ARG GITHUB_USERNAME \
    GITHUB_TOKEN

COPY [ \
    "build/repo-cloning.sh", \
    "build/build-gus-config.sh", \
    "build/build-gus-home.sh", \
    "build/db-install.sh", \
    "./" \
]

RUN ./repo-cloning.sh \
    && ./build-gus-home.sh \
    && ./build-gus-config.sh \
    && ./db-install.sh; \
    rm -rf ${PROJECT_HOME}/*
