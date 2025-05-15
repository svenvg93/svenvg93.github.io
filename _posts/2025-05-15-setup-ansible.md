---
title: Ansible Series Part 1 | Initial Setup
description: Getting started with Ansible — from installation to your first automated task.
date: 2025-05-15
categories:
  - homelab
  - automation
tags:
  - ansible
image:
  path: /assets/img/headers/2025-05-15-setup-ansible.jpg
  alt: Photo by Simon Kadula on Unsplash
---

Ansible is a powerful automation tool that lets you manage servers using simple, human-readable playbooks. In this first part of the series, we’ll walk through installing Ansible, setting up SSH key access, and running your first playbook — laying the groundwork for automating your homelab.

## Installing Ansible

Start by installing Ansible on your control machine (usually your local workstation).

For Ubuntu or Debian:

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

Once installed, run `ansible --version` to verify.

## Setting Up SSH Access

Ansible uses SSH to connect to remote machines. Setting up key-based SSH allows seamless, passwordless access.

### Generate an SSH key (if you don’t already have one)

```bash
ssh-keygen -t ed25519
```

Press enter to accept the default location. You can skip the passphrase for automation purposes.

### Copy your public key to a remote host

```bash
ssh-copy-id user@your-server-ip
```

Now verify it works:

```bash
ssh user@your-server-ip
```

If you’re logged in without being prompted for a password, you’re ready.

## Structuring Your Homelab Ansible Project

Here's a simple directory layout to manage your homelab infrastructure:

```
homelab-ansible/
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── playbooks/
│   └── install-htop.yml
└── README.md
```

### `ansible.cfg`

```yaml
[defaults]
inventory = ./inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
timeout = 10
```

This config points Ansible to your inventory file and disables host key checking to prevent interruptions.


## Defining Your Inventory

Create `inventory/hosts.yml` to group your homelab servers:

```yaml
all:
  children:
    homelab:
      hosts:
        server01:
        server02:
```

You can replace `server01` and `server02` with hostnames or IPs.

## Testing Connectivity

You can test SSH connectivity using the ping module:

```bash
ansible -m ping homelab
```

This sends a lightweight ping over SSH to each host.


## Recap

By now, you’ve:

- Installed Ansible
- Set up SSH key-based access to your servers
- Structured your first Ansible project
- Written and executed a basic playbook

From here, you can expand your automation toolkit — and in the next parts of this series, we’ll dive into Ansible roles, playbooks,handlers, and Vault to help you build scalable, secure, and maintainable playbooks for your homelab.
