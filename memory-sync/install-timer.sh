#!/usr/bin/env bash
# install-timer.sh — instala el timer de systemd (a nivel de usuario) que
# sincroniza la memoria cada 5 minutos. No requiere root.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

command -v systemctl >/dev/null 2>&1 || die "systemd no disponible; usa cron (ver README)."

UNIT_DIR="$HOME/.config/systemd/user"
mkdir -p "$UNIT_DIR"

# Copia las unidades sustituyendo la ruta de instalación real.
sed "s#__INSTALL_DIR__#${HERE}#g" "$HERE/systemd/memory-sync.service" > "$UNIT_DIR/memory-sync.service"
cp "$HERE/systemd/memory-sync.timer" "$UNIT_DIR/memory-sync.timer"
ok "Unidades instaladas en $UNIT_DIR"

systemctl --user daemon-reload
systemctl --user enable --now memory-sync.timer
ok "Timer activado (sincroniza cada 5 min)."

# Para que el timer siga corriendo aunque no haya sesión iniciada del usuario.
if command -v loginctl >/dev/null 2>&1; then
  loginctl enable-linger "$USER" 2>/dev/null \
    && ok "Linger activado: la sincronización corre aunque no estés conectado." \
    || warn "No pude activar linger (quizá necesitas: sudo loginctl enable-linger $USER)."
fi

echo
echo "Comprueba el estado con:"
echo "  systemctl --user list-timers memory-sync.timer"
echo "  systemctl --user status memory-sync.service"
echo "  journalctl --user -u memory-sync.service -n 20"
