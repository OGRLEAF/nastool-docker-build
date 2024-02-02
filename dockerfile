# syntax=docker/dockerfile:labs
FROM python:3.10-alpine

ENV SSH_AGENT_UID=1000
# ENV NPM_MIRROR="--registry=https://registry.npmmirror.com"
# ENV PIP_MIRROR="--index-url=https://mirrors.aliyun.com/pypi/simple/"
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN adduser --disabled-password --uid ${SSH_AGENT_UID} app-user
RUN mkdir /nastool-lite
RUN chown app-user:app-user /nastool-lite

ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-leaf.git#dev_noauth  /nastool-lite/server
ADD --chown=app-user:app-user git@github.com:OGRLEAF/nas-tools-react /nastool-lite/web-react


RUN apk add --update --no-cache --virtual .build-deps \
        util-linux\
        libffi-dev \
        gcc \
        musl-dev \
        libxml2-dev \
        libxslt-dev 
RUN apk add --update --no-cache  git \
        tzdata \
        zip \
        curl \
        bash \
        fuse3  \
        xvfb \
        inotify-tools \
        chromium-chromedriver  \
        s6-overlay \
        ffmpeg-dev \
        redis \
        wget \
        shadow \
        sudo

RUN python -V

RUN apk add nodejs npm
RUN apk add nginx envsubst

RUN npm install -g pm2 sharp ${NPM_MIRROR}
# RUN chown root:root /nastool-lite -Rf

# USER app-user

WORKDIR /nastool-lite
RUN python -m venv python-venv
ENV PATH="/nastool-lite/python-venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel  ${PIP_MIRROR}
RUN pip install cython  ${PIP_MIRROR}

RUN pip install -r /nastool-lite/server/requirements.txt ${PIP_MIRROR}


WORKDIR /nastool-lite/web-react
RUN npm install ${NPM_MIRROR}
RUN npm run build
RUN /.next/standalone /nastool-lite/web
RUN rm /nastool-lite/web-react -R

USER root
EXPOSE 3000

WORKDIR /nastool-lite/
COPY ./entrypoint.sh ./
COPY ./pm2_config.js ./ecosystem.config.js

COPY nginx.conf.template /etc/nginx/

RUN touch /.dockerenv
ENV NGINX_PORT=3000
ENV PUID=0
ENV GUID=0
ENV NATOOL_CONFIG_PATH=/config
ENV NASTOOL_CONFIG=${NATOOL_CONFIG_PATH}/config.yaml

ENV WEBDRIVER=/nastool-lite/chromedriver
ENTRYPOINT ["bash", "entrypoint.sh" ]