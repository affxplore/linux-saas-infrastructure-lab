# Operations Runbook & Troubleshooting Guide

## Daily Health Check Commands
- **Check All Docker Services:** `docker compose ps`
- **Check Nginx Status:** `sudo systemctl status nginx`
- **Check System Memory & Swap:** `free -h`
- **Check Disk Space:** `df -h /`
- **Check UFW Firewall Rules:** `sudo ufw status`

---

## Standard Emergency Procedures

### 1. INC-001: Nginx Service Outage
**Symptom:** Clients get `ERR_CONNECTION_REFUSED`, Uptime Kuma triggers DOWN alert.
```bash
# Verify process status and port binding
sudo systemctl status nginx
sudo ss -tulpn | grep -E ':80|:443'

# Test configuration syntax before starting
sudo nginx -t

# Restart Nginx service
sudo systemctl start nginx
2. INC-002: Application Container Crash / Unresponsive
Symptom: Nginx returns 502 Bad Gateway, Prometheus target saas-app reports DOWN.

# Check container status and exit code
docker ps -a | grep saas-app

# Inspect application container logs for fatal errors
docker logs --tail 50 saas-app

# Restart application container
docker compose restart saas-app
3. INC-003: MySQL Database Service Interruption
Symptom: Application throws database connection errors / timeouts.

# Check container status
docker ps | grep mysql-db

# Inspect running MySQL threads and queries
docker exec -it mysql-db mysql -uroot -psupersecretrootpass -e "SHOW FULL PROCESSLIST;"

# Restart database service safely
docker compose restart mysql-db

# If data is corrupted, restore from latest backup
LATEST_BACKUP=$(ls -t /opt/backups/*.tar.gz | head -n 1)
~/linux-saas-infrastructure-lab/backup/restore-mysql.sh ${LATEST_BACKUP}
4. INC-004: High CPU / Memory Exhaustion
Symptom: Grafana CPU/RAM spikes to 100%, API latency increases.

# Identify top resource-consuming processes
ps aux --sort=-%cpu | head -n 10
ps aux --sort=-%mem | head -n 10

# Kill rogue/hung process if necessary
sudo kill -9 <PID>

# Clear OS page cache safely
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
5. INC-005: Disk Space Depletion
Symptom: Write operations fail, Grafana disk metric < 5% free.

# Inspect disk usage
df -h /

# Locate top 10 largest files/directories
sudo du -ah / 2>/dev/null | sort -rh | head -n 10

# Clean up Docker system resources and log files
docker system prune -f
sudo logrotate -f /etc/logrotate.d/nginx-saas
6. INC-006: Nginx Routing / Misconfiguration Error
Symptom: HTTP 502 Bad Gateway while backend containers are UP.

# Test Nginx configuration for syntax errors
sudo nginx -t

# Inspect Nginx error logs for invalid upstream routing
sudo tail -n 20 /var/log/nginx/saas_error.log

# Fix configuration in /etc/nginx/sites-available/saas-app.conf and reload
sudo systemctl reload nginx
