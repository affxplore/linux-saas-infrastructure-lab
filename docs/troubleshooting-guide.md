# Operations Runbook & Troubleshooting Guide

## Daily Health Check Commands
- **Check All Docker Services:** `docker compose ps`
- **Check Nginx Status:** `sudo systemctl status nginx`
- **Check System Memory & Swap:** `free -h`
- **Check Disk Space:** `df -h /`
- **Check UFW Firewall Rules:** `sudo ufw status`

---

## Standard Emergency Procedures

### 1. High Memory / Swap Exhaustion
```bash
# Identify memory-hungry processes
ps aux --sort=-%mem | head -n 10
# Clear page cache safely
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
# Inspect running MySQL threads
docker exec -it mysql-db mysql -uroot -psupersecretrootpass -e "SHOW FULL PROCESSLIST;"
# Restart MySQL service safely
docker compose restart mysql-db
# Verify process holding port 80/443
sudo ss -tulpn | grep -E ':80|:443'
# Reload Nginx gracefully
sudo nginx -t && sudo systemctl reload nginx
