# Incident Report: INC-004 (Sustained High CPU Load)

- **Date/Time:** 2026-08-23
- **Severity:** Medium (P3)
- **Impact:** Increased API latency and degraded application responsiveness.

## Symptom
Grafana CPU usage panel spiked to 100%. Node Exporter triggered high usage metric.

## Root Cause
Rogue process or load spike consuming CPU cycles (`stress-ng` simulation).

## Detection & Investigation
- Ran `top -b -n 1` to isolate top consuming processes.
- Identified PID consuming maximum CPU % via `ps aux --sort=-%cpu`.

## Remediation & Recovery
- Terminated rogue process: `sudo killall stress-ng`.
- CPU usage normalized below 10%.

## Prevention
Configured container CPU resource limits (`cpus: '1.0'`) in `docker-compose.yml`.
