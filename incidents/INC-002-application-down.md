# Incident Report: INC-002 (SaaS Application Container Failure)

- **Date/Time:** 2026-08-23
- **Severity:** High (P2)
- **Impact:** Public traffic received 502 Bad Gateway.

## Symptom
Nginx return `502 Bad Gateway`. Prometheus target `saas-app` reported `DOWN`.

## Root Cause
The `saas-app` Docker container crashed or was stopped manually.

## Detection & Investigation
- Examined Nginx error log: `tail -n 20 /var/log/nginx/saas_error.log` showing `connect() failed (111: Connection refused)`.
- Checked container state: `docker ps -a` showed `Exited (137)`.

## Remediation & Recovery
- Restored service via `docker start saas-app`.
- Verified health endpoint: `curl http://127.0.0.1:8000`.

## Prevention
Enforced `restart: always` in `docker-compose.yml`.
