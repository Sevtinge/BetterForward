FROM python:3.12-alpine

RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY locale /app/locale
COPY requirements.txt /tmp/requirements.txt

RUN apk add --no-cache ca-certificates && \
    update-ca-certificates

RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt \
    && mkdir -p /app/data \
    && find /app/locale -name '*.po' -type f -delete

RUN find locale -name '*.po' -print0 | while IFS= read -r -d '' po; do \
    msgfmt "$po" -o "${po%.po}.mo"; \
    done



ADD main.py /app
ADD src /app/src
ADD db_migrate /app/db_migrate

ENV TOKEN=""
ENV GROUP_ID=""
ENV LANGUAGE="en_US"
ENV TG_API=""
ENV WORKER="2"

CMD python -u /app/main.py -token "$TOKEN" -group_id "$GROUP_ID" -language "$LANGUAGE" -tg_api "$TG_API" -worker "$WORKER"
