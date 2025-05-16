---
title: Ansible Series Part 3 | Ansible Vault
description: Learn how to use Ansible Vault to securely manage secrets in your playbooks.
date: 2025-05-29
categories:
  - homelab
  - automation
tags:
  - ansible
  - security
  - vault
image:
  path: /assets/img/headers/2025-05-29-ansible-series-part-3-vault.jpg
  alt: Photo by Markus Spiske on Unsplash
---

Storing API keys, tokens, and passwords in your playbooks isn’t safe—especially if you keep your Ansible project in version control. That’s where **Ansible Vault** comes in. It lets you encrypt sensitive variables while still using them like any other part of your automation.

In this third part of the series, I’ll show you how I use Vault to securely manage secrets in my homelab setup. In this example, we’ll use Vault to store a Tailscale auth key, which one of my roles uses to authenticate a server into my private Tailscale network.

## Prerequisites

- Ansible is installed (`ansible --version`)
- You have a valid Tailscale auth key (`tskey-XXXX`)
- Your project has a `group_vars/` folder


## Suggested Directory Structure

Here’s how I structure my group variables folder:

```
group_vars/
├── all.yml          # (optional) public/global variables
└── vault.yml        # encrypted secrets (Vault protected)
```

## Create the Vault File

Create an encrypted file for your secrets:

```bash
ansible-vault create group_vars/vault.yml
```

When the editor opens, enter something like:

```yaml
tailscale_auth_key: "tskey-REPLACE_ME"
```
{: file="group_vars/vault.yml" }

Then save and close the editor. The file is now encrypted and safe to commit (if you're careful with your vault password).


## Use the Vault Variable in a Playbook

You can now use the secret just like any other variable:

```yaml
- name: Authenticate with Tailscale
  ansible.builtin.command: >
    tailscale up --authkey {{ tailscale_auth_key }}
```
{: file="playbooks/tailscale.yml" }

Ansible will automatically load variables from `group_vars/`.

---

## Run the Playbook with Vault

Once you've encrypted your secrets with Ansible Vault, you can run your playbook securely by providing the vault password at runtime:

```bash
ansible-playbook playbooks/tailscale.yml --ask-vault-pass
```

This command will prompt you for the vault password before executing the playbook, ensuring your secrets are decrypted only when needed.


## Editing or Updating the Vault

To edit your encrypted file later:

```bash
ansible-vault edit group_vars/vault.yml
```

To change the vault password:

```bash
ansible-vault rekey group_vars/vault.yml
```

## Git Ignore Vault Files

Add this to your `.gitignore` file to prevent secrets from being committed:

```gitignore
group_vars/vault.yml
.vault_pass.txt
```
{: file=".gitignore" }


## Recap

In this post, you:

- Learned what Ansible Vault is and why it matters
- Created an encrypted secrets file
- Used Vault variables in a real playbook
- Ran a playbook securely with password or file-based vault access
- Updated your `.gitignore` to protect sensitive data

---

> You can find the full source for my setup on [GitHub](https://github.com/svenvg93/ansible-homelab)
