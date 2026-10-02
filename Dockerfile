FROM nginx:1.31.6-alpine

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
    apk upgrade --no-cache

USER 101:101

EXPOSE 8080

HEALTHCHECK --start-period=90s --start-interval=2s --interval=30s --timeout=3s --retries=3 CMD ["/bin/sh", "-c", "curl --fail -s http://127.0.0.1:8080/healthz || exit 1"]
