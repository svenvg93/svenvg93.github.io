---
title: Automating Dependabot for Docker Compose
description:
date: 2025-05-12
categories:
  - homelab
  - automation
tags:
  - github
image:
  path: /assets/img/headers/2025-05-12-dependabot-docker-compose.jpg
  alt: Photo by Markus Winkler on Unsplash
---

Keeping dependencies up to date is essential for security and maintainability—but manually managing updates across multiple `docker-compose.yml` files in a project can be tedious. In this post, I’ll show you a small Bash script I wrote to automate the generation of a `dependabot.yml` file. It scans your repo for all Docker Compose files and configures Dependabot to check them for updates monthly. It’s lightweight, efficient, and ensures you never miss a patch. Let’s dive in. We will automate the updating the `dependabot.yml` with Github Actions.




