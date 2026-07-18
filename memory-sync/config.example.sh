#!/usr/bin/env bash
# config.example.sh — copia a "config.sh" y ajústalo.
#
#   cp config.example.sh config.sh && nano config.sh
#
# ⚠️ config.sh contiene tu TOKEN de GitHub. Está en .gitignore: NUNCA lo subas.

# Carpeta de tu vault/memoria (Obsidian) en el VPS.
export VAULT_DIR="$HOME/memoria"

# Tu usuario de GitHub.
export GITHUB_USER="ayato-angel"

# Repo PRIVADO de GitHub que hará de puente. Créalo vacío antes (ver README).
export GITHUB_REPO_URL="https://github.com/ayato-angel/memoria.git"

# Rama a usar.
export BRANCH="main"

# Identidad para los commits automáticos que hace el VPS.
export GIT_USER_NAME="VPS Memory Sync"
export GIT_USER_EMAIL="waka.cyc@gmail.com"

# Token de acceso personal de GitHub (recomendado: "fine-grained" con permiso
# Contents: Read and write SOLO sobre el repo de memoria). Ver README para crearlo.
# Se guarda en ~/.git-credentials con permisos 600 durante el setup.
export GITHUB_TOKEN=""
