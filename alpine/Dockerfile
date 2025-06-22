ARG BASEIMAGE_VERSION=1.25.3.2-5-

FROM openresty/openresty:${BASEIMAGE_VERSION}alpine-fat AS builder

RUN apk add --update --no-cache \
    bash \
    curl \
    git \
#    openldap-dev \
    openssl \
    pcre-dev \
    sudo \
    wget

ARG APISIX_VERSION=3.7.0

RUN cd ~ \
    && curl -s https://github.com/apache/apisix/archive/refs/tags/$APISIX_VERSION.tar.gz -L -o $APISIX_VERSION.tar.gz \
    && mkdir -p /usr/local/src \
    && tar -xzvf $APISIX_VERSION.tar.gz -C /usr/local/src \
    && rm -f $APISIX_VERSION.tar.gz

# remove archived lualdap dependency
RUN sed -i.bak '/^    "lualdap = 1.2.6-1",$/d' /usr/local/src/apisix-$APISIX_VERSION/rockspec/apisix-$APISIX_VERSION-0.rockspec \
    && sed -i.bak '/^    "lualdap = 1.2.6-1",$/d' /usr/local/src/apisix-$APISIX_VERSION/rockspec/apisix-master-0.rockspec

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh -s -- -y \
    && source "$HOME/.cargo/env"

RUN cd /usr/local/src/apisix-$APISIX_VERSION \
    && ./utils/install-dependencies.sh \
    && . "$HOME/.cargo/env" \
    && make deps \
    && make install \
    && cp -R apisix /usr/local/apisix \
    && cp -R deps /usr/local/apisix \
    && cd / \
    && rm -Rf /usr/local/src

FROM openresty/openresty:${BASEIMAGE_VERSION}alpine AS runtime

RUN apk add --update --no-cache \
    bash \
#    openldap \
    openssl \
    pcre

COPY --from=builder /usr/local/apisix /usr/local/apisix
COPY --from=builder /usr/local/openresty /usr/local/openresty
COPY --from=builder /usr/bin/apisix /usr/bin/apisix

WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

RUN addgroup --system --gid 636 apisix \
    && adduser -S -G apisix -H --shell /usr/sbin/nologin -u 636 apisix \
    && chown -R apisix:apisix /usr/local/apisix

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

EXPOSE 9080 9443

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["docker-start"]

STOPSIGNAL SIGQUIT
