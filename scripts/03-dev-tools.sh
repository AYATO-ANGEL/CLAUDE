#!/usr/bin/env bash
# 03-dev-tools.sh — Node.js LTS y utilidades de desarrollo.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

require_debian_like

NODE_MAJOR="${NODE_MAJOR:-20}"

# --- Node.js (NodeSource) ---------------------------------------------------
if has node && node -v | grep -qE "^v(1[89]|[2-9][0-9])"; then
  ok "Node.js ya instalado: $(node -v)"
else
  log "Instalando Node.js ${NODE_MAJOR}.x (NodeSource)"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | $SUDO -E bash -
  apt_install nodejs
  ok "Node.js instalado: $(node -v) / npm $(npm -v)"
fi

# npm global sin sudo para el usuario de trabajo (prefijo en su HOME)
WORK_USER="${WORK_USER:-$(logname 2>/dev/null || echo "$USER")}"
if id "$WORK_USER" >/dev/null 2>&1 && [ "$WORK_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$WORK_USER" | cut -d: -f6)"
  NPM_DIR="${USER_HOME}/.npm-global"
  $SUDO -u "$WORK_USER" mkdir -p "$NPM_DIR"
  PROFILE="${USER_HOME}/.profile"
  if ! grep -q ".npm-global/bin" "$PROFILE" 2>/dev/null; then
    printf '\n# npm global sin sudo\nexport PATH="$HOME/.npm-global/bin:$PATH"\n' \
      | $SUDO tee -a "$PROFILE" >/dev/null
    $SUDO -u "$WORK_USER" npm config set prefix "$NPM_DIR" 2>/dev/null || true
    ok "npm global configurado para '${WORK_USER}' en ~/.npm-global (sin sudo)."
  fi
fi

# --- Utilidades de desarrollo -----------------------------------------------
log "Instalando utilidades de desarrollo"
apt_install git-lfs python3 python3-pip python3-venv make pkg-config
git lfs install --system 2>/dev/null || true

# --- Config útil de tmux (solo si no existe) --------------------------------
if id "$WORK_USER" >/dev/null 2>&1; then
  USER_HOME="$(getent passwd "$WORK_USER" | cut -d: -f6)"
  TMUXCONF="${USER_HOME}/.tmux.conf"
  if [ ! -f "$TMUXCONF" ]; then
    $SUDO -u "$WORK_USER" tee "$TMUXCONF" >/dev/null <<'EOF'
set -g mouse on
set -g history-limit 10000
set -g base-index 1
setw -g pane-base-index 1
set -g default-terminal "screen-256color"
EOF
    ok "Config básica de tmux creada para '${WORK_USER}'."
  fi
fi

ok "Herramientas de desarrollo listas."
