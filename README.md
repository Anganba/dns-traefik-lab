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
│                ns.zenorahost.com                   │
└────────────────────────────────────────────────────┘
```

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

### 3️⃣ Configure environment:
Fill in your Namecheap credentials inside .env.
```bash
cp traefik/.env.example traefik/.env
```

### ⚠️ Important Configuration Note — Update Your IP Address
The IP address 192.168.68.129 used in this repository is specific to my local VM, where the BIND9 DNS server runs.
You must replace this with the IP address of your own DNS server or host machine in the following files:
```bash
bind9/config/zenorahost-com.zone
Any A-records or zone file entries referencing 192.168.68.129
```
Example:
```bash
ns      IN  A   192.168.68.129  # Change this to your server IP
yea     IN  A   192.168.68.129  # Change this too
*.yea   IN  A   192.168.68.129  # And this

```
If you skip this step, DNS queries and SSL validation will fail.

### 4️⃣ Start the DNS Server:
```bash
docker compose -f bind9/docker-compose.yaml up -d
```
Verify with:
```bash
dig @YOUR_DNS_SERVER_IP nginx.yea.zenorahost.com
```

---

### 5️⃣ Setup Traefik Reverse Proxy
Configure `.env` in `traefik/` folder:
```env
NAMECHEAP_API_USER=yournamecheapusername
NAMECHEAP_API_KEY=yourapikey
NAMECHEAP_API_URL=https://api.namecheap.com/xml.response
```
Run Traefik:
```bash
docker compose -f traefik/docker-compose.yaml up -d
```
Verify dashboard at:
```
https://traefik.yea.zenorahost.com
```

---

### 5️⃣ Deploy Nginx & Portainer (example apps)
Deploy your services using Traefik labels:
```bash
docker compose -f nginx/docker-compose.yaml up -d
docker compose -f portainer/docker-compose.yaml up -d
```

Then access:
```
https://nginx.yea.zenorahost.com
https://portainer.yea.zenorahost.com
https://traefik.yea.zenorahost.com
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
![DNS Verification](https://github.com/Anganba/ImagesHostedOnGitHub/blob/6f545125cdf5952b9d1d70a1e3bae77f955e3237/dns-traefik-lab-img/DNS_verification.png)
- Traefik dashboard with routers + TLS certs
![Traefik Dashboard](https://github.com/Anganba/ImagesHostedOnGitHub/blob/727c6bbd7b58c6b2a93dafa7e8a694993eb30886/dns-traefik-lab-img/traefik.png)
- NGINX Browser view with HTTPS padlock
![NGINX HTTPS Result](https://github.com/Anganba/ImagesHostedOnGitHub/blob/d8ec622763c0339949da6742d48752bbd697bcc7/dns-traefik-lab-img/nginx.png)
- Portainer dashboard running behind Traefik
![Portainer UI](https://github.com/Anganba/ImagesHostedOnGitHub/blob/584a5bbd3b662971b46e57e0fd224d9fb1c26c54/dns-traefik-lab-img/portainer.png)


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
**Anganba Singha** — DevOps | Linux Server Administrator | Cybersecurity Enthusiast
