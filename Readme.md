# Nginx source build with docker including health_check, GeoIP2 and VTS

## Requirement

You will need to replace the environment variable name LICENSE_KEY_FOR_GEOIP at line not 13 at the Dockerfile with your won license key.

To obtain the GeoIP2 license you will need to visit <https://www.maxmind.com/en/home>

## Build instruction

`docker build -t nginx-with-health-check-geoip2-vts:latest .`

## Run instruction

`docker-compose up`

## Observation

```
Health check status: http://localhost/status
VTS dashboard: http://localhost:11050/status
VTS Status in JSON: http://localhost:11050/status-json
```
