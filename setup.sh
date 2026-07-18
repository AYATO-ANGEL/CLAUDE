#!/usr/bin/env bash
# setup.sh — orquestador. Ejecuta todos los pasos de configuración del VPS
# en orden. Pensado para correr EN el VPS (Ubuntu/Debian), no desde tu portátil.
#
#   git clone <este-repo> && cd <repo>
#   cp config.example.sh config.sh   # y edítalo
#   ./setup.sh                       # todo, o:  ./setup.sh 02-security
#
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

# Carga config del usuario si existe (si no, usa los valores por defecto).
if [ -f "$HERE/config.sh" ]; then
  # shellcheck source=/dev/null
  source "$HERE/config.sh"
  echo "==> Config cargada desde config.sh"
else
  echo "⚠ No hay config.sh; usando valores por defecto. (cp config.example.sh config.sh)"
fi

# shellcheck source=scripts/lib.sh
source "$HERE/scripts/lib.sh"

STEPS=(
  "00-preflight"
  "01-base"
  "02-security"
  "03-dev-tools"
  "04-docker"
  "05-claude-code"
)

run_step() {
  local name="$1"
  local script="$HERE/scripts/${name}.sh"
  [ -f "$script" ] || die "No existe el paso: ${name}"
  echo
  log "════════ PASO: ${name} ════════"
  bash "$script"
  ok "Paso '${name}' terminado."
}

# Si se pasa un paso concreto, ejecuta solo ese.
if [ "$#" -ge 1 ]; then
  for arg in "$@"; do run_step "$arg"; done
  exit 0
fi

# Si no, ejecuta todos en orden.
for step in "${STEPS[@]}"; do
  run_step "$step"
done

echo
ok "════════ Configuración del VPS completada ════════"
echo "Recuerda: si endureciste SSH, prueba una sesión NUEVA antes de cerrar esta."
