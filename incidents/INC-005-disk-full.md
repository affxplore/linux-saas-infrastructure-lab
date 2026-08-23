# Incident Report: INC-005 (Disk Storage Exhaustion)

- **Date/Time:** 2026-08-23
- **Severity:** Critical (P1)
- **Impact:** Database write failures and inability to write system logs.

## Symptom
Grafana disk space metric dropped below 5% available. Docker containers failed to write data.

## Root Cause
Large dummy file creation or unrotated log buildup in `/tmp` or `/var/log`.

## Detection & Investigation
- Executed `df -h /` confirming 95%+ usage.
- Located large files via `du -ah / 2>/dev/null | sort -rh | head -n 10`.

## Remediation & Recovery
- Removed offending file: `rm -f /tmp/dummy_large_file.img`.
- Triggered manual log rotation: `sudo logrotate -f /etc/logrotate.d/nginx-saas`.

## Prevention
Enforced Docker daemon log caps (`max-size: 10m`) and automated logrotate policies.
