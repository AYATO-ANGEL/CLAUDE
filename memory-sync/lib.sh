#!/usr/bin/env bash
# lib.sh — helpers compartidos por los scripts de memory-sync.
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
fi
log()  { printf '%s\n' "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; }
ok()   { printf '%s\n' "${C_GREEN}✓${C_RESET} $*"; }
warn() { printf '%s\n' "${C_YELLOW}⚠ $*${C_RESET}" >&2; }
err()  { printf '%s\n' "${C_RED}✗ $*${C_RESET}" >&2; }
die()  { err "$*"; exit 1; }

load_config() {
  local here="$1"
  if [ -f "$here/config.sh" ]; then
    # shellcheck source=/dev/null
    source "$here/config.sh"
  else
    die "Falta config.sh. Ejecuta:  cp config.example.sh config.sh && nano config.sh"
  fi
  : "${VAULT_DIR:?Define VAULT_DIR en config.sh}"
  : "${GITHUB_REPO_URL:?Define GITHUB_REPO_URL en config.sh}"
  : "${BRANCH:=main}"
  : "${GIT_USER_NAME:=VPS Memory Sync}"
  : "${GIT_USER_EMAIL:=vps@localhost}"
}
