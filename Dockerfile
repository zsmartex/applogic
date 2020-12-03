FROM crystallang/crystal:0.35.1

ENV APP_HOME=/home/app

ARG UID=1000
ARG GID=1000

RUN groupadd -r --gid ${GID} app \
  && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
      --gid ${GID} --uid ${UID} app

WORKDIR $APP_HOME

COPY --chown=app:app shard.yml shard.lock $APP_HOME/

RUN shards install

COPY --chown=app:app . $APP_HOME

RUN shards build --release --production
