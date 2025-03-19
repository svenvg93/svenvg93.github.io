---
title: Setting up VyOS router for your network
description: Setting up a VyOS router for your homelab gives you enterprise-grade networking with open-source flexibility.
date: 2025-03-19
categories:
  - homelab
  - network
tags: 
  - vyos
image:
  path: /assets/img/headers/2025-03-19-setup-vyos-router.jpg
  alt: Photo by Patrick Turner on Unsplash
---

Setting up a [VyOS](https://vyos.io) router for your homelab gives you enterprise-grade networking with open-source flexibility. In this post, we'll cover the essential steps to install and configure VyOS for a more secure and efficient network.

VyOS provides a free routing platform that competes directly with other commercially available solutions from well-known network providers. Because VyOS is run on standard amd64 systems, it can be used as a router and firewall platform for cloud deployments.

VyOS offers powerful routing, firewalling, making it an excellent choice for homelabbers who want more than what consumer routers can provide. In this post, we’ll walk you through the essential steps to install and configure VyOS, so you can build a more secure and efficient network tailored to your needs.

## Installation

VyOS can run on various diffrent platforms. Both baremetal as well als cloud platforms. In this guide we will use the "bare metal" installation inside of a VM.

After you [download](https://github.com/vyos/vyos-nightly-build/releases) the latests version, boot from the image using the appropriate method for your platform (USB, virtual machine, or PXE).

> VyOS rolling release images are built from the latest development code, incorporating the newest changes from maintainers and community contributors. While they receive automated testing to ensure they boot and load configurations, they may include experimental features, bugs, and compatibility issues. As a result, they are not recommended for production use.
{: .prompt-warning }

Once the image loads, log in with the default credentials (`vyos/vyos`). In operational mode, run `install image` and follow the wizard. It will guide you through partitioning the disk and configuring the root password. After installation, remove the live USB or CD and reboot the system.

## Configuration

### LAN

First, we’ll configure the LAN ports to establish a network connection for all your devices. This will ensure that both your homelab and internet access are set up properly, providing seamless connectivity throughout your network.

#### Bridge Interface

we’ll create a bridge interface, allowing us to combine all the ports into a single network. This will enable seamless communication between all your devices on the same network.


```shell
configure
set interfaces bridge br0 
set interfaces bridge br0 address 192.168.1.1/24
set interfaces bridge br0 member interface eth0
commit
exit
```

> In this setup I only have one interface in the bridge. You repeat the `interfaces bridge br0 member interface eth0` command for every interface you want to be part of the bridge.
{: .prompt-info }

You can check the bridge with the command `show bridge br0`

```
vyos@vyos:~$ show interfaces bridge 
Codes: S - State, L - Link, u - Up, D - Down, A - Admin Down
Interface        IP Address                        S/L  Description
---------        ----------                        ---  -----------
br0              192.168.1.1/24                    u/u 
```

#### DHCP

Now, we’ll set up a DHCP server to automatically assign IP addresses to all the devices connected to your network.

```shell
configure
set service dhcp-server shared-network-name LAN authoritative
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 lease 86400
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 option default-router 192.168.1.1
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 option name-server 192.168.1.1
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 range 0 start 192.168.1.100
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 range 0 stop 192.168.1.200
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 subnet-id 1
commit
exit
```

To view active leases from connected clients, use the command: `show dhcp server leases`

```shell
vyos@vyos:~$ show dhcp server leases
IP Address     MAC address        State    Lease start                Lease expiration           Remaining    Pool    Hostname     Origin
-------------  -----------------  -------  -------------------------  -------------------------  -----------  ------  -----------  --------
192.168.1.100  bc:24:11:82:b2:20  active   2025-03-19 17:31:03+00:00  2025-03-20 17:31:03+00:00  23:41:55     LAN     ubuntu-test  local
192.168.1.101  bc:24:11:89:c8:77  active   2025-03-19 17:36:13+00:00  2025-03-20 17:36:13+00:00  23:47:05     LAN     ubuntu-test  local
```

#### DNS

```shell
set service dns forwarding system
set service dns forwarding listen-on br0
```



### Firewall

```
configure


### System

```shell
configure
set system host-name 'router'
set system domain-name 'home'
set system time-zone 'Europe/Amsterdam'
```

### WAN

```shell
set interfaces ethernet eth1 vif 300 address dhcp
```
```shell
vyos@vyos# run show dhcp client leases
Interface    eth1.300
IP address   85.146.118.xx                [Active]
Subnet Mask  255.255.255.128
Domain Name  
Router       85.146.118.x
Name Server  37.143.84.xx 62.58.48.xx
DHCP Server  85.146.118.x
DHCP Server  900
VRF          default
Last Update  Wed Mar 19 18:02:14 UTC 2025
Expiry       Wed Mar 19 18:17:14 UTC 2025

[edit]
```
### NAT

