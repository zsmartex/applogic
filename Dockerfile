FROM crystallang/crystal:0.35.1-alpine AS builder

ENV APP_HOME=/home/app

ARG UID=1000
ARG GID=1000

RUN groupadd -r --gid ${GID} app \
  && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
      --gid ${GID} --uid ${UID} app

WORKDIR $APP_HOME

COPY --chown=app:app shard.yml shard.lock $APP_HOME/

RUN chown -R app:app /opt/vendor $APP_HOME \
  && su app -s /bin/bash -c "shards install"

COPY --chown=app:app . $APP_HOME

RUN shards build --release --production

FROM alpine:3.12

RUN apk update
RUN apk add gc gcc yaml-dev pcre ca-certificates

WORKDIR /home/app

COPY --from=builder /build/bin/* /home/app/
