#!/usr/bin/env bash
# memory-sync.sh — sincronización BIDIRECCIONAL vault (VPS) <-> GitHub.
# Seguro para ejecutar repetidamente (cron/timer) o a mano.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
load_config "$HERE"

[ -d "$VAULT_DIR/.git" ] || die "El vault no está inicializado. Ejecuta primero ./setup-memory-sync.sh"
cd "$VAULT_DIR"

# 1) Guarda los cambios locales del VPS.
git add -A
if git diff --cached --quiet; then
  : # nada nuevo en el VPS
else
  git commit -q -m "sync desde VPS ($(date -Iseconds))"
  log "Cambios locales del VPS commiteados."
fi

# 2) Trae los cambios de la nube (lo que Claude haya editado desde el móvil).
git fetch -q origin "$BRANCH" || die "No pude contactar con GitHub (¿red o token?)."

# 3) Fusiona. Los .md usan 'union' (no bloquean). Si algo NO-md entra en
#    conflicto, aborta sin perder datos y avisa.
if ! git merge --no-edit -q "origin/$BRANCH" 2>/dev/null; then
  err "Conflicto de fusión (archivo no-markdown). Sincronización pausada."
  err "Resuélvelo a mano en: $VAULT_DIR   (git status / git mergetool)"
  git merge --abort
  exit 1
fi

# 4) Sube todo a GitHub.
if git push -q origin "$BRANCH"; then
  ok "Memoria sincronizada con GitHub ($(date '+%H:%M:%S'))."
else
  die "Falló el push a GitHub."
fi
