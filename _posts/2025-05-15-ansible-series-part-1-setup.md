---
title: Ansible Series Part 1 | Initial Setup
description: Getting started with Ansible — from installation to your first automated task.
date: 2025-05-15
categories:
  - Automation
tags:
  - ansible
series:
  - Ansible
series_part: 1
image:
  path: /assets/img/headers/2025-05-15-ansible-series-part-1-setup.jpg
  alt: Photo by Jake Walker on Unsplash
---

Ansible is a powerful automation tool that lets you manage your infrastructure using simple, repeatable playbooks. In this first part of the series, you'll install Ansible, configure SSH access, and run your first task — laying the foundation for automating your homelab.

## Install Ansible

Install Ansible on your local workstation or control node. In my case I use a my macbook as "control node".

Ensure pip is available and up to date:
```bash
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip
```

Install Ansible:
```bash
pip install ansible
```

Verify the installation:
```bash
ansible --version
```

## Set Up SSH Key Access

Ansible connects to remote machines via SSH. To avoid typing passwords every time, set up SSH key authentication.

> If you already use [Tailscale](https://tailscale.com) to access your nodes, you can use **Tailscale SSH** instead of managing your own SSH keys.


### Generate a key pair

```bash
ssh-keygen -t ed25519
```

Press enter to use the default file location. Leave the passphrase empty for automation.

### Copy your public key to a remote host

```bash
ssh-copy-id user@your-server-ip
```

Then test your connection:

```bash
ssh user@your-server-ip
```

If you’re logged in without a password prompt, you're ready to automate.

## Project Structure

Here’s a basic layout for organizing your Ansible project:

```
homelab-ansible/
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── playbooks/
│   └── install-htop.yml
└── README.md
```

### Create the ansibile configuration file

The `ansible.cfg` file is typically located either in your home directory or in the `/etc/ansible` directory.

```ini
[defaults]
inventory = ./inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
timeout = 10
```
{: file="ansible.cfg" }

This configuration:
- Points to your inventory file
- Disables SSH host key prompts
- Improves reliability by disabling retry files and adding a timeout

### Define Your Inventory

Create a static inventory file to list your homelab machines. This file is typically placed in your current working directory, alongside your playbooks and roles in the inventory folder

```yaml
all:
  children:
    homelab:
      hosts:
        server01:
        server02:
```
{: file="inventory/hosts.yml" }

Replace `server01` and `server02` with actual IPs or hostnames.



## Test SSH Connectivity

Use Ansible’s ping module to confirm everything is working:

```bash
ansible -m ping homelab
```

Each machine should return `pong` if SSH and the inventory are set up correctly.



## First Playbook: Install htop

Let's create a simple Ansible playbook to install a package (in this case, `htop`) on all your homelab servers. It's a good practice to save your playbooks in a dedicated playbooks/ directory. If you don't have this folder yet, you can create it.

Save the following content as `playbooks/install-htop.yml`:

```yaml
- name: Install htop on homelab servers
  hosts: homelab
  become: true
  tasks:
    - name: Ensure htop is installed
      ansible.builtin.apt:
        name: htop
        state: present
```
{: file="playbooks/install-htop.yml" }

This playbook:
- Connects to all hosts in the `homelab` group
- Uses `sudo` (`become: true`)
- Installs the `htop` package if it's not already present

## Run the Playbook

From your project root:

```bash
ansible-playbook playbooks/install-htop.yml --ask-become-pass
```

> If your user has passwordless sudo, you can skip the `--ask-become-pass` flag.

## Recap

You’ve now:

- Installed Ansible
- Set up SSH key access to your servers
- Created a clean project structure
- Written and executed a basic playbook

## What’s Next

In the next parts of this series, we’ll cover:
- Organizing your automation with roles
- Reacting to changes using handlers
- Managing secrets securely with Ansible Vault

You’re now ready to scale up your homelab automation. Let's continue. 

> In the meantime check out my [git repro](https://github.com/svenvg93/ansible-homelab) that I use for my homelab
