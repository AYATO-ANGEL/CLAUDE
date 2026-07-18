#!/usr/bin/env bash
# lib.sh — funciones compartidas por todos los scripts de setup.
# No se ejecuta directamente; se importa con:  source "$(dirname "$0")/lib.sh"

# ---- Colores (se desactivan si no hay terminal) ----------------------------
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
fi

log()   { printf '%s\n' "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; }
ok()    { printf '%s\n' "${C_GREEN}✓${C_RESET} $*"; }
warn()  { printf '%s\n' "${C_YELLOW}⚠ $*${C_RESET}" >&2; }
err()   { printf '%s\n' "${C_RED}✗ $*${C_RESET}" >&2; }
die()   { err "$*"; exit 1; }

# ¿Corremos como root o con sudo disponible?
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    die "Este script necesita root o sudo, y no se encontró sudo."
  fi
fi

# Pregunta sí/no. Devuelve 0 para sí. Respeta ASSUME_YES=1.
confirm() {
  local prompt="${1:-¿Continuar?}"
  if [ "${ASSUME_YES:-0}" = "1" ]; then return 0; fi
  local reply
  read -r -p "${C_YELLOW}${prompt} [s/N] ${C_RESET}" reply
  case "$reply" in
    [sS]|[sS][iíIÍ]|[yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ¿Está instalado un comando?
has() { command -v "$1" >/dev/null 2>&1; }

# Instala paquetes apt si faltan (idempotente).
apt_install() {
  local to_install=()
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      to_install+=("$pkg")
    fi
  done
  if [ "${#to_install[@]}" -eq 0 ]; then
    ok "Ya instalado: $*"
    return 0
  fi
  log "Instalando: ${to_install[*]}"
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "${to_install[@]}"
}

# Comprueba que estamos en Debian/Ubuntu.
require_debian_like() {
  if [ ! -f /etc/os-release ]; then
    die "No se encontró /etc/os-release; sistema no soportado por estos scripts."
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *debian*|*ubuntu*) ok "Sistema: ${PRETTY_NAME:-desconocido}" ;;
    *) die "Estos scripts asumen Debian/Ubuntu. Detectado: ${PRETTY_NAME:-desconocido}" ;;
  esac
}
