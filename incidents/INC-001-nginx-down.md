# Incident Report: INC-001 (Nginx Web Server Outage)

- **Date/Time:** 2026-08-23
- **Severity:** Critical (P1)
- **Impact:** Total loss of external connectivity to all hosted applications.

## Symptom
Clients received `ERR_CONNECTION_REFUSED`. Uptime Kuma triggered a DOWN alert.

## Root Cause
Nginx process stopped or failed to launch on host OS.

## Detection & Investigation
- `systemctl status nginx` showed `inactive (dead)`.
- Port 80/443 listened by no process (`ss -tulpn | grep :80`).

## Remediation & Recovery
- Executed `sudo systemctl start nginx`.
- Validated service state via `curl -I http://127.0.0.1`.

## Prevention
Configured `systemctl enable nginx` and set up auto-restart policies on systemd failure.
