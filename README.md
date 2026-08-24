I analyzed the complete project configuration document, including the 16 phases, monitoring stack, backup/restore workflow, incident simulations, incident reports, operations runbook, and final E2E validation. The source establishes the project as an AWS EC2-based Linux SaaS infrastructure lab using Docker Compose, Nginx, MySQL, Prometheus, Grafana, Node Exporter, Uptime Kuma, automated backup/restore, centralized log inspection, incident simulation, and operational validation.  

I have **redacted credentials and the example Elastic IP** in the README rather than reproducing them. The source itself contains hard-coded credentials, so those should be treated as secrets and replaced with environment-specific values. 

# Linux SaaS Infrastructure Monitoring & Operations Lab

A hands-on Linux infrastructure and operations lab that provisions an AWS EC2 server, applies Linux security hardening, deploys a containerized SaaS application and MySQL database, exposes services through an Nginx reverse proxy, implements infrastructure monitoring with Prometheus and Grafana, performs synthetic availability monitoring with Uptime Kuma, automates database backup and recovery, centralizes operational log inspection, and validates incident-response procedures through controlled failure simulations.

---

## Overview

This project demonstrates the end-to-end operation of a small SaaS infrastructure environment on **AWS EC2**.

The infrastructure is intentionally designed around a single Ubuntu server and separates public-facing traffic from internal application, database, and monitoring services.

The project covers:

* AWS EC2 provisioning
* Security Group configuration
* Elastic IP association
* Ubuntu Server hardening
* Swap configuration
* UFW firewall configuration
* SSH hardening
* Docker Engine and Docker Compose V2
* Containerized Python SaaS application
* MySQL database
* Nginx reverse proxy
* Prometheus monitoring
* Node Exporter
* Grafana operational dashboards
* Uptime Kuma synthetic monitoring
* Automated MySQL backup
* Database disaster recovery
* Nginx and Docker log rotation
* Centralized log inspection
* Docker network tracing
* Controlled incident simulations
* Incident response methodology
* Incident report documentation
* Operations troubleshooting runbook
* End-to-end infrastructure validation

The source configuration uses the following logical deployment flow:

```text
Internet
   |
   | HTTP :80 / HTTPS :443
   v
+---------------------------+
| AWS EC2                   |
| Ubuntu Server 24.04 LTS   |
|                           |
| +-----------------------+ |
| | Nginx Reverse Proxy   | |
| +-----------+-----------+ |
|             |
|     +-------+--------+
|     |                |
|     v                v
|  SaaS App          Monitoring UI
|  :8000             /grafana/
|                    /kuma/
|     |
|     v
|  MySQL
|  :3306 internal
|
| Monitoring:
|   Node Exporter :9100
|          |
|          v
|     Prometheus :9090
|          |
|          v
|       Grafana
|
| Availability:
|   Uptime Kuma :3001
|
| Backup:
|   mysqldump -> /opt/backups
+---------------------------+
```

The project keeps application, database, and monitoring ports bound to localhost or internal Docker networks rather than exposing them directly through the AWS Security Group. 

---

## Objectives

### Infrastructure

* Provision an AWS EC2 instance.
* Configure network access through an AWS Security Group.
* Associate an Elastic IP.
* Establish SSH access.

### Security

* Configure a 2 GB swap file.
* Configure UFW.
* Disable SSH password authentication.
* Disable direct root login.
* Limit SSH authentication attempts.
* Keep internal application and monitoring ports inaccessible from the public network.

### Application

* Deploy a Python/Flask SaaS application.
* Connect the application to MySQL.
* Expose the application through Nginx.

### Monitoring

* Collect host metrics with Node Exporter.
* Collect application and host metrics with Prometheus.
* Visualize metrics through Grafana.
* Monitor public application availability using Uptime Kuma.

### Operations

* Automate MySQL backups.
* Provide database restoration tooling.
* Configure scheduled backups.
* Implement log rotation.
* Provide centralized log inspection.
* Trace Docker network connectivity.
* Simulate infrastructure incidents.
* Document incident response.
* Perform end-to-end validation.

---

## Architecture

### High-Level Architecture

