FROM nginx:1.29.3-alpine

ARG TZ='Europe/Riga'
ENV DEFAULT_TZ=${TZ} \
    LC_ALL=lv_LV.UTF-8 \
    LANG=lv_LV.UTF-8

COPY --chown=nginx:nginx 99_usermode.sh /docker-entrypoint.d/

RUN cp /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime && \
    chmod +x /docker-entrypoint.d/99_usermode.sh && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/run/ && \
    chown -R nginx:nginx /etc/nginx/ && \
    chown -R nginx:nginx /usr/share/nginx/html/ && \
    apk add --no-cache \
      pcre2=10.46-r0 \
      libpng=1.6.51-r0 \
      busybox=1.37.0-r20

USER nginx:nginx

EXPOSE 8080

HEALTHCHECK --start-period=20s --start-interval=5s --interval=1m --timeout=10s --retries=5 CMD curl --fail -s http://localhost:8080 || exit 1
