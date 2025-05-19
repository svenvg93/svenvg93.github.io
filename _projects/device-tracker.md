---
title: "Device Inventory Tracker"
date: 2025-04-08
description: "A lightweight, intuitive tool to manage your device inventory by type, model, and quantity, complete with auto-generated charts."
type: projects
---

> This project is still a WIP, this page will be updated along the way  
{: .prompt-warning }

## Overview

**Device Inventory Tracker** is a lightweight, open-source application designed to help you organize and monitor your hardware inventory—whether you’re managing a handful of devices or hundreds. It provides an intuitive UI for defining device types and models, and automatically generates charts to give you insight into stock levels and changes over time.

[View on GitHub](https://github.com/svenvg93/device-tracker)

## Features

- **Device Type & Model Management**  
  Define custom device types (e.g. “Router”, “Switch”) and associated models, each with its own metadata (color, comments).

- **Counter Tracking**  
  Create counters for each model to record quantities over time, with each counter tied to its device model and type.

- **Auto-Generated Charts**  
  View historical trends via interactive charts—no manual data export required.

- **User Authentication & Roles**  
  Secure login with role-based access: default admin account, plus the ability to invite additional users.

- **Responsive, Modern UI**  
  Built with Laravel, Tailwind CSS, and Vite for a fast, mobile-friendly experience.

## Tech Stack

- **Backend**: Laravel (PHP)  
- **Frontend**: Tailwind CSS, Alpine.js, Vite  
- **Database**: SQLite (default) or MySQL/PostgreSQL  
- **Containerization**: Docker & Docker Compose  

## Usage

- Visit `http://localhost:8080` (or your Docker host)  
- Log in with the default admin account (`admin@example.com` / `password`)  
- Navigate to **Device Types** to create your categories  
- Add **Device Models** and then **Counters** to begin tracking  
- View your **Dashboard** for real-time charts and summaries

## License

This project is released under the **MIT License**.


