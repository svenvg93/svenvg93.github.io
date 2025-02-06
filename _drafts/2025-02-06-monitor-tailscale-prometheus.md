---
title: Monitoring Tailscale with Prometheus
description: Learn how to track Tailscale traffic using Prometheus for real-time insights into your secure network.
date: 2025-02-06
categories: 
  - tailscale
  - monitoring
tags: 
  - tailscale
  - docker
image:
  path: /assets/img/headers/2025-02-06-monitor-tailscale-prometheus.jpg
  alt: Photo by Jack B on Unsplash
---
Tailscale makes secure networking easy, but how do you monitor its performance? In this guide, we’ll set up Prometheus to collect key Tailscale metrics and gain insights into your mesh VPN connections. Learn how to track bandwidth usage and ensure your network is running smoothly—all with open-source monitoring tools! 🚀

## Configure Tailscale

```shell
sudo tailscale set --webclient
```

## Configure Prometheus

```yaml
scrape_configs:
  - job_name: 'tailscale'
    scrape_interval: 10s
    static_configs:
      - targets:
          - 'pi5.tail43c135.ts.net:5252'
          - 'pi4.tail43c135.ts.net:5252'
```
{: file='prometheus.yml'}

## Grafana Dashboard
