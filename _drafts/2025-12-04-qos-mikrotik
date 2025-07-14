---
title: QoS on Mirkotik ofzo
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

Absolutely! Here's the **full set of MikroTik commands** to:

*  Create mangle rules for upload/download packet-marking
*  Create FQ-CoDel-based queue tree for both directions
*  Use `parent=global` so it's interface-agnostic
*  Apply shaping at \~900 Mbps
*  Ensure traffic is processed correctly


## 🛠 Full Commands (Copy & Paste)

### 1. **Mangle Rules to Mark Upload & Download**

```bash
/ip firewall mangle
add chain=forward action=mark-packet new-packet-mark=download passthrough=yes out-interface=bridge1 comment="Mark download traffic"
add chain=forward action=mark-packet new-packet-mark=upload passthrough=yes out-interface=internet comment="Mark upload traffic"
```

> Replace `bridge1` and `internet` with your LAN and WAN interface names if different.


### 2. **Create FQ-CoDel Queue Types**

```bash
/queue type
add name=fq_codel_download kind=fq-codel fq-codel-target=3ms
add name=fq_codel_upload kind=fq-codel fq-codel-target=3ms
```


### 3. **Queue Tree (FQ-CoDel with Marks)**

```bash
/queue tree
add name=queue-download parent=global packet-mark=download queue=fq_codel_download limit-at=850M max-limit=900M
add name=queue-upload parent=global packet-mark=upload queue=fq_codel_upload limit-at=850M max-limit=900M
```
### Disbale HW 

```bash
/interface bridge port            
set [find] hw=no
```

## ✅ After Applying

1. Run:

```bash
/queue tree print stats interval=1
```

```bash
/queue tree print stats interval=1
Flags: X - disabled, I - invalid 
 0   name="queue-download" parent=global packet-mark=download rate=52320 packet-rate=45 queued-bytes=0 queued-packets=0 bytes=28192979120 packets=25350209 dropped=0 

 1   name="queue-upload" parent=global packet-mark=upload rate=338232 packet-rate=72 queued-bytes=0 queued-packets=0 bytes=26698400069 packets=23484974 dropped=0 
 ```