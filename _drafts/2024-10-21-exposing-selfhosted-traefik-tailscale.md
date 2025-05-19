---
title: Exposing Self-Hosted Apps with Traefik and Tailscale
description: Securely expose your self-hosted apps using Traefik and Tailscale, without touching your router.
date: 2025-05-16
categories:
  - Networking
  - Reverse Proxy
tags:
  - traefik
  - tailscale
image:
  path: /assets/img/headers/2025-05-16-traefik-tailscale-cloudflare.jpg
  alt: Traefik and Tailscale network diagram
---

One of my favorite things about self-hosting is having full control over my apps—but accessing them securely from anywhere used to be a bit of a hassle. That changed when I started using [Tailscale](https://tailscale.com). It gives me a private network between all my devices, no port forwarding or firewall headaches required.

To make things even smoother, I use [Traefik](https://traefik.io) as a reverse proxy. It handles routing and TLS for my apps, all within the Tailscale network. In this post, I’ll walk through how I set this up to securely expose my self-hosted services—no public internet needed.
