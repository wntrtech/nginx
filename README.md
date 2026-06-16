# nginx

Nginx server for static resources

## What's in the image

- Based on `nginx:alpine`, runs as `nginx:nginx` (non-root) on `:8080`.
- Timezone: `Europe/Riga` (override with build-arg `TZ`).
- `/etc/nginx/conf.d/default.conf` — server on `:8080` serving
  `/usr/share/nginx/html`, with `server_tokens off`, `http2 on`, and
  `/healthz` included.
- `/etc/nginx/snippets/healthz.conf` — reusable `location = /healthz`
  snippet (`access_log off`, returns `200 {"status":"pass"}` as
  `application/json`).
- `HEALTHCHECK` — `curl --fail http://127.0.0.1:8080/healthz`.
- Entrypoint script `99_usermode.sh` — rewrites `:80` → `:8080` in any
  `default.conf` that still uses port 80 and removes `user nginx;` from
  `nginx.conf` for rootless operation.

## Usage

### Serve static content

Drop your build output into `/usr/share/nginx/html`. Health check, port,
and serving config are already wired:

```dockerfile
FROM ghcr.io/wntrtech/nginx:latest
COPY --chown=nginx:nginx dist/ /usr/share/nginx/html
```

### Serve static content with a custom server config

Ship your own `default.conf` (CSP, SPA fallback, env-substitution,
caching, etc.) and `include` the healthz snippet so the image's
`HEALTHCHECK` keeps working unchanged:

```nginx
# default.conf
server {
    listen      8080;
    listen [::]:8080;
    server_name localhost;
    server_tokens off;
    http2 on;

    include /etc/nginx/snippets/healthz.conf;

    location / {
        root  /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```

```dockerfile
FROM ghcr.io/wntrtech/nginx:latest
COPY --chown=nginx:nginx dist/        /usr/share/nginx/html
COPY --chown=nginx:nginx default.conf /etc/nginx/conf.d/default.conf
```

### Kubernetes probes

Point `httpGet` probes at `path: /healthz`, `port: 8080`.

## Tests

In order to test vulnerabilities, before you pushing your changes, run:

powershell:

```powershell
docker build -t test-app -f Dockerfile . ; docker save test-app -o test_docker_img.tar ; docker rmi test-app ; docker run --rm -v "$PWD`:/workdir" aquasec/trivy:latest image --exit-code 0 --severity UNKNOWN,LOW,MEDIUM --input /workdir/test_docker_img.tar ; docker run --rm -v "$PWD`:/workdir" aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL --input /workdir/test_docker_img.tar
```

bash:

```bash
docker build -t test-app -f Dockerfile . \
  && docker save test-app -o test_docker_img.tar \
  && docker rmi test-app \
  && docker run --rm -v "$(pwd):/workdir" aquasec/trivy:latest image --exit-code 0 --severity UNKNOWN,LOW,MEDIUM --input /workdir/test_docker_img.tar \
  && docker run --rm -v "$(pwd):/workdir" aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL --input /workdir/test_docker_img.tar
```
