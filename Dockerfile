FROM ruby:2.6-alpine

LABEL com.github.actions.name="Wolfhound"
LABEL com.github.actions.description="Bark to your code quality and style errors"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="grey-dark"

LABEL maintainer="ItsMyCargo Engineering <oss@itsmycargo.com>"

# Packages
RUN apk add --update --no-cache \
  jq \
  nodejs

# Ruby
COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache --virtual .build-deps \
  build-base cmake openssl-dev \
  && gem install -g \
  && apk del .build-deps

# (Java|Type)script
ENV PREFIX=/usr/local/node_modules
ENV PATH=$PREFIX/.bin:$PATH
ENV NODE_PATH=$PREFIX
ENV NPM_CONFIG_PREFIX=$PREFIX

RUN mkdir $PREFIX
COPY package.json yarn.lock ./

RUN apk add --no-cache --virtual .build-deps \
  yarn \
  && yarn config set prefix $PREFIX \
  && yarn install --modules-folder $PREFIX \
  && apk del .build-deps \
  && ln -s $PREFIX/.bin/eslint /usr/bin/eslint

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
