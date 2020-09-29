FROM crystallang/crystal:0.35.1-alpine AS builder

ENV APP_HOME=/home/app

ARG UID=1000
ARG GID=1000

RUN addgroup -S --gid ${GID} app \
  && adduser -S -h ${APP_HOME} \
      --ingroup app --uid ${UID} app

WORKDIR $APP_HOME

COPY --chown=app:app shard.yml shard.lock $APP_HOME/

RUN shards install

COPY --chown=app:app . $APP_HOME

RUN shards build --release --production

FROM alpine:3.12

RUN apk update
RUN apk add gc gcc yaml-dev pcre ca-certificates

WORKDIR /home/app

COPY --from=builder /home/app/* /home/app/
