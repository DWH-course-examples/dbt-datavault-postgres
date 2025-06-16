ARG DBT_VERSION=1.0.0
FROM fishtownanalytics/dbt:${DBT_VERSION}

ENV DBT_PROFILES_DIR=.

RUN set -ex \
    && python -m pip install setuptools \
    && python -m pip install dbt-postgres==1.4.0 dbt-core==1.4.0


ENTRYPOINT [ "tail", "-f", "/dev/null" ]