#!/bin/bash
# Integrated Log Analyzer & Streamer

echo "=========================================="
echo "      SAAS INFRASTRUCTURE LOG VIEWER     "
echo "=========================================="
echo "1. Stream Nginx Access Logs (Live)"
echo "2. Stream Nginx Error Logs (Live)"
echo "3. Stream SaaS Application Container Logs"
echo "4. Stream MySQL Container Logs"
echo "5. View UFW Firewall Dropped Packets"
echo "=========================================="
read -p "Select Log Stream [1-5]: " CHOICE

case $CHOICE in
    1) tail -f /var/log/nginx/saas_access.log ;;
    2) tail -f /var/log/nginx/saas_error.log ;;
    3) docker logs -f saas-app ;;
    4) docker logs -f mysql-db ;;
    5) sudo dmesg -T | grep -i ufw ;;
    *) echo "Invalid option." ;;
esac
