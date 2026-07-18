#!/usr/bin/env bash
# 04-docker.sh — Docker: detecta el existente y solo asegura la configuración.
# (En tu VPS Docker ya está instalado; este script NO lo reinstala.)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

require_debian_like

WORK_USER="${WORK_USER:-$(logname 2>/dev/null || echo "$USER")}"

if has docker; then
  ok "Docker ya instalado: $(docker --version 2>/dev/null || echo 'versión desconocida')"
  if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose (plugin) disponible: $(docker compose version --short 2>/dev/null)"
  elif has docker-compose; then
    ok "docker-compose (v1) disponible: $(docker-compose --version)"
  else
    warn "No se detectó Docker Compose. Puedes instalar el plugin con:"
    warn "    $SUDO apt-get install -y docker-compose-plugin"
  fi
else
  warn "Docker NO está instalado. Instalación oficial:"
  warn "    curl -fsSL https://get.docker.com | $SUDO sh"
  warn "(Se omite la instalación automática porque indicaste que ya lo tienes.)"
fi

# Asegura que el usuario de trabajo puede usar Docker sin sudo.
if getent group docker >/dev/null 2>&1 && id "$WORK_USER" >/dev/null 2>&1; then
  if id -nG "$WORK_USER" | tr ' ' '\n' | grep -qx docker; then
    ok "'${WORK_USER}' ya está en el grupo docker."
  else
    $SUDO usermod -aG docker "$WORK_USER"
    ok "'${WORK_USER}' añadido al grupo docker."
    warn "Cierra sesión y vuelve a entrar para que el grupo docker surta efecto."
  fi
fi

# Asegura que el servicio arranca con el sistema.
if has systemctl && systemctl list-unit-files 2>/dev/null | grep -q '^docker.service'; then
  $SUDO systemctl enable --now docker 2>/dev/null || true
  ok "Servicio docker habilitado al arranque."
fi
