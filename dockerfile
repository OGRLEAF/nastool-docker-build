# syntax=docker/dockerfile:labs
FROM alpine:latest

ENV SSH_AGENT_UID=1000

RUN adduser --disabled-password --uid ${SSH_AGENT_UID} app-user
RUN mkdir /nastool-lite

ADD git@github.com:OGRLEAF/nas-tools-leaf.git#dev_noauth  /nastool-lite/server
ADD git@github.com:OGRLEAF/nas-tools-react /nastool-lite/web


# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache --virtual .build-deps \
        libffi-dev \
        gcc \
        musl-dev \
        libxml2-dev \
        libxslt-dev 
RUN apk add --no-cache $(echo $(cat /nastool-lite/server/package_list.txt))
RUN python -V

RUN apk add nodejs npm
RUN apk add nginx envsubst

RUN npm install -g pm2 
# \ --registry=https://registry.npmmirror.com

WORKDIR /nastool-lite/web
RUN npm install 
# --registry=https://registry.npmmirror.com
RUN npm run build

WORKDIR /nastool-lite/server
RUN python -m venv .venv
ENV PATH="/nastool-lite/server/.venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel 
# --index-url="https://mirrors.aliyun.com/pypi/simple/"
RUN pip install cython 
# --index-url="https://mirrors.aliyun.com/pypi/simple/"

RUN pip install -r requirements.txt 
# --index-url="https://mirrors.aliyun.com/pypi/simple/"

EXPOSE 3000

WORKDIR /nastool-lite/
COPY ./entrypoint.sh ./
COPY ./pm2_config.js ./ecosystem.config.js

COPY nginx.conf.template /etc/nginx/

RUN chown root:root /nastool-lite -Rf
RUN chmod 770 /nastool-lite -Rf

ENV NGINX_PORT=3000
ENV PUID=0
ENV GUID=0

ENTRYPOINT ["bash", "entrypoint.sh" ]