# syntax=docker/dockerfile:labs
FROM debian:stable-slim

ENV SSH_AGENT_UID=1000
ENV NPM_MIRROR="--registry=https://registry.npmmirror.com"
ENV PIP_MIRROR="--index-url=https://mirrors.aliyun.com/pypi/simple/"

# RUN sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list


ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-leaf.git#dev_noauth  /nastool-lite/server
ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-react /nastool-lite/web-react

RUN apt-get update
RUN apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        util-linux\
        libffi-dev \
        gcc \
        musl-dev \
        libxml2-dev \
        libxslt-dev\
        adduser 
RUN apt-get install -y  git \
        tzdata \
        zip \
        curl \
        bash \
        fuse3  \
        xvfb \
        inotify-tools \
        chromium-driver  \
        ffmpeg \
        redis \
        wget \
        sudo \
        gettext-base

RUN python3 -V

RUN adduser --disabled-password --uid 1001 app-user
RUN chown app-user:app-user /nastool-lite

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs

RUN apt-get install nginx -y

RUN npm install -g pm2 sharp
# RUN chown root:root /nastool-lite -Rf

# USER app-user


WORKDIR /nastool-lite
RUN python3 -m venv python-venv

ENV PY_VENV=/nastool-lite/python-venv/bin
ENV PIP=${PY_VENV}/pip
ENV PYTHON=${PY_VENV}/python
RUN ${PIP} install --upgrade pip setuptools wheel ${PIP_MIRROR}
RUN ${PIP} install cython  ${PIP_MIRROR}
RUN ${PIP} install -r /nastool-lite/server/requirements.txt ${PIP_MIRROR}


WORKDIR /nastool-lite/web-react
RUN npm install ${NPM_MIRROR}
RUN npm run build
WORKDIR /nastool-lite/
RUN cp /nastool-lite/web-react/.next/standalone /nastool-lite/web -R
RUN cp /nastool-lite/web-react/.next/static /nastool-lite/web-static -R
RUN rm /nastool-lite/web-react -R

USER root
EXPOSE 3000

WORKDIR /nastool-lite/
COPY ./entrypoint.sh ./
COPY ./pm2_config.js ./ecosystem.config.js

COPY nginx.conf.template /etc/nginx/

RUN touch /.dockerenv
RUN chmod 770 /root

ENV NGINX_PORT=3000
ENV WEB_PORT=3002
ENV PUID=0
ENV GUID=0
ENV NATOOL_CONFIG_PATH=/config
ENV NASTOOL_CONFIG=${NATOOL_CONFIG_PATH}/config.yaml

ENV WEBDRIVER=/nastool-lite/chromedriver


ENTRYPOINT ["bash", "entrypoint.sh" ]