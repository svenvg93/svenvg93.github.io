---
title: Ansible Series Part x | Ansible Vault
description: This guide walks you through using Ansible Vault to encrypt your secrets.
date: 2025-05-15
categories:
  - homelab
  - automation
tags:
  - ansible
image:
  path: /assets/img/headers/2025-05-15-setup-ansible-vault.jpg
  alt: Photo by Jason Pofahl on Unsplash
---

## Prerequisites

- Ansible installed (`ansible --version`)
- A valid Tailscale auth key (`tskey-XXXX`)
- Your Ansible project has a `group_vars/` folder

---

## Suggested Directory Structure

```
group_vars/
├── all.yml          # (optional) public/global variables
└── vault.yml        # encrypted secrets (Vault protected)
```

---

## Step 1: Create the Vault File

Create an encrypted file to store the Tailscale auth key:

```bash
ansible-vault create group_vars/vault.yml
```

Inside the editor that opens, enter:

```yaml
tailscale_auth_key: "tskey-REPLACE_ME"
```

Then save and exit.

---

## Step 2: Use the Variable in Your Role or Playbook

Use the variable like any other:

```yaml
- name: Authenticate with Tailscale
  ansible.builtin.command: >
    tailscale up --authkey {{ tailscale_auth_key }} --hostname {{ inventory_hostname }}
```

Ansible automatically loads all variables from `group_vars/`.

---

## Step 3: Run Your Playbook with Vault

You can run the playbook by providing the vault password:

### Option A: Prompt for password

```bash
ansible-playbook playbooks/tailscale.yml --ask-vault-pass
```

### Option B: Use a password file (secure it!)

```bash
ansible-playbook playbooks/tailscale.yml \
  --vault-password-file ~/.ansible/vault_pass.txt
```

---

## Step 4: Edit or Update the Vault File

To update the key later:

```bash
ansible-vault edit group_vars/vault.yml
```

To change the password protecting the vault file:

```bash
ansible-vault rekey group_vars/vault.yml
```

---

## Step 5: Prevent Secrets from Being Committed

Update your `.gitignore`:

```gitignore
group_vars/all.yml
!group_vars/all.yml.bak
group_vars/vault.yml
.vault_pass.txt
```

---

## Optional: Reference Vault Variables from `all.yml`

If you want to separate public/private configs:

```yaml
# group_vars/all.yml
tailscale_auth_key: "{{ vault_tailscale_auth_key }}"
```

And inside `vault.yml`:

```yaml
vault_tailscale_auth_key: "tskey-REPLACE_ME"
```

---

## Additional Resources

- [🔗 Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [🔐 Tailscale Auth Keys](https://tailscale.com/kb/1085/auth-keys/)

