FROM python:3.14-slim

WORKDIR /usr/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*


RUN pip install --no-cache-dir dbt-bigquery dbt-postgres

ENTRYPOINT ["dbt"]