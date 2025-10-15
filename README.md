# DNS & Reverse Proxy Infrastructure

> A self-hosted DNS and reverse proxy environment built with **BIND9**, **Traefik**, **Namecheap ACME DNS verification**, and **Docker Compose**.

---

## 🚀 Overview
This project is a complete lab setup for automating SSL certificate issuance using **Let's Encrypt** and managing internal/external traffic via **Traefik**, all routed through a **custom BIND9 DNS server** hosted locally.

The system was designed and tested on **Ubuntu Server 24.04 LTS** using **Docker** containers, with services communicating across a shared `frontend` network.

---

## 🧩 Components

| Component | Description |
|------------|-------------|
| **BIND9** | Authoritative DNS server for custom domain (e.g., `zenorahost.com`) |
| **Traefik v3** | Reverse proxy handling HTTPS termination and certificate management |
| **Let's Encrypt (ACME)** | Provides automated SSL/TLS certificates using Namecheap DNS challenge |
| **Namecheap API** | DNS provider API used for ACME DNS verification |
| **Nginx** | Example backend service hosted behind Traefik |
| **Portainer** | Web UI for Docker management, accessible via Traefik HTTPS route |

---

## 🧠 Architecture Diagram
```
                ┌─────────────────────┐
                │     Client (Web)    │
                └─────────┬───────────┘
                          │ HTTPS (443)
                          ▼
                ┌──────────────────────┐
                │      Traefik         │
                │  Reverse Proxy + SSL │
                └─────────┬────────────┘
                          │ Internal network (frontend)
          ┌───────────────┴───────────────┐
          │                               │
  ┌──────────────┐              ┌─────────────────┐
  │   Nginx App  │              │   Portainer UI  │
  └──────────────┘              └─────────────────┘
          │                               │
          ▼                               ▼
nginx.yea.zenorahost.com     portainer.yea.zenorahost.com

          │                               │                          
          ▼                               ▼   
┌────────────────────────────────────────────────────┐
│                    BIND9 DNS                       │
│                  ns.zenorahost                     │
└────────────────────────────────────────────────────┘
```

---



## 🧱 Folder Overview
Show what each folder does (instead of embedding configs):| Folder         | Purpose                                                                                                               |
| -------------- | --------------------------------------------------------------------------------------------------------------------- |
| `bind9/`       | Contains configuration for the DNS server. Defines custom zones and authoritative records for `zenorahost.com`.       |
| `traefik/`     | Houses Traefik reverse proxy setup, ACME certificate resolver, and environment variables for Namecheap DNS challenge. |
| `nginx/`       | Example backend web service for testing routing and SSL certificate issuance.                                         |
| `portainer/`   | (Optional) Web UI to manage Docker containers visually.                                                               |
| `.env.example` | Template for API credentials and domain environment variables. Copy and rename to `.env` before running.              |
| -------------- | --------------------------------------------------------------------------------------------------------------------- |

---
## 🛠 Setup & Deployment

### 1️⃣ Prerequisites
- A domain name (e.g. `zenorahost.com`)
- Access to **Namecheap API key & username**
- Installed: Docker, Docker Compose
- Local or public Linux server (tested on Ubuntu Server 24.04 LTS)

### 2️⃣ Clone Repository
```bash
git clone https://github.com/anganba/dns-traefik-lab.git
cd dns-traefik-lab
```

### 3️⃣ Configure DNS Server (BIND9)
Edit your zone file in `bind9/config/zenorahost-com.zone`:
```bash
$ORIGIN zenorahost.com.
@       IN SOA  ns.zenorahost.com. info.zenorahost.com. (
            20251015 ; serial
            12h      ; refresh
            15m      ; retry
            3w       ; expire
            2h       ; minimum ttl
            )
        IN NS   ns.zenorahost.com.
ns      IN A    192.168.68.129
yea     IN A    192.168.68.129
*.yea   IN A    192.168.68.129
```

Update `named.conf`:
```bash
zone "zenorahost.com" IN {
  type master;
  file "/etc/bind/zenorahost-com.zone";
  allow-update { none; };
};
```

Then start DNS container:
```bash
docker compose -f bind9/docker-compose.yml up -d
```
Test resolution:
```bash
dig @192.168.68.129 nginx.yea.zenorahost.com
```

---

### 4️⃣ Setup Traefik Reverse Proxy
Configure `.env` in `traefik/` folder:
```env
NAMECHEAP_API_USER=yournamecheapusername
NAMECHEAP_API_KEY=yourapikey
NAMECHEAP_API_URL=https://api.namecheap.com/xml.response
```
Run Traefik:
```bash
docker compose -f traefik/docker-compose.yml up -d
```
Verify dashboard at:
```
https://yea.zenorahost.com:8080/dashboard/#/
```

---

### 5️⃣ Deploy Nginx & Portainer (example apps)
Deploy your services using Traefik labels:
```bash
docker compose -f nginx/docker-compose.yml up -d
docker compose -f portainer/docker-compose.yml up -d
```

Then access:
```
https://nginx.yea.zenorahost.com
https://portainer.yea.zenorahost.com
```

---

## 🔒 SSL Certificate Automation
Traefik uses **Let's Encrypt DNS-01 challenge** to request certificates via Namecheap DNS.
The generated certs are stored in `data/certs/acme.json`.

Common issues:
- `acme: error presenting token: namecheap: Cannot complete command` → your domain isn’t using Namecheap nameservers.
- Fix: go to Namecheap Dashboard → Advanced DNS → set **nameservers to Namecheap BasicDNS** or your custom BIND9 if you are testing internally.

---

## 📸 Demo Screenshots
- `dig` DNS resolution showing correct IP mapping
- Traefik dashboard with routers + TLS certs
- Browser view with HTTPS padlock
- Portainer dashboard running behind Traefik

---

## 📘 Lessons Learned
- Mastered DNS server setup (SOA, NS, A, wildcard records)
- Understood how ACME DNS challenges verify domain ownership
- Built reverse proxy routing using Traefik labels
- Automated SSL renewal without manual cert management

---

## 📂 Project Structure
```text
dns-traefik-lab/
├── bind9
│   ├── config/
│   │   ├── named.conf
│   │   └── zenorahost-com.zone
│   ├── docker-compose.yml
│   ├── cache/
│   └── records/
├── traefik
│   ├── traefik.yml
│   ├── docker-compose.yml
│   ├── data/
│   │   └── certs/acme.json
│   └── .env
├── nginx
│   └── docker-compose.yml
├── portainer
│   └── docker-compose.yml
└── README.md
```

---

## 🧾 License
MIT License — freely use, modify, and share.

---

## 🌐 Author
**Anganba** — DevOps | Linux Server Administration | Cybersecurity Enthusiast
