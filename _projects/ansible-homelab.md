---
title: Ansible Homelab Automation
date: 2025-05-18
description: A fully automated homelab setup using Ansible to provision and configure servers, deploy apps, and maintain consistency across environments.
---

> This project is still a WIP, this page will be updated along the way  
{: .prompt-warning }

Managing a homelab manually becomes unscalable fast. This project uses **Ansible** to automate everything from system setup to application deployment — ensuring consistent, repeatable, and version-controlled infrastructure across multiple servers.

## Features

- ✅ Provisioning of Ubuntu-based servers
- ✅ Install and configure Docker & Docker Compose
- ✅ Idempotent playbooks — safe to rerun
- ✅ Easily extendable to new devices or services

## Stack

- **Ansible** (core automation tool)
- **Ubuntu Server** (22.04 LTS)
- **Docker & Docker Compose**
- **Git** (for version control and pull-based deployment)

## Folder Structure

```shell
ansible/
|-- README.md
|-- ansible.cfg
|-- group_vars
|   `-- all.yml
|-- inventory
|   `-- hosts.yml
|-- playbooks
|   |-- docker.yml
|   |-- maintenance.yml
|   |-- netprobes.yml
|   |-- node_exporter.yml
|   |-- tailscale.yml
|   `-- timezone.yml
`-- roles
    |-- docker
    |   |-- handlers
    |   |   `-- main.yml
    |   `-- tasks
    |       `-- main.yml
    |-- maintenance
    |   `-- tasks
    |       `-- main.yml
    |-- node_exporter
    |   |-- handlers
    |   |   `-- main.yml
    |   `-- tasks
    |       `-- main.yml
    |-- tailscale
    |   |-- handlers
    |   |   `-- main.yml
    |   `-- tasks
    |       `-- main.yml
    `-- telegraf
        |-- handlers
        |   `-- main.yml
        `-- tasks
            `-- main.yml
```

## Usage

Run the playbooks like this:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/maintenance.yml
ansible-playbook -i inventory/hosts.yml playbooks/docker.yml
ansible-playbook -i inventory/hosts.yml playbooks/node_exporter.yml
```

## Security

- SSH-only access
- Secrets encrypted with `ansible-vault`

## GitHub

[View the project on GitHub »](https://github.com/svenvg93/ansible-homelab)
