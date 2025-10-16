#!/bin/bash
# ================================================================
# DNS & Reverse Proxy Infrastructure Deployment Script
# ---------------------------------------------------------------
# Automates Docker Compose stack management for:
#   - BIND9 DNS
#   - Traefik Reverse Proxy (with Namecheap ACME)
#   - Nginx test backend
#   - Portainer
# Supports: up | down | restart
# Includes: Logging, container health status
# Author: Anganba Singha
# ================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Root path
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Compose file paths
BIND_COMPOSE="${PROJECT_ROOT}/bind9/docker-compose.yaml"
TRAEFIK_COMPOSE="${PROJECT_ROOT}/Traefik/docker-compose.yaml"
PORTAINER_COMPOSE="${PROJECT_ROOT}/Portainer-Server/docker-compose.yaml"
NGINX_COMPOSE="${PROJECT_ROOT}/nginx/docker-compose.yaml"

# Detect Docker or Podman
if command -v podman-compose &>/dev/null; then
  COMPOSE_CMD="podman-compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
elif command -v docker &>/dev/null; then
  COMPOSE_CMD="docker compose"
else
  echo -e "${RED}[✗] Neither Docker nor Podman found.${NC}"
  exit 1
fi

# Logging helpers
log()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
section(){ echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Deploy functions
compose_up() {
  section "Starting DNS & Reverse Proxy Stack"
  
  log "Starting BIND9 DNS Server..."
  $COMPOSE_CMD -f "$BIND_COMPOSE" up -d || { error "Failed to start BIND9"; exit 1; }

  log "Starting Traefik Reverse Proxy..."
  $COMPOSE_CMD -f "$TRAEFIK_COMPOSE" up -d || { error "Failed to start Traefik"; exit 1; }

  log "Starting Nginx Backend..."
  $COMPOSE_CMD -f "$NGINX_COMPOSE" up -d || { error "Failed to start Nginx"; exit 1; }

  log "Starting Portainer UI..."
  $COMPOSE_CMD -f "$PORTAINER_COMPOSE" up -d || { error "Failed to start Portainer"; exit 1; }

  section "All Services Started Successfully"
  show_status
}

compose_down() {
  section "Stopping All Services"
  $COMPOSE_CMD -f "$PORTAINER_COMPOSE" down
  $COMPOSE_CMD -f "$NGINX_COMPOSE" down
  $COMPOSE_CMD -f "$TRAEFIK_COMPOSE" down
  $COMPOSE_CMD -f "$BIND_COMPOSE" down
  log "All services have been stopped."
}

compose_restart() {
  section "Restarting All Services"
  compose_down
  sleep 3
  compose_up
}

# Show service status and health checks
show_status() {
  section "Container Status Summary"

  # Get container status table with health info
  containers=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")

  if [[ -z "$containers" ]]; then
    warn "No running containers found."
    return
  fi

  echo -e "${YELLOW}Health Checks:${NC}"
  echo "$containers" | awk -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
    NR==1 {print; next}
    /healthy/    {print green $0 nc; next}
    /starting/   {print yellow $0 nc; next}
    /unhealthy/  {print red $0 nc; next}
    {print $0}
  '
}


# Main control
case "$1" in
  up)
    compose_up
    ;;
  down)
    compose_down
    ;;
  restart)
    compose_restart
    ;;
  status)
    show_status
    ;;
  *)
    echo -e "${YELLOW}Usage:${NC} $0 {up|down|restart|status}"
    echo "  up       Start all services"
    echo "  down     Stop and remove all services"
    echo "  restart  Restart all services"
    echo "  status   Show running containers and health info"
    exit 1
    ;;
esac

