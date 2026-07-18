#!/usr/bin/env bash
# 05-claude-code.sh — instala Claude Code en el VPS para el usuario de trabajo.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

WORK_USER="${WORK_USER:-$(logname 2>/dev/null || echo "$USER")}"

if ! has node; then
  die "Node.js no está instalado. Ejecuta antes 03-dev-tools.sh."
fi

NODE_MAJOR_INSTALLED="$(node -v | sed 's/^v//' | cut -d. -f1)"
if [ "$NODE_MAJOR_INSTALLED" -lt 18 ]; then
  die "Claude Code necesita Node >= 18. Instalado: $(node -v)."
fi

log "Instalando Claude Code (@anthropic-ai/claude-code)"

# Preferimos instalarlo como el usuario de trabajo, sin sudo, usando su prefijo.
if id "$WORK_USER" >/dev/null 2>&1 && [ "$WORK_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$WORK_USER" | cut -d: -f6)"
  $SUDO -u "$WORK_USER" -H bash -lc \
    'npm install -g @anthropic-ai/claude-code' \
    && ok "Claude Code instalado para '${WORK_USER}'." \
    || die "Falló la instalación de Claude Code."
  BIN="${USER_HOME}/.npm-global/bin/claude"
else
  $SUDO npm install -g @anthropic-ai/claude-code \
    && ok "Claude Code instalado globalmente." \
    || die "Falló la instalación de Claude Code."
  BIN="$(command -v claude || echo claude)"
fi

cat <<EOF

${C_GREEN}${C_BOLD}Claude Code instalado.${C_RESET}

Para empezar a usarlo en el VPS:
  1) Entra como tu usuario de trabajo:   ssh ${WORK_USER}@<IP-de-tu-VPS>
  2) Recarga el PATH:                    source ~/.profile
  3) Ve a tu proyecto:                   cd ~/mi-proyecto
  4) Lanza Claude Code:                  claude
     (la primera vez te pedirá autenticarte en el navegador)

Binario: ${BIN}
EOF
