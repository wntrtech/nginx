FROM nginx:1.31.1-alpine

ARG TZ='Europe/Riga'
ENV DEFAULT_TZ=${TZ} \
    LC_ALL=lv_LV.UTF-8 \
    LANG=lv_LV.UTF-8

COPY --chown=nginx:nginx 99_usermode.sh /docker-entrypoint.d/
COPY --chown=nginx:nginx snippets/ /etc/nginx/snippets/
COPY --chown=nginx:nginx default.conf /etc/nginx/conf.d/default.conf

RUN cp /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime && \
    chmod +x /docker-entrypoint.d/99_usermode.sh && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/run/ && \
    chown -R nginx:nginx /etc/nginx/ && \
    chown -R nginx:nginx /usr/share/nginx/html/  && \
    apk add --no-cache \
      libcrypto3=3.5.7-r0 \
      libssl3=3.5.7-r0 \
      musl=1.2.5-r23 \
      musl-utils=1.2.5-r23 \
      nghttp2=1.69.0-r0 \
      nghttp2-libs=1.69.0-r0 \
      libxml2=2.13.9-r1 \
      libxpm=3.5.19-r0 \
      xz-libs=5.8.3-r0 \
      zlib=1.3.2-r0
      
USER nginx:nginx

EXPOSE 8080

HEALTHCHECK --start-period=90s --start-interval=2s --interval=30s --timeout=3s --retries=3 CMD curl --fail -s http://127.0.0.1:8080/healthz || exit 1
