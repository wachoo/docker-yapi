FROM node:11-alpine as builder

COPY repositories /etc/apk/repositories
RUN apk update && apk add --no-cache  git python make openssl tar gcc
ADD yapi.tar.gz /home/
RUN ls /home/
RUN mkdir -p /api/vendors && mv /home/yapi*/* /api/vendors
RUN ls /api/vendors
RUN cd /api/vendors && npm install --production --registry https://registry.npm.taobao.org

FROM node:11-alpine

MAINTAINER wachoo
ENV TZ="Asia/Shanghai" HOME="/"
WORKDIR ${HOME}

COPY --from=builder /api/vendors /api/vendors
COPY config.json /api/
EXPOSE 3001

COPY docker-entrypoint.sh /api/
RUN chmod 755 /api/docker-entrypoint.sh

ENTRYPOINT ["/api/docker-entrypoint.sh"]