```text
                         Internet
                            |
                            v
                 +---------------------+
                 |   AWS Security      |
                 |      Group          |
                 |                    |
                 |  SSH  :22          |
                 |  HTTP :80          |
                 |  HTTPS:443         |
                 +----------+----------+
                            |
                            v
                 +---------------------+
                 | AWS EC2             |
                 | saas-infra-node-01  |
                 | Ubuntu 24.04 LTS    |
                 +----------+----------+
                            |
                            v
                 +---------------------+
                 | Nginx Reverse Proxy |
                 +----------+----------+
                            |
          +-----------------+------------------+
          |                 |                  |
          v                 v                  v
       /                  /grafana/          /kuma/
       |                    |                  |
       v                    v                  v
+-------------+      +-------------+    +-------------+
| SaaS App    |      | Grafana     |    | Uptime Kuma |
| :8000       |      | :3000       |    | :3001       |
+------+------+      +------+------+    +-------------+
       |
       v
+-------------+
| MySQL :3306 |
+-------------+

Monitoring flow:

+--------------+       +-------------+       +----------+
| Node Exporter| ----> | Prometheus  | ----> | Grafana  |
| Host metrics |       | :9090       |       | Dashboard|
+--------------+       +-------------+       +----------+
                              ^
                              |
                         SaaS App
                         /metrics
```

---

## Architecture Components

| Component               | Role                                                 |
| ----------------------- | ---------------------------------------------------- |
| AWS EC2                 | Hosts the infrastructure                             |
| Ubuntu Server 24.04 LTS | Operating system                                     |
| AWS Security Group      | Cloud-level network access control                   |
| Elastic IP              | Stable public IP address                             |
| UFW                     | Host-level firewall                                  |
| OpenSSH                 | Remote administration                                |
| Docker Engine           | Container runtime                                    |
| Docker Compose V2       | Container orchestration                              |
| Python 3.11             | Application runtime                                  |
| Flask                   | SaaS application framework                           |
| Gunicorn                | Application WSGI server                              |
| MySQL 8.0               | Database                                             |
| Nginx                   | Reverse proxy                                        |
| Node Exporter           | Host metrics exporter                                |
| Prometheus              | Metrics collection                                   |
| Grafana                 | Metrics visualization                                |
| Uptime Kuma             | Synthetic availability monitoring                    |
| Bash                    | Backup, restore, validation, and operational scripts |
| Cron                    | Scheduled database backups                           |
| Logrotate               | Log retention and rotation                           |

---

## Infrastructure Specifications

The documented EC2 configuration is:

| Resource      | Configuration           |
| ------------- | ----------------------- |
| Instance name | `saas-infra-node-01`    |
| OS            | Ubuntu Server 24.04 LTS |
| Architecture  | 64-bit x86              |
| Instance type | `t3.small`              |
| CPU           | 2 vCPU                  |
| RAM           | 2 GB                    |
| Root volume   | 20 GB gp3               |
| Public IP     | Elastic IP              |
| SSH user      | `ubuntu`                |

The documentation also notes that a 1 GB RAM instance requires a 2 GB swap file when running Docker, MySQL, and Prometheus together. 

---

## Network and Port Design

### AWS Security Group

Only the following inbound ports are intended to be publicly accessible:

| Port | Protocol | Source            | Purpose |
| ---: | -------- | ----------------- | ------- |
|   22 | TCP      | My IP recommended | SSH     |
|   80 | TCP      | `0.0.0.0/0`       | HTTP    |
|  443 | TCP      | `0.0.0.0/0`       | HTTPS   |

The documentation explicitly states that internal ports such as `3306`, `8000`, `9090`, `3000`, and `3001` should not be opened in the AWS Security Group. 

### Internal Services

| Service          | Port | Exposure                   |
| ---------------- | ---: | -------------------------- |
| SaaS application | 8000 | Host localhost             |
| Prometheus       | 9090 | Host localhost             |
| Grafana          | 3000 | Host localhost             |
| Uptime Kuma      | 3001 | Host localhost             |
| Node Exporter    | 9100 | Host localhost             |
| MySQL            | 3306 | Docker application network |

This design allows Nginx to act as the public entry point while the application and monitoring services remain behind the reverse proxy.

---

# Deployment

## Phase 1 — AWS EC2 Provisioning & Networking

### 1. Create the Security Group

Create:

```text
sg-saas-lab
```

Configure inbound rules:

```text
SSH     TCP 22   My IP
HTTP    TCP 80   0.0.0.0/0
HTTPS   TCP 443  0.0.0.0/0
```

Keep outbound access at the documented default so the server can download packages and Docker images. 

### 2. Launch EC2

Use:

```text
Name:          saas-infra-node-01
AMI:           Ubuntu Server 24.04 LTS
Instance:      t3.small
Storage:       20 GB gp3
Public IP:     Enabled
Security Group: sg-saas-lab
```

### 3. Associate Elastic IP

Allocate an Elastic IP from the Amazon IPv4 pool and associate it with:

```text
saas-infra-node-01
```

Store the resulting address as:

```text
YOUR_EC2_IP
```

The Elastic IP provides a stable address for public access after server restarts. 

### 4. Test SSH

On the local machine:

```bash
chmod 400 /path/to/your-key.pem

ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP
```

---

# Phase 2 — Ubuntu Server Hardening

## 1. Configure 2 GB Swap

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

