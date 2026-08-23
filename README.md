# Linux SaaS Infrastructure & SRE Lab

Proyek simulasi infrastruktur SaaS berbasis Linux, Docker, dan Prometheus/Grafana yang dirancang dengan standar *Production-Ready*, *Security Hardening*, dan *SRE Incident Response*.

---

## 🏗️ Arsitektur Sistem

```mermaid
graph TD
    Client[User Browser] -->|HTTP 80| Nginx[Nginx Reverse Proxy]
    
    subgraph "Docker Bridge Network (docker_app-network)"
        Nginx -->|Proxy Pass| Flask[SaaS App :8000]
        Flask -->|MySQL Driver| DB[(MySQL DB :3306)]
    end
    
    subgraph "Docker Bridge Network (docker_monitoring-net)"
        Prometheus[Prometheus :9090] -->|Scrape Metrics| Flask
        Prometheus -->|Scrape Metrics| NodeExp[Node Exporter :9100]
        Grafana[Grafana :3000] -->|Query Data| Prometheus
        Kuma[Uptime Kuma :3001] -->|Healthcheck| Nginx
    end

linux-saas-infrastructure-lab/
├── backup/                  # Skrip automated backup & restore database MySQL
├── docker/                  # Konfigurasi Docker Compose & Prometheus
├── docs/                    # Panduan troubleshooting & skrip E2E validation
└── incidents/               # Dokumentasi 6 skenario SRE Incident Response (INC-001 s/d INC-006)

🚀 Komponen Utama & Fitur
Web & Database Tier: Aplikasi SaaS berbasis Python/Flask terhubung dengan database MySQL.

Security & Hardening:

Konfigurasi UFW Firewall & SSH Hardening (PermitRootLogin no).

Proteksi endpoint internal /metrics (mengembalikan HTTP 403 Forbidden dari luar jaringan publik).

Observability Stack:

Prometheus & Node Exporter untuk metrik sistem (CPU, Memory, Disk).

Grafana Dashboard untuk visualisasi metrik secara real-time.

Uptime Kuma untuk uptime monitoring.

SRE Ops & Readiness: Dilengkapi dengan 6 skenario Incident Report, skrip rotasi log, manajemen backup, serta Automated E2E Validation Script (e2e-validation.sh).

🛠️ Cara Menjalankan Validasi Sistem
sudo ./docs/e2e-validation.sh

📋 Daftar Skenario Insiden (SRE)
INC-001: Nginx Service Down

INC-002: Application Crash / Down

INC-003: MySQL Database Failure & Interruption

INC-004: High CPU Utilization (Stress Testing)

INC-005: Disk Full Simulation & Mitigation

INC-006: Nginx Proxy Misconfiguration

