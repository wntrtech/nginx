FROM nginx:1.29.4-alpine

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
    chown -R nginx:nginx /usr/share/nginx/html/

USER nginx:nginx

EXPOSE 8080

HEALTHCHECK --start-period=20s --start-interval=5s --interval=1m --timeout=10s --retries=5 CMD curl --fail -s http://localhost:8080 || exit 1
