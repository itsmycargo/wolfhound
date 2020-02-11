FROM ruby:2.7

LABEL com.github.actions.name="Wolfhound"
LABEL com.github.actions.description="Bark to your code quality and style errors"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="grey-dark"

LABEL maintainer="ItsMyCargo Engineering <oss@itsmycargo.com>"

RUN apt-get update && apt-get install -y \
      apt-transport-https \
      automake \
      build-essential \
      cmake \
      git \
      jq \
      locales \
      shellcheck

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
      && locale-gen C.UTF-8 \
      && /usr/sbin/update-locale LANG=C.UTF-8

RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
      && echo "deb https://deb.nodesource.com/node_12.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
      && apt-get update && apt-get install -y nodejs

RUN curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
      && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
      && apt-get update && apt-get install -y yarn

# Ruby
RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment 'true' \
  && bundle install --frozen \
  && bundle binstub pronto

# (Java|Type)script
ENV PREFIX=/usr/local/node_modules
ENV PATH=$PREFIX/.bin:$PATH
ENV NODE_PATH=$PREFIX
ENV NPM_CONFIG_PREFIX=$PREFIX

RUN mkdir $PREFIX

COPY package.json yarn.lock ./
RUN yarn config set prefix $PREFIX \
  && yarn install --modules-folder $PREFIX \
  && ln -s $PREFIX/.bin/eslint /usr/bin/eslint \
  && ln -s $PREFIX/.bin/stylelint /usr/bin/stylelint

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
