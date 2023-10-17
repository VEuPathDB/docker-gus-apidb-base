FROM amazoncorretto:21.0.0-alpine3.18

ENV PGDATA=/var/lib/postgresql/data

# Install necessary packages.
RUN apk add git perl perl-utils libaio python3 unzip perl-json perl-xml-simple \
            perl-date-manip perl-text-csv perl-tree-dag_node postgresql15 bash \
            maven apache-ant perl-dbi perl-dbd-pg \
    && cpan Module-Install-RDF-0.009 Statistics-Descriptive-3.0801 \
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
