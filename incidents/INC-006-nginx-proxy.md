# Incident Report: INC-006 (Nginx Misconfiguration / Misrouting)

- **Date/Time:** 2026-08-23
- **Severity:** High (P2)
- **Impact:** HTTP 502 Bad Gateway served to end users due to invalid upstream port.

## Symptom
Public access resulted in 502 status despite backend containers being healthy.

## Root Cause
Syntax error or invalid upstream target port inside `/etc/nginx/sites-available/saas-app.conf`.

## Detection & Investigation
- Ran Nginx config test: `sudo nginx -t`.
- Inspected error log: `tail -f /var/log/nginx/saas_error.log` showing `connect() failed to 127.0.0.1:8001`.

## Remediation & Recovery
- Corrected port mapping from 8001 back to 8000 in config file.
- Reloaded Nginx service: `sudo systemctl reload nginx`.

## Prevention
Mandated running `sudo nginx -t` prior to executing any `systemctl reload nginx` in deployment pipelines.
