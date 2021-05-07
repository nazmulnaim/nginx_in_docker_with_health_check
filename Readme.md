# Nginx source build with docker including health_check and VTS

## Build instruction

`docker build -t nginx-with-health-check-vts:latest .`

## Run instruction

`docker-composer up`

## Observation

```
Health check status: http://localhost/status
VTS dashboard: http://localhost:11050/status
VTS Status in JSON: http://localhost:11050/status-json
```
