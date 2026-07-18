#!/usr/bin/env bash
# 00-preflight.sh — comprobaciones previas. No cambia nada en el sistema.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

log "Preflight: comprobando el sistema antes de configurarlo"

require_debian_like

# Arquitectura y recursos
ok "Kernel: $(uname -srm)"
ok "CPU(s): $(nproc)   RAM: $(free -h | awk '/^Mem:/{print $2}')   Disco libre: $(df -h / | awk 'NR==2{print $4}')"

# ¿Somos root o hay sudo?
if [ "$(id -u)" -eq 0 ]; then
  ok "Ejecutando como root."
else
  if $SUDO -n true 2>/dev/null; then
    ok "sudo disponible sin contraseña."
  else
    warn "sudo pedirá contraseña durante la instalación."
  fi
fi

# ¿Hay clave SSH para el usuario de trabajo? (clave para el endurecido)
WORK_USER="${WORK_USER:-$(logname 2>/dev/null || echo "$USER")}"
AUTHKEYS="/home/${WORK_USER}/.ssh/authorized_keys"
[ "$WORK_USER" = "root" ] && AUTHKEYS="/root/.ssh/authorized_keys"

if [ -s "$AUTHKEYS" ]; then
  n=$(grep -c -E '^(ssh-|ecdsa-|sk-)' "$AUTHKEYS" 2>/dev/null || echo 0)
  ok "Claves SSH para '${WORK_USER}': ${n} encontrada(s) en ${AUTHKEYS}"
else
  warn "No se encontraron claves SSH para '${WORK_USER}' en ${AUTHKEYS}."
  warn "El endurecido de SSH se saltará para no bloquearte el acceso."
fi

# Conectividad de salida (para descargar paquetes/Node/Claude Code)
if has curl && curl -fsS --max-time 8 https://deb.nodesource.com >/dev/null 2>&1; then
  ok "Conectividad de salida HTTPS: OK"
else
  warn "No pude verificar salida HTTPS; revisa red/DNS del VPS."
fi

log "Preflight completado. Revisa los avisos ⚠ antes de continuar."
