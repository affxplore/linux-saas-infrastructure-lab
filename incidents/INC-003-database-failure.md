# Incident Report: INC-003 (MySQL Database Disruption)

- **Date/Time:** 2026-08-23
- **Severity:** High (P2)
- **Impact:** Application backend unable to process queries or persist data.

## Symptom
Application backend thrown internal database connection errors.

## Root Cause
`mysql-db` container unreachable over `app-network`.

## Detection & Investigation
- Tested connection: `docker exec -it saas-app python -c "import mysql.connector..."` -> Connection Refused.
- Verified Docker logs: `docker logs mysql-db`.

## Remediation & Recovery
- Restarted container: `docker start mysql-db`.
- Verified DB state using `./backup/restore-mysql.sh` if table corruption occurred.

## Prevention
Set up automatic health check probes on MySQL container in `docker-compose.yml`.
