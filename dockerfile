# syntax=docker/dockerfile:labs
FROM debian:stable-slim

SHELL ["/bin/bash", "-c"]

ARG USE_CN_MIRROR

ENV USE_CN_MIRROR=$USE_CN_MIRROR
ENV SSH_AGENT_UID=1000
ENV NPM_MIRROR=${USE_CN_MIRROR:+"--registry=https://registry.npmmirror.com"}
ENV PIP_MIRROR=${USE_CN_MIRROR:+"--index-url=https://mirrors.aliyun.com/pypi/simple/"}
RUN echo "Use npm mirror: ${NPM_MIRROR}"
RUN echo "Use npm mirror: ${PIP_MIRROR}"

# RUN ls -la /etc/apt/sources.list.d
# RUN cat /etc/apt/sources.list.d/debian.sources
# RUN if [[ -n $USE_CN_MIRROR ]] ; then \
#         echo "Use apt mirror"; \
#         sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list ; \
#         fi

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

RUN adduser --disabled-password --uid 1000 app-user

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs

RUN apt-get install nginx -y
RUN npm install -g pm2 sharp

RUN mkdir /nastool-lite
RUN chown root:root /nastool-lite -Rf


WORKDIR /nastool-lite

ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-leaf.git#dev_noauth  /nastool-lite/server

RUN python3 -m venv python-venv
ENV PY_VENV=/nastool-lite/python-venv/bin
ENV PIP=${PY_VENV}/pip
ENV PYTHON=${PY_VENV}/python
RUN ${PIP} install --upgrade pip setuptools wheel ${PIP_MIRROR}
RUN ${PIP} install cython  ${PIP_MIRROR}
RUN ${PIP} install -r /nastool-lite/server/requirements.txt ${PIP_MIRROR}


ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-react /nastool-lite/web-react

WORKDIR /nastool-lite/web-react

RUN npm install ${NPM_MIRROR}
RUN npm install sharp
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