free -h
```

Verify that the `Swap` row reports approximately:

```text
2.0Gi
```

The swap configuration is intended to reduce the risk of OOM conditions while multiple infrastructure services are running. 

---

## 2. Configure UFW

Set the default policies:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Allow the public services:

```bash
sudo ufw allow 22/tcp comment 'SSH Port'
sudo ufw allow 80/tcp comment 'HTTP Nginx'
sudo ufw allow 443/tcp comment 'HTTPS Nginx'
```

Enable and verify:

```bash
sudo ufw enable
sudo ufw status verbose
```

---

## 3. Harden SSH

Create the custom configuration:

```bash
sudo mkdir -p /etc/ssh/sshd_config.d/
```

Create:

```text
/etc/ssh/sshd_config.d/hardening.conf
```

with:

```text
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 3
```

Validate before restarting SSH:

```bash
sudo sshd -t
```

Then:

```bash
sudo systemctl restart ssh
```

**Important:** Keep the existing SSH session open until a new SSH session has been successfully tested. 

---

# Phase 3 — Validation After Hardening

Open a new terminal and verify SSH access:

```bash
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP
```

Do not close the original session until the new connection is confirmed.

---

# Phase 4 — Docker Engine & Docker Compose V2

Install dependencies:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
```

Configure the Docker keyring:

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Add the Docker repository:

```bash
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker:

```bash
sudo apt-get update

sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

Allow the `ubuntu` user to execute Docker without `sudo`:

```bash
sudo usermod -aG docker ubuntu
newgrp docker
```

Verify:

```bash
docker --version
docker compose version
```

---

# Phase 5 — SaaS Application & MySQL

Create the project directory:

```bash
mkdir -p ~/linux-saas-infrastructure-lab/docker
cd ~/linux-saas-infrastructure-lab/docker
```

## Environment Configuration

Create `.env`:

```env
DB_ROOT_PASSWORD=<YOUR_DB_ROOT_PASSWORD>
DB_NAME=saasdb
DB_USER=saasuser
DB_PASSWORD=<YOUR_DB_PASSWORD>
```

Do not commit `.env` to a public repository.

---

## Docker Compose Architecture

The stack contains:

```text
saas-app
mysql-db
prometheus
grafana
node-exporter
uptime-kuma
```

The application and MySQL use `app-network`.

Monitoring services use `monitoring-net`.

The application connects to MySQL using the Docker DNS hostname:

```text
mysql-db
```

The application exposes:

```text
127.0.0.1:8000 -> container:8000
```

Prometheus:

```text
127.0.0.1:9090 -> container:9090
```

Grafana:

```text
127.0.0.1:3000 -> container:3000
```

Uptime Kuma:

```text
127.0.0.1:3001 -> container:3001
```

The application provides:

```text
GET /
GET /metrics
```

The `/` endpoint returns:

```text
SaaS Application Running Successfully!
```

The `/metrics` endpoint exposes Prometheus metrics, including the application request counter. 

### Deploy

```bash
docker compose up -d
```

### Verify

```bash
docker compose ps
```

Test the application:

```bash
curl http://127.0.0.1:8000
```

Expected response:

```text
SaaS Application Running Successfully!
```

Test metrics:

```bash
curl http://127.0.0.1:8000/metrics
```

Test the application-to-database connection:

```bash
docker exec -it saas-app python -c "
import mysql.connector
conn = mysql.connector.connect(
    host='mysql-db',
    user='saasuser',
    password='<YOUR_DB_PASSWORD>',
    database='saasdb'
)
print('Database Connection Successful!')
"
```

---

# Phase 6 — Nginx Reverse Proxy

Install Nginx:

```bash
sudo apt-get update
sudo apt-get install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx

sudo systemctl status nginx --no-pager
```

Remove the default site:

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

Create:

```text
/etc/nginx/sites-available/saas-app.conf
```

The primary routing model is:

```text
Internet
   |
   v
Nginx :80
   |
   v
127.0.0.1:8000
   |
   v
SaaS App
```

The main application route uses:

```nginx
location / {
    proxy_pass http://127.0.0.1:8000;
}
```

The `/metrics` endpoint is explicitly denied:

```nginx
location /metrics {
    deny all;
    return 403;
}
```

Validate before reload:

```bash
sudo nginx -t
```

Then:

```bash
sudo systemctl reload nginx
```

Test locally:

```bash
curl -I http://127.0.0.1
curl -I http://127.0.0.1/metrics
```

The application should be reachable through:

```text
http://YOUR_EC2_IP
```

The expected application response is:

```text
SaaS Application Running Successfully!
```

The reverse-proxy and `/metrics` protection configuration are documented in the source. 

---

# Phase 7 — Node Exporter & Prometheus

## Node Exporter

