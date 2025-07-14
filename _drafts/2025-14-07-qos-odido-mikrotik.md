---
title: QoS Miktorik Odido TV
description:
date: 2025-07-01
categories:
  - Networking
  - Router
tags:
  - mikrotik
  - firewall
image:
  path: /assets/img/headers/.jpg
  alt:
---


## ✅ What We Need To Do

* Match **download traffic where the source IP is `123.456.789.0/24`**
* Mark those packets in `forward` chain
* Prioritize that traffic using a `queue tree` with `priority=1`

---

## 🛠 MikroTik Configuration to Prioritize OTT TV Streams

> Replace `123.456.789.0/24` with the real subnet used by your OTT provider.

---

### 🔧 1. Mangle Rule to Mark Download Traffic from OTT Source

```bash
/ip firewall mangle
add chain=forward src-address=123.456.789.0/24 in-interface=internet action=mark-packet new-packet-mark=ott-download passthrough=yes comment="Mark OTT download traffic"
```

* ✅ `src-address=` the OTT provider IP range
* ✅ `in-interface=internet` is your WAN (incoming to you)
* ✅ `forward` chain ensures it applies to routed traffic

---

### 🔧 2. Create a High-Priority Queue Type (Optional)

```bash
/queue type
add name=fq_codel_ott kind=fq-codel fq-codel-target=3ms
```

---

### 🔧 3. Create Queue Tree with High Priority

```bash
/queue tree
add name="ott-streaming" parent=global packet-mark=ott-download queue=fq_codel_ott priority=1 max-limit=300M
```

---

### ✅ Optional: Mark and Deprioritize Other Traffic

```bash
/ip firewall mangle
add chain=forward src-address=!123.456.789.0/24 in-interface=internet action=mark-packet new-packet-mark=default-download passthrough=yes comment="Other internet traffic"

/queue tree
add name="default-download" parent=global packet-mark=default-download queue=default priority=8 max-limit=900M
```

---

### 🧪 Verify It’s Working

```bash
/queue tree print stats interval=1
```

* Stream content on your OTT service
* Watch `ott-streaming` fill with traffic
* Other downloads (e.g. YouTube, file downloads) go to `default-download`

---

## ✅ Result

* OTT TV traffic from `123.456.789.0/24` gets **preferential treatment**
* Ensures smooth playback even during congestion
* Other traffic is shaped behind it

---

### 🚀 Let Me Know If You Want:

* To apply this by **destination port** (e.g. 443, 554 for RTSP)
* Use **DSCP values** if the provider marks traffic
* Prioritize IPTV multicast as well (very different setup)

You’re now shaping **by OTT provider’s IP block** — a pro-level method for smart streaming quality!
