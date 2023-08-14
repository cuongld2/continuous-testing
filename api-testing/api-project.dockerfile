# Get the base image of Node version 16
FROM ubuntu:18.04

ENV NODE_VERSION=16.13.0
RUN apt-get update && \
    apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

RUN npm init playwright@latest

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;


ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN apt-get update && apt-get -y install libnss3 libatk-bridge2.0-0 libdrm-dev libxkbcommon-dev libgbm-dev libasound-dev libatspi2.0-0 libxshmfence-dev zip nano

ENV PATH /app/node_modules/.bin:$PATH


RUN mkdir /app
WORKDIR /app


COPY package.json package.json
COPY package-lock.json package-lock.json
COPY playwright.config.ts playwright.config.ts
COPY tests/ tests/
COPY models/ models/
COPY utils/ utils/
COPY data/ data/

COPY global-setup.ts global-setup.ts
COPY global-teardown.ts global-teardown.ts
COPY test-reporter.ts test-reporter.ts
COPY config/ config/


RUN npm install

# Keep the container up and running
CMD ["/bin/sh", "-c", "trap : TERM INT; sleep infinity & wait"]
