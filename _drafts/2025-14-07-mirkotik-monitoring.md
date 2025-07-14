---
title:
description:
date:
categories:
  -
tags:
  -
image:
  path: /assets/img/headers/.jpg
  alt:
---

1. Use a MikroTik Prometheus Exporter (Python/Go tools)
Community tools that connect via the MikroTik API or SNMP and export to Prometheus:

👉 Popular Tools:
mikrotik-exporter (Go-based, simple setup)

blackbox_exporter (pings/checks interface reachability)

telegraf + snmp input (via InfluxDB or Prometheus)

📦 Option A: mikrotik-exporter (recommended)
🛠 How it works:
Runs on a small Linux VM, container, or your monitoring host

Connects to MikroTik via API

Exposes metrics on /metrics for Prometheus scrape

🔧 Setup Example:
Run the exporter (Docker example):

bash
Copy
Edit
docker run -d \
  -p 9436:9436 \
  -e MIKROTIK_TARGETS="router1:admin:password@192.168.88.1" \
  nshttpd/mikrotik-exporter
Add this to Prometheus config:

yaml
Copy
Edit
scrape_configs:
  - job_name: 'mikrotik'
    static_configs:
      - targets: ['<exporter-host>:9436']
Import dashboards in Grafana:

Use Grafana.com dashboard ID 12435 or custom one.

Includes CPU, memory, traffic, queues, etc.

