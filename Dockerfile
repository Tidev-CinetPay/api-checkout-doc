FROM python:3.9.2-alpine3.13

ARG WITH_PLUGINS=true

ENV PACKAGES=/usr/local/lib/python3.9/site-packages

ENV PYTHONDONTWRITEBYTECODE=1

ADD . ./app

WORKDIR /app

VOLUME /app/logs

RUN pip install --no-cache-dir -r requirements.txt

RUN pip install mkdocs-minify-plugin

EXPOSE 8000:8000

RUN pip install mkdocs-redirects

ENTRYPOINT ["mkdocs"]

CMD ["serve", "--dev-addr=0.0.0.0:8000"]