Create a dedicated system user:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
```

Download the documented Node Exporter release:

```bash
cd /tmp

curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
```

Install the binary:

```bash
sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

Create:

```text
/etc/systemd/system/node_exporter.service
```

with:

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

Verify:

```bash
curl -s http://127.0.0.1:9100/metrics | head -n 10
```

The documented Node Exporter configuration binds it to localhost on port `9100`. 

---

## Prometheus Configuration

Create:

```text
~/linux-saas-infrastructure-lab/docker/monitoring/prometheus
```

Then create:

```text
prometheus.yml
```

with:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'saas-app'
    static_configs:
      - targets: ['saas-app:8000']
```

Prometheus therefore monitors:

```text
node-exporter:9100
saas-app:8000
```

The documented scrape interval is 15 seconds. 

Deploy:

```bash
cd ~/linux-saas-infrastructure-lab/docker
docker compose up -d
```

Verify:

```bash
docker compose ps prometheus

curl -s http://127.0.0.1:9090/api/v1/targets \
  | grep -E '"job"|"health"'
```

Expected target health:

```text
"health": "up"
```

for:

```text
node-exporter
saas-app
```

---

# Phase 8 — Grafana Operational Dashboard

Grafana runs on:

```text
127.0.0.1:3000
```

and is exposed publicly through:

```text
/grafana/
```

The Grafana container is configured for sub-path operation.

Access:

```text
http://YOUR_EC2_IP/grafana/
```

The source uses an initial administrative account. For a repository README, credentials are intentionally represented as placeholders rather than stored values.

---

## Add Prometheus Data Source

Inside Grafana:

1. Open **Connections**.
2. Select **Data sources**.
3. Select **Add data source**.
4. Choose **Prometheus**.
5. Use the Docker-internal Prometheus URL:

```text
http://prometheus:9090
```

6. Select **Save & test**.

The expected result is:

```text
Data source is working
```

The documented Grafana configuration uses the internal Docker DNS name to communicate with Prometheus. 

---

## Import Host Dashboard

The source documents importing:

```text
Dashboard ID: 1860
```

using Prometheus as the data source.

This provides the documented Node Exporter host metrics dashboard.

---

# Phase 9 — Uptime Kuma Synthetic Monitoring

Uptime Kuma provides an availability-oriented monitoring layer separate from Prometheus metrics.

The intended public route is:

```text
/kuma/
```

The container listens on:

```text
127.0.0.1:3001
```

---

## Nginx Routing

Uptime Kuma requires WebSocket support.

The documented Nginx configuration includes:

```nginx
location /kuma/ {
    proxy_pass http://127.0.0.1:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Additional routes are handled for Uptime Kuma assets and WebSocket/API traffic to prevent blank-page behavior. 

Validate and reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Access:

```text
http://YOUR_EC2_IP/kuma/
```

---

## Configure the Monitor

Create the first Uptime Kuma administrator.

Then create an HTTP monitor:

```text
Monitor Type:       HTTP(s)
Friendly Name:     SaaS App Public Health
Heartbeat Interval: 20 seconds
```

The monitored URL can use the local application endpoint or the public application endpoint according to the documented configuration. 

---

# Phase 10 — Automated Backup & Disaster Recovery

The backup architecture consists of:

```text
MySQL Container
      |
      v
mysqldump
      |
      v
/opt/backups
      |
      v
.tar.gz
      |
      v
7-day retention
```

---

## Backup Directory

```bash
sudo mkdir -p /opt/backups
sudo chown ubuntu:ubuntu /opt/backups
```

---

## Backup Script

Create:

```text
~/linux-saas-infrastructure-lab/backup/backup-mysql.sh
```

The script:

1. Executes `mysqldump` inside the MySQL container.
2. Writes the SQL backup to `/opt/backups`.
3. Compresses the backup.
4. Removes the uncompressed SQL file.
5. Deletes archives older than seven days.

Use environment-specific credentials rather than hard-coded secrets.

The documented backup retention policy is seven days. 

Make executable:

```bash
chmod +x ~/linux-saas-infrastructure-lab/backup/backup-mysql.sh
```

---

## Restore Script

Create:

```text
~/linux-saas-infrastructure-lab/backup/restore-mysql.sh
```

The restore workflow:

```text
.tar.gz backup
      |
      v
Temporary directory
      |
      v
SQL file
      |
      v
MySQL container
```

The script expects the backup path as its first argument:

```bash
./restore-mysql.sh /path/to/backup_file.tar.gz
```

The source restores the SQL dump into the MySQL database and removes the temporary extraction directory afterward. 

---

## Scheduled Backup

The documented cron schedule runs the backup every day at:

```text
02:00
```

The configured cron pattern is:

```cron
0 2 * * *
```

Verify:

```bash
crontab -l
```

---

## Disaster Recovery Verification

Run an initial backup:

```bash
~/linux-saas-infrastructure-lab/backup/backup-mysql.sh
```

Verify:

```bash
ls -lh /opt/backups/
```

Perform the documented controlled database test.

Then locate the latest backup:

```bash
LATEST_BACKUP=$(ls -t /opt/backups/*.tar.gz | head -n 1)
```

Restore:

```bash
~/linux-saas-infrastructure-lab/backup/restore-mysql.sh ${LATEST_BACKUP}
```

The project explicitly includes disaster recovery verification rather than merely creating backups. 

---

# Phase 11 — Observability, Centralized Logging & Network Flow Analysis

## Nginx Log Rotation

Create:

```text
/etc/logrotate.d/nginx-saas
```

The documented policy:

```text
daily
14 rotations
compression enabled
delayed compression
```

Nginx logs are rotated from:

```text
/var/log/nginx/saas_access.log
/var/log/nginx/saas_error.log
```

---

## Docker Log Limits

Configure Docker's daemon logging:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Reload Docker:

```bash
sudo systemctl reload docker
```

The purpose is to prevent uncontrolled container log growth from consuming disk space. 

---

## Centralized Log Inspection

The project includes:

```text
docs/inspect-logs.sh
```

It provides an interactive menu for:

```text
1. Nginx access logs
2. Nginx error logs
3. SaaS application logs
4. MySQL logs
5. UFW dropped packets
```

Make executable:

```bash
chmod +x ~/linux-saas-infrastructure-lab/docs/inspect-logs.sh
```

---

## Docker Network Tracing

Inspect the application network:

```bash
docker network inspect docker_app-network | grep -A 5 "Containers"
```

Test application-to-MySQL DNS resolution:

```bash
docker exec -it saas-app ping -c 3 mysql-db
```

Test application metrics from the Prometheus container:

```bash
docker exec -it prometheus \
  wget -qO- http://saas-app:8000/metrics | head -n 10
```

These tests validate Docker network isolation and inter-container communication. 

---

# Phase 12 — Controlled Incident Simulations

The project intentionally introduces six controlled incidents to validate monitoring and recovery workflows.

All scenarios are intended to be controlled and recoverable.

---

## INC-001 — Nginx Service Outage

### Trigger

```bash
sudo systemctl stop nginx
```

### Expected impact

```text
Public application becomes unreachable.
Uptime Kuma reports DOWN.
```

### Recovery

```bash
sudo systemctl start nginx
```

---

## INC-002 — Application Container Crash

### Trigger

```bash
docker stop saas-app
```

### Expected impact

```text
Nginx returns 502 Bad Gateway.
Prometheus reports the saas-app target as DOWN.
```

### Recovery

```bash
docker start saas-app
```

---

## INC-003 — MySQL Service Interruption

### Trigger

```bash
docker stop mysql-db
```

### Test connectivity:

```bash
docker exec -it saas-app python -c "
import mysql.connector
mysql.connector.connect(
    host='mysql-db',
    user='saasuser',
    password='<YOUR_DB_PASSWORD>'
)
"
```

### Recovery

```bash
docker start mysql-db
```

The source documents this as a controlled database interruption scenario. 

---

## INC-004 — High CPU Utilization

Install the test tool:

```bash
sudo apt-get install -y stress-ng
```

Run the controlled workload:

```bash
stress-ng --cpu 2 --timeout 60s &
```

Observe:

```bash
top -b -n 1 | head -n 12
```

The expected effect is a significant CPU spike visible in Grafana.

The process automatically stops after 60 seconds, or it can be terminated manually:

```bash
sudo killall stress-ng
```

---

## INC-005 — Disk Space Depletion

Create the controlled dummy file:

```bash
fallocate -l 5G /tmp/dummy_large_file.img
```

Check disk utilization:

```bash
df -h /
```

Remove the test file:

```bash
rm -f /tmp/dummy_large_file.img
```

This scenario tests whether the monitoring stack detects significant storage depletion. 

---

## INC-006 — Nginx Routing Error

The source simulates a wrong upstream port:

```bash
sudo sed -i \
  's/127.0.0.1:8000/127.0.0.1:8001/g' \
  /etc/nginx/sites-available/saas-app.conf

sudo systemctl reload nginx
```

Expected result:

```text
HTTP 502 Bad Gateway
```

Inspect the error log:

```bash
sudo tail -n 5 /var/log/nginx/saas_error.log
```

Restore the correct upstream:

```bash
sudo sed -i \
  's/127.0.0.1:8001/127.0.0.1:8000/g' \
  /etc/nginx/sites-available/saas-app.conf

sudo systemctl reload nginx
```

---

# Phase 13 — Incident Response Methodology

Each incident follows a five-stage lifecycle.

## 1. Detection

Identify the abnormal condition through:

* Uptime Kuma
* Grafana
* Prometheus
* HTTP status codes
* System metrics

## 2. Containment

Prevent the problem from spreading or causing additional impact.

## 3. Investigation & Root Cause Analysis

Investigate:

```text
system logs
journalctl
docker logs
dmesg
Nginx logs
configuration changes
```

## 4. Remediation & Recovery

Restore service through actions such as:

```text
restart service
restart container
rollback configuration
restore database
free disk space
```

## 5. Post-Mortem & Prevention

Document:

* What happened
* Why it happened
* How it was detected
* How it was recovered
* How recurrence can be prevented

This five-stage methodology is explicitly defined in the project source. 

---

# Phase 14 — Incident Reports

The project generates six incident reports under:

```text
incidents/
```

Expected files:

```text
incidents/
├── INC-001-nginx-down.md
├── INC-002-application-down.md
├── INC-003-database-failure.md
├── INC-004-high-cpu.md
├── INC-005-disk-full.md
└── INC-006-nginx-proxy.md
```

Each report documents:

* Date/time
* Severity
* Impact
* Symptom
* Root cause
* Detection/investigation
* Remediation/recovery
* Prevention

The documented incidents range from Nginx outage and application failure to database interruption, CPU exhaustion, disk exhaustion, and Nginx misrouting. 

---

# Phase 15 — Operations Runbook

The project includes:

```text
docs/troubleshooting-guide.md
```

## Daily Health Checks

Check Docker:

```bash
docker compose ps
```

Check Nginx:

```bash
sudo systemctl status nginx
```

Check memory and swap:

```bash
free -h
```

Check disk:

```bash
df -h /
```

Check UFW:

```bash
sudo ufw status
```

These checks are the documented baseline daily operational checks. 

---

## Emergency Procedures

### Nginx outage

```bash
sudo systemctl status nginx
sudo ss -tulpn | grep -E ':80|:443'
sudo nginx -t
sudo systemctl start nginx
```

### Application container failure

```bash
docker ps -a | grep saas-app
docker logs --tail 50 saas-app
docker compose restart saas-app
```

### MySQL failure

```bash
docker ps | grep mysql-db

docker compose restart mysql-db
```

If database corruption is suspected:

```bash
LATEST_BACKUP=$(ls -t /opt/backups/*.tar.gz | head -n 1)

~/linux-saas-infrastructure-lab/backup/restore-mysql.sh \
  ${LATEST_BACKUP}
```

### High CPU or memory

```bash
ps aux --sort=-%cpu | head -n 10
ps aux --sort=-%mem | head -n 10
```

If necessary:

```bash
sudo kill -9 <PID>
```

The source also documents clearing the Linux page cache:

```bash
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### Disk exhaustion

```bash
df -h /

sudo du -ah / 2>/dev/null \
  | sort -rh \
  | head -n 10
```

Clean Docker resources:

```bash
docker system prune -f
```

Rotate Nginx logs:

```bash
sudo logrotate -f /etc/logrotate.d/nginx-saas
```

### Nginx routing error

```bash
sudo nginx -t

sudo tail -n 20 /var/log/nginx/saas_error.log

sudo systemctl reload nginx
```

The complete troubleshooting flow is documented in the project's operations runbook. 

---

# Phase 16 — Final End-to-End Validation

The project provides:

```text
docs/e2e-validation.sh
```

The validation script checks ten infrastructure conditions.

## Validation Checklist

|  # | Check            | Expected           |
| -: | ---------------- | ------------------ |
|  1 | Swap             | Configured         |
|  2 | UFW              | Active             |
|  3 | SSH hardening    | Enabled            |
|  4 | Docker           | Operational        |
|  5 | Containers       | At least 4 running |
|  6 | Nginx            | HTTP 200           |
|  7 | `/metrics`       | HTTP 403           |
|  8 | Node Exporter    | Metrics available  |
|  9 | Prometheus       | Healthy targets    |
| 10 | Backup directory | Operational        |

The documented script checks the infrastructure sequentially and exits with failure when a critical check does not pass. 

Make it executable:

```bash
chmod +x ~/linux-saas-infrastructure-lab/docs/e2e-validation.sh
```

Run:

```bash
~/linux-saas-infrastructure-lab/docs/e2e-validation.sh
```

A successful run reports:

```text
ALL END-TO-END VALIDATION TESTS PASSED SUCCESSFULLY!
```

---

# Operations URLs

Replace `YOUR_EC2_IP` with the actual Elastic IP.

## SaaS Application

```text
http://YOUR_EC2_IP/
```

## Grafana

```text
http://YOUR_EC2_IP/grafana/
```

## Uptime Kuma

```text
http://YOUR_EC2_IP/kuma/
```

Prometheus and Node Exporter are intended to remain locally/internal rather than being directly exposed publicly.

---

# Security Considerations

## AWS Security Group

Only expose:

```text
22
80
443
```

Do not expose:

```text
3306
8000
9090
3000
3001
```

## UFW

The host firewall denies incoming traffic by default and explicitly permits SSH, HTTP, and HTTPS.

## SSH

The hardening configuration:

```text
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 3
```

## Application Metrics

The application exposes `/metrics` internally, but Nginx denies public access:

```text
HTTP 403
```

## Service Binding

Application and monitoring services are bound to localhost on the host where applicable, while MySQL remains on the Docker application network.

## Credentials

Never commit:

```text
.env
```

or files containing:

```text
database passwords
private keys
AWS credentials
API tokens
administrator passwords
```

Use environment-specific secret management when moving beyond a lab environment.

---

# Logging & Observability

The observability stack consists of multiple layers:

```text
                    +----------------+
                    | Uptime Kuma    |
                    | Availability   |
                    +-------+--------+
                            |
                            v
Internet ---> Nginx ---> SaaS Application
                  |             |
                  |             v
                  |           Metrics
                  |             |
                  |             v
                  |         Prometheus
                  |             |
                  |             v
                  |           Grafana
                  |
                  +--> Nginx Logs
                       
Host OS ---> Node Exporter ---> Prometheus

Docker ---> Container Logs ---> Log Inspection

MySQL ---> Container Logs ---> Log Inspection
```

This provides both:

* **Metrics-based observability**
* **Availability monitoring**
* **Log-based troubleshooting**

---

# Project Structure

The source documentation implies the following logical repository structure:

```text
linux-saas-infrastructure-lab/
├── README.md
│
├── docker/
│   ├── .env
│   ├── docker-compose.yml
│   └── monitoring/
│       └── prometheus/
│           └── prometheus.yml
│
├── backup/
│   ├── backup-mysql.sh
│   └── restore-mysql.sh
│
├── docs/
│   ├── inspect-logs.sh
│   ├── e2e-validation.sh
│   └── troubleshooting-guide.md
│
└── incidents/
    ├── INC-001-nginx-down.md
    ├── INC-002-application-down.md
    ├── INC-003-database-failure.md
    ├── INC-004-high-cpu.md
    ├── INC-005-disk-full.md
    └── INC-006-nginx-proxy.md
```

The `backup/`, `docs/`, and `incidents/` directories are explicitly created by the documented procedures.  

---

# Configuration Files

Important configuration files include:

```text
/etc/ssh/sshd_config.d/hardening.conf
/etc/nginx/sites-available/saas-app.conf
/etc/systemd/system/node_exporter.service
/etc/logrotate.d/nginx-saas
/etc/docker/daemon.json
```

Project-level files include:

```text
docker/docker-compose.yml
docker/monitoring/prometheus/prometheus.yml
backup/backup-mysql.sh
backup/restore-mysql.sh
docs/inspect-logs.sh
docs/e2e-validation.sh
docs/troubleshooting-guide.md
incidents/*.md
```

---

# Common Operational Commands

## Docker

```bash
docker compose ps
docker ps
docker logs --tail 50 saas-app
docker compose restart saas-app
docker compose restart mysql-db
docker compose up -d
```

## Nginx

```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl start nginx
```

## Firewall

```bash
sudo ufw status
sudo ufw status verbose
```

## System Resources

```bash
free -h
df -h /
top -b -n 1
```

## Node Exporter

```bash
curl -s http://127.0.0.1:9100/metrics
```

## Prometheus

```bash
curl -s http://127.0.0.1:9090/api/v1/targets
```

## Backup

```bash
ls -lh /opt/backups/
```

---

# Troubleshooting Principles

When troubleshooting the infrastructure, follow this general sequence:

```text
1. Detect
   |
   v
2. Determine scope
   |
   v
3. Check service state
   |
   v
4. Inspect logs
   |
   v
5. Verify network connectivity
   |
   v
6. Identify root cause
   |
   v
7. Apply remediation
   |
   v
8. Verify recovery
   |
   v
9. Document prevention
```

Useful sources of evidence include:

```text
systemctl
ss
curl
docker ps
docker logs
journalctl
dmesg
Nginx access logs
Nginx error logs
Prometheus targets
Grafana metrics
Uptime Kuma status
```

---

# Learning Outcomes

This project demonstrates practical experience with:

### Linux Administration

* Ubuntu Server administration
* System services
* systemd
* Swap
* Filesystem management
* Resource inspection
* Linux permissions

### Networking

* AWS Security Groups
* Public/private service exposure
* localhost binding
* Docker bridge networking
* Docker internal DNS
* Reverse proxying
* Network tracing

### Security

* UFW
* SSH hardening
* Root-login restrictions
* Password-authentication restrictions
* Internal service isolation
* Metrics endpoint protection

### Containers

* Docker Engine
* Docker Compose V2
* Container networking
* Persistent volumes
* Container lifecycle management
* Container logging

### Monitoring

* Prometheus
* Node Exporter
* Grafana
* Uptime Kuma
* Application metrics
* Infrastructure metrics
* Availability monitoring

### Operations

* Automated backups
* Database restoration
* Cron
* Logrotate
* Incident response
* Root cause analysis
* Operational runbooks
* Disaster recovery testing
* End-to-end validation

---

# Project Workflow

The complete implementation follows this operational sequence:

```text
AWS Provisioning
      |
      v
Security Group
      |
      v
EC2 + Elastic IP
      |
      v
SSH Access
      |
      v
Linux Hardening
      |
      +--> Swap
      +--> UFW
      +--> SSH Hardening
      |
      v
Docker Installation
      |
      v
SaaS + MySQL Deployment
      |
      v
Nginx Reverse Proxy
      |
      v
Node Exporter
      |
      v
Prometheus
      |
      v
Grafana
      |
      v
Uptime Kuma
      |
      v
Automated Backup
      |
      v
Logging & Observability
      |
      v
Incident Simulations
      |
      v
Incident Documentation
      |
      v
Operations Runbook
      |
      v
E2E Validation
```

---

# Conclusion

The Linux SaaS Infrastructure Monitoring & Operations Lab demonstrates a complete infrastructure lifecycle, from cloud provisioning and Linux hardening through containerized application deployment, reverse proxy configuration, observability, backup and recovery, incident response, and final validation.

The project is particularly focused on the operational side of infrastructure: not only deploying services, but also monitoring them, detecting failures, troubleshooting them, recovering from incidents, protecting logs and storage, and verifying that the infrastructure remains operational.

The final E2E validation consolidates the most important infrastructure checks into a single automated test covering swap, firewall, SSH hardening, Docker, containers, Nginx, metrics protection, Node Exporter, Prometheus, and backups. 

---

# Documentation Gaps / Assumptions

1. **HTTPS/TLS implementation is not actually documented.**
   Port `443` is allowed in the AWS Security Group, but the provided Nginx configuration only explicitly configures HTTP on port `80`. Therefore this README does not claim that TLS/HTTPS is implemented.

2. **The exact final `docker-compose.yml` changes across phases.**
   The source repeatedly rewrites the Compose file as Prometheus, Grafana, and Uptime Kuma are introduced. This README represents the resulting architecture rather than reproducing every intermediate rewrite.

3. **Credentials in the source are treated as secrets.**
   The original documentation contains database and Grafana credentials. They have deliberately been replaced with placeholders here.

4. **The source contains an inconsistency around the Uptime Kuma route.**
   The public UI is accessed through `/kuma/`, while one rewrite rule references `/status`. The README follows the actual documented public `/kuma/` route and does not present `/status/` as the primary access URL. 

5. **The source contains a documentation inconsistency in the incident-prevention narrative.**
   Some incident reports mention controls such as MySQL health checks, container CPU limits, or systemd auto-restart policies whose exact final configuration is not fully shown in the supplied deployment steps. Those controls are therefore described only as documented incident-prevention measures rather than claimed as independently verified final configuration.

6. **The source does not provide a complete cleanup/teardown procedure.**
   Therefore a destructive AWS teardown procedure has not been invented.

7. **The source uses an example Elastic IP in several commands.**
   This README replaces it with `YOUR_EC2_IP` so the documentation is reusable and does not preserve an environment-specific address.

---

# Suggested Repository Structure

```text
linux-saas-infrastructure-lab/
├── README.md
├── .gitignore
│
├── docker/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── monitoring/
│       └── prometheus/
│           └── prometheus.yml
│
├── backup/
│   ├── backup-mysql.sh
│   └── restore-mysql.sh
│
├── docs/
│   ├── e2e-validation.sh
│   ├── inspect-logs.sh
│   └── troubleshooting-guide.md
│
├── incidents/
│   ├── INC-001-nginx-down.md
│   ├── INC-002-application-down.md
│   ├── INC-003-database-failure.md
│   ├── INC-004-high-cpu.md
│   ├── INC-005-disk-full.md
│   └── INC-006-nginx-proxy.md
│
└── screenshots/
    └── ...
```

A `.gitignore` should exclude sensitive and runtime-generated content such as:

```text
.env
*.pem
*.key
*.log
```

The repository structure above is a recommendation derived from the project artifacts documented in the source; it is not presented as an existing repository tree.
