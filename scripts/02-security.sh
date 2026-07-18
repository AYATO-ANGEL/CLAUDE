#!/usr/bin/env bash
# 02-security.sh — firewall (UFW), fail2ban, actualizaciones automáticas y
# endurecido de SSH con protección para no dejarte fuera.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

require_debian_like

WORK_USER="${WORK_USER:-deploy}"
SSH_PORT="${SSH_PORT:-22}"
HARDEN_SSH="${HARDEN_SSH:-1}"

# --- Firewall UFW -----------------------------------------------------------
log "Configurando firewall UFW"
apt_install ufw
$SUDO ufw default deny incoming
$SUDO ufw default allow outgoing
# IMPORTANTE: permitir SSH ANTES de activar, o te quedas fuera.
$SUDO ufw allow "${SSH_PORT}/tcp" comment 'SSH'
# HTTP/HTTPS por comodidad para servir apps (puedes quitarlas si no las usas).
$SUDO ufw allow 80/tcp  comment 'HTTP'
$SUDO ufw allow 443/tcp comment 'HTTPS'
if $SUDO ufw status | grep -q "Status: active"; then
  ok "UFW ya estaba activo; reglas actualizadas."
else
  log "Activando UFW (SSH en ${SSH_PORT} está permitido)"
  $SUDO ufw --force enable
fi
$SUDO ufw status verbose || true

# --- fail2ban ---------------------------------------------------------------
log "Instalando fail2ban (bloqueo de fuerza bruta en SSH)"
apt_install fail2ban
JAIL="/etc/fail2ban/jail.d/sshd.local"
if [ ! -f "$JAIL" ]; then
  $SUDO tee "$JAIL" >/dev/null <<EOF
[sshd]
enabled = true
port    = ${SSH_PORT}
maxretry = 5
bantime  = 1h
findtime = 10m
EOF
  ok "Configuración de fail2ban para sshd creada."
fi
$SUDO systemctl enable --now fail2ban 2>/dev/null || $SUDO service fail2ban restart || true

# --- Actualizaciones de seguridad automáticas -------------------------------
log "Habilitando actualizaciones de seguridad automáticas"
apt_install unattended-upgrades
$SUDO tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
ok "unattended-upgrades activado."

# --- Endurecido de SSH (con red de seguridad) -------------------------------
if [ "$HARDEN_SSH" != "1" ]; then
  warn "HARDEN_SSH=0 → se omite el endurecido de SSH."
  exit 0
fi

# Verifica que exista al menos una clave para el usuario ANTES de tocar SSH.
AUTHKEYS="/home/${WORK_USER}/.ssh/authorized_keys"
[ "$WORK_USER" = "root" ] && AUTHKEYS="/root/.ssh/authorized_keys"
if ! $SUDO test -s "$AUTHKEYS"; then
  err "No hay claves SSH en ${AUTHKEYS}."
  err "Se OMITE el endurecido para no bloquearte. Sube tu clave y reintenta."
  exit 0
fi
ok "Clave SSH detectada para '${WORK_USER}'. Es seguro endurecer SSH."

warn "Se va a: deshabilitar login de root y autenticación por CONTRASEÑA."
warn "Solo podrás entrar con tu clave SSH tras este paso."
if ! confirm "¿Aplicar el endurecido de SSH ahora?"; then
  warn "Endurecido de SSH cancelado por el usuario."
  exit 0
fi

DROPIN="/etc/ssh/sshd_config.d/99-hardening.conf"
$SUDO mkdir -p /etc/ssh/sshd_config.d
$SUDO tee "$DROPIN" >/dev/null <<EOF
# Generado por scripts de setup del VPS.
Port ${SSH_PORT}
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
EOF

# Valida la config antes de recargar; si es inválida, revierte.
if $SUDO sshd -t 2>/dev/null; then
  $SUDO systemctl reload ssh 2>/dev/null || $SUDO systemctl reload sshd 2>/dev/null \
    || $SUDO service ssh reload || true
  ok "SSH endurecido y recargado."
  warn "IMPORTANTE: NO cierres esta sesión todavía."
  warn "Abre una sesión NUEVA en otra terminal con tu clave y confirma que entras:"
  warn "    ssh -p ${SSH_PORT} ${WORK_USER}@<IP-de-tu-VPS>"
  warn "Si algo falla, borra ${DROPIN} y recarga sshd para revertir."
else
  err "La configuración de SSH no es válida. Revirtiendo."
  $SUDO rm -f "$DROPIN"
  die "No se aplicó el endurecido (config inválida)."
fi
