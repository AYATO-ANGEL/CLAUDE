#!/usr/bin/env bash
# memory-watch.sh — sincroniza casi en tiempo real: observa cambios en el vault
# y lanza memory-sync.sh tras unos segundos de calma (debounce).
# Alternativa al timer de systemd (útil si quieres sync inmediato al guardar).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
load_config "$HERE"

command -v inotifywait >/dev/null 2>&1 \
  || die "Falta inotifywait. Instala:  sudo apt-get install -y inotify-tools"

DEBOUNCE="${DEBOUNCE:-10}"   # segundos de calma antes de sincronizar
log "Observando $VAULT_DIR (debounce ${DEBOUNCE}s). Ctrl-C para parar."

# Sincroniza una vez al arrancar.
bash "$HERE/memory-sync.sh" || warn "Sync inicial falló; sigo observando."

while true; do
  # Espera a que ocurra algún cambio (ignora la carpeta .git).
  inotifywait -r -q -e modify,create,delete,move \
    --exclude '(/\.git/|\.git$)' "$VAULT_DIR" >/dev/null || true
  # Espera calma: mientras sigan llegando cambios, reinicia el contador.
  while inotifywait -r -q -t "$DEBOUNCE" -e modify,create,delete,move \
      --exclude '(/\.git/|\.git$)' "$VAULT_DIR" >/dev/null 2>&1; do :; done
  bash "$HERE/memory-sync.sh" || warn "Sync falló; reintentaré en el próximo cambio."
done
