# DNS & Reverse Proxy Infrastructure

> A complete self-hosted DNS and reverse proxy solution with automated SSL management using **BIND9**, **Traefik**, and **Docker Compose**. Built as a practical infrastructure lab project demonstrating DNS, reverse proxy routing, and TLS automation with Namecheap's API and Let's Encrypt.

---

## 🚀 Overview
This project replicates a small-scale production setup for managing internal and external services with your own DNS authority and automated HTTPS via Traefik. The system runs locally or on a VPS, allowing dynamic certificate generation through the Namecheap DNS API.

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
```bash
sudo apt install docker.io
sudo apt install docker-compose
```
- Local or public Linux server (tested on Ubuntu Server 24.04 LTS)

### 2️⃣ Clone Repository
```bash
git clone https://github.com/anganba/dns-traefik-lab.git
cd dns-traefik-lab
```

### 3️⃣ Configure environment:
Make sure to give this permission:
`sudo chmod 600 Traefik/data/certs/namecheap-acme.json`
Fill in your Namecheap credentials inside .env.
```bash
cp Traefik/.env.example Traefik/.env
```
Configure `.env` in `traefik/` folder:
```env
NAMECHEAP_API_USER=yournamecheapusername
NAMECHEAP_API_KEY=yourapikey
NAMECHEAP_API_URL=https://api.namecheap.com/xml.response
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

Also Your Namecheap account must have:
API access enabled under “Profile → Tools → Namecheap API Access”.
Your host’s public IP added to the “API Whitelist IPs” section.
If you don't have your local VMs' IP or VPS IP get whitelisted in the Namecheap API section, TLS Handshake will fail.
### Run the deploy script:
```bash
sudo ./deploy.sh up
```
If this ERROR pops up: Network frontend declared as external, but could not be found. 
Please create the network manually using `sudo docker network create frontend` and try again.

Make sure to restart the container using this command:
`sudo ./deploy.sh restart`

### The usage of the deploy script:
```
Usage: ./deploy.sh {up|down|restart|status}
  up       Start all services
  down     Stop and remove all services
  restart  Restart all services
  status   Show running containers and health info  
```


### 4️⃣ Verify the DNS Server:

```bash
dig @YOUR_DNS_SERVER_IP nginx.yea.zenorahost.com
```

Verify Traefik dashboard at:
```
https://traefik.yea.zenorahost.com
```

### 6️⃣ Verify Nginx & Portainer (example apps)
To access:
```
https://nginx.yea.zenorahost.com
https://portainer.yea.zenorahost.com
https://traefik.yea.zenorahost.com
```
### ⚠️ Important Configuration Note — Update Your DNS Settings
If you want to access those `https://traefik.yea.zenorahost.com` in your windows or local machine, make sure to point your DNS settings preferred DNS to `VM's IP where DNS server is running` and as alternative DNS use `1.1.1.1` or `8.8.8.8` .
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
└── deploy.sh
└── README.md
```
---

## 🧠 What You’ll Learn
- Setting up an **authoritative DNS server** with custom zones
- Using **DNS-based ACME challenges** for HTTPS automation
- Managing **reverse proxy routes** dynamically with Docker labels
- Deploying self-contained, production-like infrastructure stacks

---

## 🧩 Troubleshooting

### 🔹 Permission Issues (first-time setup)
If BIND9 fails to read/write files under `config`, `cache`, or `records`, run these commands **once**:
```bash
# Quick method (less secure)
sudo chmod -R 777 ./config ./cache ./records

# Recommended secure method
sudo chown -R 100:101 ./config ./cache ./records
sudo chmod -R 755 ./config ./cache ./records
```
**When to use:**
- Happens when BIND9 cannot access zone files or cache directories inside the container.
- Usually appears as `permission denied` errors or missing zone load logs.

### 🔹 404 Page Not Found
- Usually caused by an incorrect router rule or wrong container port mapping.
- Double-check the `traefik.http.routers.<service>.rule` and internal port.

### 🔹 ACME / Certificate Errors
- Verify that your domain (`zenorahost.com`) nameservers point to your BIND9 instance.
- Check that the zone file matches the public DNS entries.

### 🔹 TLS Handshake Error
- Ensure Namecheap API credentials are valid and propagated.
- Wait for DNS records to update (can take up to 10–15 min).
- Sometimes if TLS handshake fails it might be issues with the file permission
Change ownership and permissions so Traefik can manage the file.
If your container runs as root (most Traefik images do by default):
```
chmod 600 ./data/certs/namecheap-acme.json

```
---

## 🏁 Future Enhancements
- Add HAProxy or Cloudflare DNS integration
- Enable IPv6 support in BIND9 and Traefik
- Add Grafana + Prometheus monitoring

---

## 🪪 License
MIT License — Free for educational and demonstration use.

---

## 🌐 Author
**Anganba Singha** — DevOps | Linux Server Administrator | Cybersecurity Enthusiast
