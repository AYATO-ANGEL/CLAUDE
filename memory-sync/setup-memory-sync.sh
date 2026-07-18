#!/usr/bin/env bash
# setup-memory-sync.sh — configuración ÚNICA (una sola vez) en el VPS.
# Convierte tu vault de Obsidian en un repo Git y lo conecta a GitHub.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
load_config "$HERE"

[ -d "$VAULT_DIR" ] || die "No existe la carpeta VAULT_DIR: $VAULT_DIR"
command -v git >/dev/null 2>&1 || die "git no está instalado (instálalo con: sudo apt-get install -y git)"

log "Configurando sincronización para: $VAULT_DIR"
cd "$VAULT_DIR"

# --- Repo git ---------------------------------------------------------------
if [ ! -d .git ]; then
  git init -b "$BRANCH"
  ok "Repositorio Git inicializado (rama $BRANCH)."
else
  ok "Ya es un repositorio Git."
  git symbolic-ref -q HEAD "refs/heads/$BRANCH" 2>/dev/null || git checkout -B "$BRANCH"
fi

# --- .gitignore para Obsidian (solo lo volátil) -----------------------------
if [ ! -f .gitignore ]; then
  cat > .gitignore <<'EOF'
# Estado volátil de Obsidian (cambia constantemente, no aporta a la memoria)
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.obsidian/.DS_Store
# Papelera y temporales
.trash/
.DS_Store
EOF
  ok ".gitignore de Obsidian creado."
fi

# --- .gitattributes: fusión "union" para markdown ---------------------------
# Evita conflictos al editar la misma nota en el VPS y en la nube: conserva
# ambos lados en vez de bloquear con marcadores de conflicto.
if [ ! -f .gitattributes ]; then
  printf '*.md merge=union\n' > .gitattributes
  ok ".gitattributes creado (markdown con fusión union)."
fi

# --- Identidad de commits ---------------------------------------------------
git config user.name  "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

# --- Credenciales de GitHub (HTTPS) -----------------------------------------
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git config --global credential.helper store
  CRED="$HOME/.git-credentials"
  touch "$CRED"; chmod 600 "$CRED"
  # Elimina línea previa de github.com y añade la nueva (sin duplicar).
  grep -v '@github.com' "$CRED" > "${CRED}.tmp" 2>/dev/null || true
  mv "${CRED}.tmp" "$CRED"
  printf 'https://%s:%s@github.com\n' "${GITHUB_USER:-git}" "$GITHUB_TOKEN" >> "$CRED"
  chmod 600 "$CRED"
  ok "Token de GitHub guardado de forma segura en ~/.git-credentials (600)."
else
  warn "No definiste GITHUB_TOKEN. Necesitarás autenticarte a mano al hacer push."
fi

# --- Remoto -----------------------------------------------------------------
git remote remove origin 2>/dev/null || true
git remote add origin "$GITHUB_REPO_URL"
ok "Remoto 'origin' = $GITHUB_REPO_URL"

# --- Primer commit ----------------------------------------------------------
git add -A
if git diff --cached --quiet; then
  ok "No hay cambios nuevos que commitear."
else
  git commit -m "Instantánea inicial de la memoria desde el VPS ($(date -Iseconds))"
  ok "Commit inicial creado."
fi

# --- Sincroniza con el remoto (por si el repo ya tenía contenido) -----------
if git ls-remote --exit-code origin "$BRANCH" >/dev/null 2>&1; then
  log "El repo remoto ya tiene la rama $BRANCH; fusionando..."
  git fetch origin "$BRANCH"
  git merge --no-edit "origin/$BRANCH" --allow-unrelated-histories \
    || die "Conflicto al fusionar. Resuélvelo a mano en $VAULT_DIR y reintenta."
fi

log "Subiendo a GitHub..."
git push -u origin "$BRANCH"

echo
ok "════════ Setup completado ════════"
echo "Tu memoria ya está en: $GITHUB_REPO_URL"
echo "Siguiente paso: activa la sincronización automática (ver README)"
echo "  o ejecuta manualmente:  ./memory-sync.sh"
