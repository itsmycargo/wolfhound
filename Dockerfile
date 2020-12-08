FROM mstruebing/editorconfig-checker:2.2.0 as editorconfig-checker
FROM golangci/golangci-lint:v1.33.0 as golangci-lint
FROM yoheimuta/protolint:v0.26.1 as protolint
FROM koalaman/shellcheck:v0.7.1 as shellcheck
FROM wata727/tflint:0.21.0 as tflint
FROM alpine/terragrunt:0.14.0 as terragrunt
FROM mvdan/shfmt:v3.2.1 as shfmt
FROM accurics/terrascan:d182f1c as terrascan
FROM hadolint/hadolint:latest-alpine as dockerfile-lint

FROM python:alpine

LABEL maintainer="ItsMyCargo SRE <sre@itsmycargo.com>"

RUN apk add --no-cache \
    bash \
    coreutils \
    curl \
    file \
    gcc \
    git git-lfs\
    go \
    gnupg \
    icu-libs \
    jq \
    krb5-libs \
    libc-dev libxml2-dev libxml2-utils libgcc \
    libcurl libintl libssl1.1 libstdc++ \
    linux-headers \
    make \
    musl-dev \
    npm nodejs-current \
    openjdk8-jre \
    py3-setuptools \
    readline-dev \
    ruby ruby-dev ruby-bundler ruby-rdoc

COPY dependencies/* /

################################
# Installs python dependencies #
################################
RUN pip3 install --no-cache-dir pipenv
RUN pipenv install --system

####################
# Run NPM Installs #
####################
RUN npm config set package-lock false \
    && npm config set loglevel error \
    && npm --no-cache install

#############################
# Add node packages to path #
#############################
ENV PATH="/node_modules/.bin:${PATH}"

##############################
# Installs ruby dependencies #
##############################
RUN bundle install

######################
# Install shellcheck #
######################
COPY --from=shellcheck /bin/shellcheck /usr/bin/

#####################
# Install Go Linter #
#####################
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/bin/

##################
# Install TFLint #
##################
COPY --from=tflint /usr/local/bin/tflint /usr/bin/

##################
# Install Terrascan #
##################
COPY --from=terrascan /go/bin/terrascan /usr/bin/
RUN terrascan init

######################
# Install Terragrunt #
######################
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/bin/

################################
# Install editorconfig-checker #
################################
COPY --from=editorconfig-checker /usr/bin/ec /usr/bin/editorconfig-checker

# Copy scripts
COPY lib /action

# Copy tool configuration
COPY config /root

RUN mkdir -p /workspace
WORKDIR /workspace

ENTRYPOINT ["/action/linter.sh"]
