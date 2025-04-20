FROM alpine:latest

RUN apk add --update --no-cache \
    inotify-tools bash yq

COPY ./entrypoint.sh /entrypoint.sh

RUN set -eux; \
  addgroup -g 1000 yq; \
  adduser -u 1000 -G yq -s /bin/sh -h /home/yq -D yq

RUN chown yq:yq /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER yq

ENTRYPOINT ["/entrypoint.sh"]
