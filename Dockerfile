FROM ruby:2.6-alpine

LABEL com.github.actions.name="Wolfhound"
LABEL com.github.actions.description="Bark to your code quality and style errors"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="grey-dark"

LABEL maintainer="ItsMyCargo Engineering <oss@itsmycargo.com>"

RUN apk add --update --no-cache \
  jq \
  nodejs \
  npm

COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache --virtual .build-deps \
  build-base cmake openssl-dev \
  && gem install -g \
  && apk del .build-deps

RUN npm install -g eslint @itsmycargo/eslint-config

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
