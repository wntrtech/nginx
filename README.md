# nginx

Nginx server for static resources

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
