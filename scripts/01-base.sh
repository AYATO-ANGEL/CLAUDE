#!/usr/bin/env bash
# 01-base.sh — actualiza el sistema, crea el usuario de trabajo y paquetes base.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

require_debian_like

WORK_USER="${WORK_USER:-deploy}"
TIMEZONE="${TIMEZONE:-Europe/Madrid}"

log "Actualizando índices de paquetes y el sistema"
$SUDO apt-get update -y
$SUDO DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

log "Instalando paquetes esenciales"
apt_install ca-certificates curl wget gnupg lsb-release \
            git build-essential unzip zip tar \
            htop tmux vim nano jq ripgrep fd-find tree \
            software-properties-common apt-transport-https

log "Configurando zona horaria: ${TIMEZONE}"
$SUDO timedatectl set-timezone "$TIMEZONE" 2>/dev/null || warn "No se pudo fijar la zona horaria."

# --- Usuario de trabajo no-root con sudo ------------------------------------
if id "$WORK_USER" >/dev/null 2>&1; then
  ok "El usuario '${WORK_USER}' ya existe."
else
  log "Creando usuario de trabajo '${WORK_USER}'"
  $SUDO adduser --disabled-password --gecos "" "$WORK_USER"
  ok "Usuario creado."
fi

if id -nG "$WORK_USER" | tr ' ' '\n' | grep -qx sudo; then
  ok "'${WORK_USER}' ya está en el grupo sudo."
else
  $SUDO usermod -aG sudo "$WORK_USER"
  ok "'${WORK_USER}' añadido al grupo sudo."
fi

# Copia claves SSH de root al usuario nuevo si el usuario no tiene ninguna.
ROOT_KEYS="/root/.ssh/authorized_keys"
USER_SSH="/home/${WORK_USER}/.ssh"
if [ -s "$ROOT_KEYS" ] && [ ! -s "${USER_SSH}/authorized_keys" ]; then
  log "Copiando claves SSH de root a '${WORK_USER}'"
  $SUDO install -d -m 700 -o "$WORK_USER" -g "$WORK_USER" "$USER_SSH"
  $SUDO install -m 600 -o "$WORK_USER" -g "$WORK_USER" "$ROOT_KEYS" "${USER_SSH}/authorized_keys"
  ok "Claves copiadas. Ahora puedes entrar como '${WORK_USER}'."
fi

ok "Base del sistema lista."
