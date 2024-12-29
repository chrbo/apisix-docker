FROM  --platform=linux/amd64 mikefarah/yq:latest

USER root

RUN apk add --update --no-cache \
    inotify-tools bash

COPY ./entrypoint.sh /entrypoint.sh

RUN chown yq:yq /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER yq

ENTRYPOINT ["/entrypoint.sh"]
