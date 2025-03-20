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


We need to enter configuration mode to configure our initial setup.

```shell
configure
```

### System 

#### Hostname

It’s a good idea to set the Hostname of the system to something that is easily identifiable. I will call mine `BR01`

```shell
set system host-name BR01
commit; save
```

#### NTP

By default, VyOS acts as an NTP server for clients. This is usually unnecessary for home use, so it's best to disable it.

```shell
delete service ntp allow-client
delete service ntp server time1.vyos.net
delete service ntp server time2.vyos.net
delete service ntp server time3.vyos.net
commit; save
```

VyOS defaults to NTP servers in the US, Germany, and Singapore (AWS). For better accuracy, use servers closer to your location. I’ll be using NL-based servers from pool.ntp.org since I’m located in the Netherlands.

```shell
set service ntp server 0.nl.pool.ntp.org
set service ntp server 1.nl.pool.ntp.org
set service ntp server 2.nl.pool.ntp.org
set service ntp server 3.nl.pool.ntp.org
set system time-zone 'Europe/Amsterdam'
commit; save
```

#### User

For security best practices, it's recommended to remove or disable the default `vyos` user and create a new one with administrative privileges.

```shell
set system login user admin authentication plaintext-password admin
commit; save
```

> change `admin` to your username and password.

Now login with your new user account to make everything works. After that delete the `vyos` user account.

```shell
delete system login user vyos 
commit; save
```

#### SSH

```shell
set service ssh listen-address 192.168.1.1
```

### LAN

We’ll configure the LAN ports to establish a network connection for all your devices. This will ensure that both your homelab and internet access are set up properly, providing seamless connectivity throughout your network.

#### Bridge Interface

We’ll create a bridge interface, allowing us to combine all the ports into a single network. This will enable seamless communication between all your devices on the same network.


```shell
configure
set interfaces bridge br0 
set interfaces bridge br0 address 192.168.1.1/24
set interfaces bridge br0 member interface eth0
commit
exit
```

> In this setup I only have one interface in the bridge. You repeat the `interfaces bridge br0 member interface eth0` command for every interface you want to be part of the bridge.

You can check the bridge with the command `show bridge br0`

```shell
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
set service dns forwarding allow-from '192.168.1.0/24'
set service dns forwarding listen-address '192.168.1.1'
set service dns forwarding system
set system name-server 'eth1.300'
```



### Firewall

In VyOS (and most firewall systems using Netfilter/iptables), traffic filtering is managed through three main chains: INPUT, OUTPUT, and FORWARD. Understanding these chains is crucial for configuring firewall rules effectively.

- INPUT Chain: This controls incoming traffic destined for the VyOS router itself. For example, SSH access to the router or web management interfaces would be filtered by the INPUT chain.
- OUTPUT Chain: This manages traffic originating from the VyOS router. If the router itself makes outbound requests (such as NTP synchronization or software updates), they are processed through the OUTPUT chain.
- FORWARD Chain: This handles traffic passing through the router but not directed to or from it. If VyOS is acting as a router between networks, the FORWARD chain determines which packets are allowed to pass between them.

#### Input Chain
```shell
configure
set firewall ipv4 input filter default-action drop
set firewall ipv4 input filter rule 10 action 'accept'
set firewall ipv4 input filter rule 10 state 'established'
set firewall ipv4 input filter rule 10 state 'related'
set firewall ipv4 input filter rule 10 inbound-interface name eth1.300
set firewall ipv4 input filter rule 10 description 'Allow Return traffic destined to the router'
set firewall ipv4 input filter rule 1000 action 'accept'
set firewall ipv4 input filter rule 1000 description 'Allow all traffic from LAN interface'
set firewall ipv4 input filter rule 1000 inbound-interface name br0
```

#### Output Chain
```shell
set firewall ipv4 output filter default-action accept 
```

#### Forward Chain
```shell
set firewall ipv4 forward filter default-action drop
set firewall ipv4 forward filter rule 20 action 'accept'
set firewall ipv4 forward filter rule 20 description 'Allow Return traffic through the router'
set firewall ipv4 forward filter rule 20 state 'established'
set firewall ipv4 forward filter rule 20 state 'related'
set firewall ipv4 forward filter rule 20 inbound-interface name eth1.300
set firewall ipv4 forward filter rule 1000 action 'accept'
set firewall ipv4 forward filter rule 1000 description 'Allow all traffic from LAN interface'
set firewall ipv4 forward filter rule 1000 inbound-interface name br0
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
```

```shell
sven@BR01# run show ip route
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

S>* 0.0.0.0/0 [210/0] via 85.146.118.129, eth1.300, weight 1, 00:00:16
C>* 85.146.118.128/25 is directly connected, eth1.300, weight 1, 00:00:17
K * 85.146.118.128/25 [0/0] is directly connected, eth1.300, weight 1, 00:00:17
L>* 85.146.118.221/32 is directly connected, eth1.300, weight 1, 00:00:17
C>* 192.168.1.0/24 is directly connected, br0, weight 1, 00:07:15
L>* 192.168.1.1/32 is directly connected, br0, weight 1, 00:07:15
[edit]
```

#### Testing Connectivity

You should now be able to reach the internet. Test connectivity by pinging a public DNS server like `1.1.1.1`, `4.2.2.2`, `8.8.8.8`, or `9.9.9.9`.

```shell
sven@BR01# run ping 4.2.2.2
PING 4.2.2.2 (4.2.2.2) 56(84) bytes of data.
64 bytes from 4.2.2.2: icmp_seq=1 ttl=58 time=15.2 ms
64 bytes from 4.2.2.2: icmp_seq=2 ttl=58 time=14.8 ms
^C
--- 4.2.2.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 14.834/15.029/15.224/0.195 ms
```

### NAT

```shell
set nat source rule 10 description 'NAT source address for all traffic leaving eth1'
set nat source rule 10 outbound-interface name 'eth1.300'
set nat source rule 10 translation address 'masquerade'
```


## Performance

```shell
   Speedtest by Ookla

      Server: Odido - Amsterdam (id: 52365)
         ISP: Odido Netherlands
Idle Latency:     5.76 ms   (jitter: 0.04ms, low: 5.74ms, high: 5.79ms)
    Download:   975.77 Mbps (data used: 1.3 GB)                                                   
                  4.97 ms   (jitter: 2.37ms, low: 4.61ms, high: 222.00ms)
      Upload:   966.04 Mbps (data used: 482.1 MB)                                                   
                 15.31 ms   (jitter: 0.91ms, low: 6.05ms, high: 16.89ms)
 Packet Loss:     0.0%
  Result URL: https://www.speedtest.net/result/c/5e330839-730a-4af7-b30e-fda648b66510
```
