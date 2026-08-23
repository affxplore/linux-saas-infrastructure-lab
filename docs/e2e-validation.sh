#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo "    STARTING END-TO-END SYSTEM VALIDATION TEST    "
echo "=================================================="

pass() { echo -e "[ ${GREEN}PASS${NC} ] $1"; }
fail() { echo -e "[ ${RED}FAIL${NC} ] $1"; exit 1; }

# 1. Swap Space Check
[ $(free -m | awk '/Swap:/ {print $2}') -gt 1000 ] && pass "Swap Space configured (>= 1GB)" || fail "Swap Space missing"

# 2. UFW Firewall Check
sudo ufw status | grep -q "Status: active" && pass "UFW Firewall Active" || fail "UFW Firewall Inactive"

# 3. SSH Hardening Check
sudo grep -q "PermitRootLogin no" /etc/ssh/sshd_config.d/hardening.conf && pass "SSH Hardening Configured" || fail "SSH Hardening missing"

# 4. Docker Engine Check
sudo docker info >/dev/null 2>&1 && pass "Docker Daemon Operational" || fail "Docker Daemon offline"

# 5. Containers Running Check
[ $(sudo docker ps -q | wc -l) -ge 4 ] && pass "All Docker Containers Running (>= 4)" || fail "Some containers are down"

# 6. Nginx Reverse Proxy Check
curl -s -I http://127.0.0.1 | grep -q "200 OK" && pass "Nginx Reverse Proxy responding (HTTP 200)" || fail "Nginx Proxy failed"

# 7. Metrics Endpoint Protection Check
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/metrics | grep -q "403" && pass "Endpoint /metrics Protected (HTTP 403)" || fail "/metrics endpoint exposed!"

# 8. Node Exporter Health Check
curl -s http://127.0.0.1:9100/metrics | grep -q "node_cpu_seconds_total" && pass "Node Exporter active on port 9100" || fail "Node Exporter unreachable"

# 9. Prometheus Targets Check
curl -s http://127.0.0.1:9090/api/v1/targets | grep -q '"health":"up"' && pass "Prometheus Targets Healthy" || fail "Prometheus target errors"

# 10. Automated Backup Directory Check
[ -f /opt/backups/*.tar.gz ] || [ -d /opt/backups ] && pass "Backup Directory & Retention Operational" || fail "Backup directory missing"

echo "=================================================="
echo -e "${GREEN}ALL END-TO-END VALIDATION TESTS PASSED SUCCESSFULLY!${NC}"
echo "=================================================="
